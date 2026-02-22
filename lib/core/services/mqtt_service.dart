/// Smart Home AI — MQTT Client Service
///
/// Manages connection to the MQTT broker (TCP for mobile, WebSocket for web).
/// Subscribes to ESP32 sensor/device/alert topics.
/// Publishes device commands.
///
/// © 2026 Circuvent Technologies Pvt Ltd, Hyderabad

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:smart_home_ai/core/models/mqtt_models.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/models/device_model.dart';

class MqttService extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────────────────

  MqttConfig _config = const MqttConfig();
  AppMqttConnectionState _connectionState = AppMqttConnectionState.disconnected;
  MqttServerClient? _client;
  Timer? _reconnectTimer;
  final _uuid = const Uuid();

  // Parsed live data
  MqttSensorMessage? _lastSensorData;
  MqttDeviceStatus? _lastDeviceStatus;
  MqttSystemStatus? _lastSystemStatus;
  final List<MqttAlert> _alerts = [];
  final List<MqttSensorMessage> _sensorHistory = [];
  final Map<String, SensorData> _currentReadings = {};
  final List<SmartDevice> _liveDevices = [];

  // Streams for consumers
  final _sensorController = StreamController<MqttSensorMessage>.broadcast();
  final _deviceStatusController = StreamController<MqttDeviceStatus>.broadcast();
  final _alertController = StreamController<MqttAlert>.broadcast();
  final _systemStatusController = StreamController<MqttSystemStatus>.broadcast();
  final _connectionController = StreamController<AppMqttConnectionState>.broadcast();

  // ─── Getters ──────────────────────────────────────────────────────────────

  MqttConfig get config => _config;
  AppMqttConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == AppMqttConnectionState.connected;
  MqttSensorMessage? get lastSensorData => _lastSensorData;
  MqttDeviceStatus? get lastDeviceStatus => _lastDeviceStatus;
  MqttSystemStatus? get lastSystemStatus => _lastSystemStatus;
  List<MqttAlert> get alerts => List.unmodifiable(_alerts);
  List<MqttSensorMessage> get sensorHistory => List.unmodifiable(_sensorHistory);
  Map<String, SensorData> get currentReadings => Map.unmodifiable(_currentReadings);
  List<SmartDevice> get liveDevices => List.unmodifiable(_liveDevices);

  Stream<MqttSensorMessage> get sensorStream => _sensorController.stream;
  Stream<MqttDeviceStatus> get deviceStatusStream => _deviceStatusController.stream;
  Stream<MqttAlert> get alertStream => _alertController.stream;
  Stream<MqttSystemStatus> get systemStatusStream => _systemStatusController.stream;
  Stream<AppMqttConnectionState> get connectionStream => _connectionController.stream;

  // ─── Configuration ────────────────────────────────────────────────────────

  /// Load saved MQTT config from SharedPreferences.
  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('mqtt_config');
      if (json != null) {
        _config = MqttConfig.fromJson(jsonDecode(json));
      }
      // Auto-detect web platform
      if (kIsWeb) {
        _config = _config.copyWith(useWebSocket: true);
      }
    } catch (e) {
      debugPrint('MqttService: Failed to load config: $e');
    }
  }

  /// Save MQTT config to SharedPreferences.
  Future<void> saveConfig(MqttConfig newConfig) async {
    _config = newConfig;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mqtt_config', jsonEncode(newConfig.toJson()));
    } catch (e) {
      debugPrint('MqttService: Failed to save config: $e');
    }
    notifyListeners();
  }

  /// Update broker address and reconnect.
  Future<void> updateBroker(String broker) async {
    await saveConfig(_config.copyWith(broker: broker));
    await disconnect();
    await connect();
  }

  // ─── Connection ───────────────────────────────────────────────────────────

  /// Connect to the MQTT broker.
  Future<bool> connect({MqttConfig? overrideConfig}) async {
    if (_connectionState == AppMqttConnectionState.connected ||
        _connectionState == AppMqttConnectionState.connecting) {
      return isConnected;
    }

    final cfg = overrideConfig ?? _config;
    _setConnectionState(AppMqttConnectionState.connecting);

    try {
      final clientId = '${cfg.clientId}_${_uuid.v4().substring(0, 8)}';

      if (kIsWeb || cfg.useWebSocket) {
        // WebSocket connection for Flutter Web
        _client = MqttServerClient.withPort(
          'ws://${cfg.broker}',
          clientId,
          cfg.wsPort,
        );
        _client!.useWebSocket = true;
        _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      } else {
        // TCP connection for mobile/desktop
        _client = MqttServerClient.withPort(
          cfg.broker,
          clientId,
          cfg.tcpPort,
        );
      }

      _client!
        ..logging(on: false)
        ..keepAlivePeriod = cfg.keepAliveSeconds
        ..autoReconnect = cfg.autoReconnect
        ..onConnected = _onConnected
        ..onDisconnected = _onDisconnected
        ..onAutoReconnect = _onAutoReconnect
        ..onAutoReconnected = _onAutoReconnected
        ..onSubscribed = (topic) => debugPrint('MqttService: Subscribed to $topic');

      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(cfg.username, cfg.password)
          .withWillTopic('smarthome/app/status')
          .withWillMessage('offline')
          .withWillRetain()
          .withWillQos(MqttQos.atLeastOnce)
          .startClean();

      debugPrint('MqttService: Connecting to ${cfg.broker}...');

      await _client!.connect(cfg.username, cfg.password);

      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        _setConnectionState(AppMqttConnectionState.connected);
        _subscribeToTopics();
        _listenToMessages();
        return true;
      } else {
        _setConnectionState(AppMqttConnectionState.error);
        return false;
      }
    } catch (e) {
      debugPrint('MqttService: Connection failed: $e');
      _setConnectionState(AppMqttConnectionState.error);
      _scheduleReconnect();
      return false;
    }
  }

  /// Disconnect from the broker.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try {
      _client?.disconnect();
    } catch (_) {}
    _client = null;
    _setConnectionState(AppMqttConnectionState.disconnected);
  }

  /// Test connection to a broker without subscribing.
  Future<bool> testConnection(MqttConfig testConfig) async {
    try {
      final testClient = MqttServerClient.withPort(
        testConfig.useWebSocket ? 'ws://${testConfig.broker}' : testConfig.broker,
        'test_${_uuid.v4().substring(0, 8)}',
        testConfig.useWebSocket ? testConfig.wsPort : testConfig.tcpPort,
      );
      testClient
        ..useWebSocket = testConfig.useWebSocket
        ..keepAlivePeriod = 10
        ..connectionMessage = MqttConnectMessage()
            .authenticateAs(testConfig.username, testConfig.password)
            .startClean();

      await testClient.connect(testConfig.username, testConfig.password);
      final ok = testClient.connectionStatus?.state ==
          MqttConnectionState.connected;
      testClient.disconnect();
      return ok;
    } catch (e) {
      debugPrint('MqttService: Test connection failed: $e');
      return false;
    }
  }

  // ─── Subscriptions ────────────────────────────────────────────────────────

  void _subscribeToTopics() {
    for (final topic in MqttTopics.appSubscriptions) {
      _client?.subscribe(topic, MqttQos.atLeastOnce);
    }
    debugPrint('MqttService: Subscribed to ${MqttTopics.appSubscriptions.length} topics');
  }

  void _listenToMessages() {
    _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final msg in messages) {
        final topic = msg.topic;
        final payload = msg.payload as MqttPublishMessage;
        final data = MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );

        try {
          _processMessage(topic, data);
        } catch (e) {
          debugPrint('MqttService: Error processing [$topic]: $e');
        }
      }
    });
  }

  // ─── Message Processing ───────────────────────────────────────────────────

  void _processMessage(String topic, String data) {
    final json = jsonDecode(data) as Map<String, dynamic>;

    if (topic == MqttTopics.sensorData) {
      _processSensorData(json);
    } else if (topic == MqttTopics.deviceStatus) {
      _processDeviceStatus(json);
    } else if (topic == MqttTopics.alerts) {
      _processAlert(json);
    } else if (topic == MqttTopics.system) {
      _processSystemStatus(json);
    }
  }

  void _processSensorData(Map<String, dynamic> json) {
    final msg = MqttSensorMessage.fromJson(json);
    _lastSensorData = msg;
    _sensorHistory.add(msg);

    // Keep last 500 entries
    if (_sensorHistory.length > 500) {
      _sensorHistory.removeRange(0, _sensorHistory.length - 500);
    }

    // Convert to SensorData current readings
    _updateCurrentReadings(msg);

    _sensorController.add(msg);
    notifyListeners();
  }

  void _updateCurrentReadings(MqttSensorMessage msg) {
    final now = DateTime.now();
    final deviceId = msg.deviceId;

    void addReading(SensorType type, double? value, String unit,
        {double? min, double? max}) {
      if (value == null) return;
      _currentReadings[type.name] = SensorData(
        id: '${deviceId}_${type.name}',
        deviceId: deviceId,
        type: type,
        value: value,
        unit: unit,
        timestamp: now,
        minThreshold: min,
        maxThreshold: max,
      );
    }

    addReading(SensorType.temperature, msg.temperature, '°C', min: 10, max: 40);
    addReading(SensorType.humidity, msg.humidity, '%', min: 20, max: 80);
    addReading(SensorType.voltage, msg.voltage, 'V', min: 190, max: 250);
    addReading(SensorType.current, msg.current, 'A', min: 0, max: 15);
    addReading(SensorType.power, msg.power, 'W', min: 0, max: 3000);
    addReading(SensorType.waterLevel, msg.waterLevel, '%', min: 5, max: 95);
    addReading(SensorType.light, msg.lightLevel, 'lux', min: 0, max: 1000);
    addReading(SensorType.gas, msg.gasLevel, 'ppm', min: 0, max: 2000);
    if (msg.motionDetected != null) {
      addReading(SensorType.motion, msg.motionDetected! ? 1.0 : 0.0, '');
    }
  }

  void _processDeviceStatus(Map<String, dynamic> json) {
    final msg = MqttDeviceStatus.fromJson(json);
    _lastDeviceStatus = msg;

    // Convert device states to SmartDevice objects
    _updateLiveDevices(msg);

    _deviceStatusController.add(msg);
    notifyListeners();
  }

  void _updateLiveDevices(MqttDeviceStatus msg) {
    _liveDevices.clear();

    // Map ESP32 device names to DeviceType
    const deviceTypeMap = {
      'light': DeviceType.light,
      'fan': DeviceType.fan,
      'ac': DeviceType.ac,
      'pump': DeviceType.waterPump,
      'buzzer': DeviceType.buzzer,
      'relay1': DeviceType.plug,
      'relay2': DeviceType.plug,
      'relay3': DeviceType.plug,
      'relay4': DeviceType.plug,
    };

    msg.devices.forEach((name, state) {
      final type = deviceTypeMap[name] ?? DeviceType.plug;
      _liveDevices.add(SmartDevice(
        id: '${msg.deviceId}_$name',
        name: _formatDeviceName(name),
        room: 'Living Room', // Default room from ESP32 config
        type: type,
        isOnline: true,
        isOn: state.isOn,
        brightness: state.brightness,
        speed: state.speed,
        temperature: state.temperature,
      ));
    });
  }

  String _formatDeviceName(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');
  }

  void _processAlert(Map<String, dynamic> json) {
    final alert = MqttAlert.fromJson(json);
    _alerts.insert(0, alert);

    // Keep last 100 alerts
    if (_alerts.length > 100) {
      _alerts.removeRange(100, _alerts.length);
    }

    _alertController.add(alert);
    notifyListeners();
  }

  void _processSystemStatus(Map<String, dynamic> json) {
    _lastSystemStatus = MqttSystemStatus.fromJson(json);
    _systemStatusController.add(_lastSystemStatus!);
    notifyListeners();
  }

  // ─── Device Commands (App → ESP32) ────────────────────────────────────────

  /// Send a command to a device. E.g. ('light', 'on'), ('fan', 'off'), ('buzzer', 'beep')
  void sendCommand(String device, String action, {int? value, int? count, int? duration}) {
    if (!isConnected) {
      debugPrint('MqttService: Cannot send command, not connected');
      return;
    }

    final cmd = MqttDeviceCommand(
      device: device,
      action: action,
      value: value,
      count: count,
      duration: duration,
    );

    _publish(MqttTopics.deviceControl, cmd.toJson());
    debugPrint('MqttService: Command sent: $device → $action');
  }

  /// Toggle a device on/off.
  void toggleDevice(String device) => sendCommand(device, 'toggle');

  /// Turn a device on.
  void turnOn(String device) => sendCommand(device, 'on');

  /// Turn a device off.
  void turnOff(String device) => sendCommand(device, 'off');

  /// Set fan speed (0-255).
  void setFanSpeed(int speed) => sendCommand('fan', 'on', value: speed);

  /// Set light brightness (0-255).
  void setLightBrightness(int brightness) =>
      sendCommand('light', 'on', value: brightness);

  /// Buzz the buzzer.
  void buzz({int count = 1, int duration = 100}) =>
      sendCommand('buzzer', 'beep', count: count, duration: duration);

  /// Trigger alarm.
  void alarm() => sendCommand('buzzer', 'alarm');

  /// Turn all devices off.
  void allOff() => sendCommand('all', 'off');

  /// Restart ESP32 via OTA topic.
  void restartEsp32() {
    _publish(MqttTopics.ota, {'command': 'restart'});
  }

  /// Publish a JSON payload to a topic.
  void _publish(String topic, Map<String, dynamic> payload, {bool retain = false}) {
    if (_client == null || !isConnected) return;

    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(payload));

    _client!.publishMessage(
      topic,
      retain ? MqttQos.atLeastOnce : MqttQos.atMostOnce,
      builder.payload!,
      retain: retain,
    );
  }

  // ─── Reconnection ────────────────────────────────────────────────────────

  void _scheduleReconnect() {
    if (!_config.autoReconnect) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (_connectionState != AppMqttConnectionState.connected) {
        debugPrint('MqttService: Attempting reconnect...');
        connect();
      }
    });
  }

  void _onConnected() {
    debugPrint('MqttService: Connected to ${_config.broker}');
    _setConnectionState(AppMqttConnectionState.connected);

    // Publish online status
    _publish('smarthome/app/status', {
      'status': 'online',
      'client': _client?.clientIdentifier,
      'platform': kIsWeb ? 'web' : 'mobile',
      'timestamp': DateTime.now().toIso8601String(),
    }, retain: true);
  }

  void _onDisconnected() {
    debugPrint('MqttService: Disconnected');
    _setConnectionState(AppMqttConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onAutoReconnect() {
    debugPrint('MqttService: Auto-reconnecting...');
    _setConnectionState(AppMqttConnectionState.reconnecting);
  }

  void _onAutoReconnected() {
    debugPrint('MqttService: Auto-reconnected');
    _setConnectionState(AppMqttConnectionState.connected);
    _subscribeToTopics();
  }

  void _setConnectionState(AppMqttConnectionState state) {
    _connectionState = state;
    _connectionController.add(state);
    notifyListeners();
  }

  // ─── Data Access Helpers (for providers) ──────────────────────────────────

  /// Check if there is real data from MQTT.
  bool get hasLiveData =>
      _lastSensorData != null || _lastDeviceStatus != null;

  /// Get sensor reading by type.
  SensorData? getReading(SensorType type) => _currentReadings[type.name];

  /// Get all current readings as a list.
  List<SensorData> get readings => _currentReadings.values.toList();

  /// Clear stored data.
  void clearData() {
    _lastSensorData = null;
    _lastDeviceStatus = null;
    _lastSystemStatus = null;
    _alerts.clear();
    _sensorHistory.clear();
    _currentReadings.clear();
    _liveDevices.clear();
    notifyListeners();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    disconnect();
    _sensorController.close();
    _deviceStatusController.close();
    _alertController.close();
    _systemStatusController.close();
    _connectionController.close();
    super.dispose();
  }
}
