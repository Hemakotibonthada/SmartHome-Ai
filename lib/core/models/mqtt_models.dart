/// MQTT message and configuration models for Smart Home AI.
///
/// © 2026 Circuvent Technologies Pvt Ltd, Hyderabad

/// MQTT connection configuration.
class MqttConfig {
  final String broker;
  final int tcpPort;
  final int wsPort;
  final String username;
  final String password;
  final String clientId;
  final bool useWebSocket;
  final int keepAliveSeconds;
  final bool autoReconnect;

  const MqttConfig({
    this.broker = '192.168.1.100',
    this.tcpPort = 1883,
    this.wsPort = 8083,
    this.username = 'smarthome',
    this.password = 'smarthome_password',
    this.clientId = 'flutter_app',
    this.useWebSocket = false,
    this.keepAliveSeconds = 30,
    this.autoReconnect = true,
  });

  /// WebSocket URL for Flutter web.
  String get wsUrl => 'ws://$broker:$wsPort/mqtt';

  MqttConfig copyWith({
    String? broker,
    int? tcpPort,
    int? wsPort,
    String? username,
    String? password,
    String? clientId,
    bool? useWebSocket,
    int? keepAliveSeconds,
    bool? autoReconnect,
  }) {
    return MqttConfig(
      broker: broker ?? this.broker,
      tcpPort: tcpPort ?? this.tcpPort,
      wsPort: wsPort ?? this.wsPort,
      username: username ?? this.username,
      password: password ?? this.password,
      clientId: clientId ?? this.clientId,
      useWebSocket: useWebSocket ?? this.useWebSocket,
      keepAliveSeconds: keepAliveSeconds ?? this.keepAliveSeconds,
      autoReconnect: autoReconnect ?? this.autoReconnect,
    );
  }

  Map<String, dynamic> toJson() => {
        'broker': broker,
        'tcpPort': tcpPort,
        'wsPort': wsPort,
        'username': username,
        'password': password,
        'clientId': clientId,
        'useWebSocket': useWebSocket,
        'keepAliveSeconds': keepAliveSeconds,
        'autoReconnect': autoReconnect,
      };

  factory MqttConfig.fromJson(Map<String, dynamic> json) => MqttConfig(
        broker: json['broker'] ?? '192.168.1.100',
        tcpPort: json['tcpPort'] ?? 1883,
        wsPort: json['wsPort'] ?? 8083,
        username: json['username'] ?? 'smarthome',
        password: json['password'] ?? 'smarthome_password',
        clientId: json['clientId'] ?? 'flutter_app',
        useWebSocket: json['useWebSocket'] ?? false,
        keepAliveSeconds: json['keepAliveSeconds'] ?? 30,
        autoReconnect: json['autoReconnect'] ?? true,
      );
}

// ──────────────────────────────────────────────────────────────────────────────
// MQTT Topic Constants — must match ESP32 firmware topics
// ──────────────────────────────────────────────────────────────────────────────

class MqttTopics {
  static const String sensorData      = 'smarthome/sensors/data';
  static const String deviceStatus    = 'smarthome/devices/status';
  static const String deviceControl   = 'smarthome/devices/control';
  static const String deviceSet       = 'smarthome/devices/+/set';
  static const String alerts          = 'smarthome/alerts';
  static const String system          = 'smarthome/system';
  static const String ota             = 'smarthome/ota';

  /// Subscribe to all smarthome topics.
  static const List<String> allSubscriptions = [
    sensorData,
    deviceStatus,
    alerts,
    system,
    'smarthome/#', // catch-all for debugging
  ];

  /// Topics the app subscribes to.
  static const List<String> appSubscriptions = [
    sensorData,
    deviceStatus,
    alerts,
    system,
  ];

  /// Per-device set topic.
  static String deviceSetTopic(String deviceName) =>
      'smarthome/devices/$deviceName/set';
}

// ──────────────────────────────────────────────────────────────────────────────
// MQTT Connection State
// ──────────────────────────────────────────────────────────────────────────────

enum AppMqttConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

extension AppMqttConnectionStateExtension on AppMqttConnectionState {
  String get displayName {
    switch (this) {
      case AppMqttConnectionState.disconnected:  return 'Disconnected';
      case AppMqttConnectionState.connecting:    return 'Connecting...';
      case AppMqttConnectionState.connected:     return 'Connected';
      case AppMqttConnectionState.reconnecting:  return 'Reconnecting...';
      case AppMqttConnectionState.error:         return 'Error';
    }
  }

  bool get isConnected => this == AppMqttConnectionState.connected;
}

// ──────────────────────────────────────────────────────────────────────────────
// Parsed MQTT Messages
// ──────────────────────────────────────────────────────────────────────────────

/// Sensor telemetry received from ESP32.
class MqttSensorMessage {
  final String deviceId;
  final DateTime timestamp;
  final double? temperature;
  final double? humidity;
  final double? voltage;
  final double? current;
  final double? power;
  final double? energy;
  final double? powerFactor;
  final double? frequency;
  final double? waterLevel;
  final double? waterDistance;
  final double? waterVolume;
  final double? lightLevel;
  final double? gasLevel;
  final bool? motionDetected;

  MqttSensorMessage({
    required this.deviceId,
    required this.timestamp,
    this.temperature,
    this.humidity,
    this.voltage,
    this.current,
    this.power,
    this.energy,
    this.powerFactor,
    this.frequency,
    this.waterLevel,
    this.waterDistance,
    this.waterVolume,
    this.lightLevel,
    this.gasLevel,
    this.motionDetected,
  });

  factory MqttSensorMessage.fromJson(Map<String, dynamic> json) {
    final sensors = json['sensors'] as Map<String, dynamic>? ?? json;
    return MqttSensorMessage(
      deviceId: json['device_id'] ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      temperature: _extractValue(sensors, 'temperature'),
      humidity: _extractValue(sensors, 'humidity'),
      voltage: _extractValue(sensors, 'voltage'),
      current: _extractValue(sensors, 'current'),
      power: _extractValue(sensors, 'power'),
      energy: _extractValue(sensors, 'energy'),
      powerFactor: _extractValue(sensors, 'power_factor'),
      frequency: _extractValue(sensors, 'frequency'),
      waterLevel: _extractValue(sensors, 'water_level'),
      waterDistance: _extractValue(sensors, 'water', subKey: 'distance'),
      waterVolume: _extractValue(sensors, 'water', subKey: 'volume'),
      lightLevel: _extractValue(sensors, 'light'),
      gasLevel: _extractValue(sensors, 'gas'),
      motionDetected: sensors['motion']?['detected'] as bool?,
    );
  }

  static double? _extractValue(
    Map<String, dynamic> sensors,
    String key, {
    String subKey = 'value',
  }) {
    final val = sensors[key];
    if (val is num) return val.toDouble();
    if (val is Map) return (val[subKey] as num?)?.toDouble();
    return null;
  }
}

/// Device status received from ESP32.
class MqttDeviceStatus {
  final String deviceId;
  final Map<String, DeviceState> devices;
  final DateTime timestamp;

  MqttDeviceStatus({
    required this.deviceId,
    required this.devices,
    required this.timestamp,
  });

  factory MqttDeviceStatus.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as Map<String, dynamic>? ?? {};
    final devices = <String, DeviceState>{};
    devicesJson.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        devices[key] = DeviceState.fromJson(key, value);
      }
    });
    return MqttDeviceStatus(
      deviceId: json['device_id'] ?? 'unknown',
      devices: devices,
      timestamp: DateTime.now(),
    );
  }
}

/// Individual device state from MQTT.
class DeviceState {
  final String name;
  final bool isOn;
  final double? speed;
  final double? brightness;
  final double? temperature;
  final String? mode;

  DeviceState({
    required this.name,
    required this.isOn,
    this.speed,
    this.brightness,
    this.temperature,
    this.mode,
  });

  factory DeviceState.fromJson(String name, Map<String, dynamic> json) {
    final stateStr = (json['state'] ?? '').toString().toLowerCase();
    return DeviceState(
      name: name,
      isOn: stateStr == 'on' || stateStr == '1' || stateStr == 'true',
      speed: (json['speed'] as num?)?.toDouble(),
      brightness: (json['brightness'] as num?)?.toDouble() ??
          (json['level'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble() ??
          (json['temp'] as num?)?.toDouble(),
      mode: json['mode'] as String?,
    );
  }
}

/// Alert received from ESP32.
class MqttAlert {
  final String deviceId;
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  MqttAlert({
    required this.deviceId,
    required this.type,
    required this.message,
    this.severity = 'warning',
    required this.timestamp,
    this.data,
  });

  factory MqttAlert.fromJson(Map<String, dynamic> json) => MqttAlert(
        deviceId: json['device_id'] ?? 'unknown',
        type: json['type'] ?? 'unknown',
        message: json['message'] ?? '',
        severity: json['severity'] ?? 'warning',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        data: json['data'] as Map<String, dynamic>?,
      );
}

/// System heartbeat from ESP32.
class MqttSystemStatus {
  final String deviceId;
  final String status;
  final int uptimeSeconds;
  final int rssi;
  final int freeHeap;
  final String? ip;
  final String? firmware;
  final int reconnects;
  final DateTime timestamp;

  MqttSystemStatus({
    required this.deviceId,
    required this.status,
    required this.uptimeSeconds,
    required this.rssi,
    required this.freeHeap,
    this.ip,
    this.firmware,
    this.reconnects = 0,
    required this.timestamp,
  });

  factory MqttSystemStatus.fromJson(Map<String, dynamic> json) =>
      MqttSystemStatus(
        deviceId: json['device_id'] ?? 'unknown',
        status: json['status'] ?? 'unknown',
        uptimeSeconds: json['uptime'] ?? 0,
        rssi: json['rssi'] ?? 0,
        freeHeap: json['free_heap'] ?? 0,
        ip: json['ip'] as String?,
        firmware: json['firmware'] as String?,
        reconnects: json['reconnects'] ?? 0,
        timestamp: DateTime.now(),
      );

  String get uptimeFormatted {
    final h = uptimeSeconds ~/ 3600;
    final m = (uptimeSeconds % 3600) ~/ 60;
    final s = uptimeSeconds % 60;
    return '${h}h ${m}m ${s}s';
  }

  String get signalStrength {
    if (rssi > -50) return 'Excellent';
    if (rssi > -60) return 'Good';
    if (rssi > -70) return 'Fair';
    return 'Poor';
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Device Command — sent from app to ESP32
// ──────────────────────────────────────────────────────────────────────────────

class MqttDeviceCommand {
  final String device;
  final String action;
  final int? value;
  final int? count;
  final int? duration;

  MqttDeviceCommand({
    required this.device,
    required this.action,
    this.value,
    this.count,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'device': device,
      'action': action,
    };
    if (value != null) json['value'] = value;
    if (count != null) json['count'] = count;
    if (duration != null) json['duration'] = duration;
    return json;
  }
}
