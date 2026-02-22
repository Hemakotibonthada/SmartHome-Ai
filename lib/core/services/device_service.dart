import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/models/device_model.dart';

class DeviceService {
  final Random _random = Random();
  final StreamController<Map<String, dynamic>> _dataController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  Timer? _simulationTimer;

  // Simulated current values
  double _temperature = 25.0;
  double _humidity = 55.0;
  double _voltage = 220.0;
  double _current = 2.5;
  double _waterLevel = 65.0;
  double _power = 550.0;

  void startSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _updateSimulatedData();
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  void _updateSimulatedData() {
    // Simulate realistic sensor value changes
    _temperature += (_random.nextDouble() - 0.5) * 0.5;
    _temperature = _temperature.clamp(15.0, 45.0);

    _humidity += (_random.nextDouble() - 0.5) * 1.0;
    _humidity = _humidity.clamp(20.0, 95.0);

    _voltage += (_random.nextDouble() - 0.5) * 2.0;
    _voltage = _voltage.clamp(200.0, 240.0);

    _current += (_random.nextDouble() - 0.5) * 0.3;
    _current = _current.clamp(0.5, 15.0);

    _waterLevel += (_random.nextDouble() - 0.5) * 0.5;
    _waterLevel = _waterLevel.clamp(0.0, 100.0);

    _power = _voltage * _current;

    final data = {
      'temperature': _temperature,
      'humidity': _humidity,
      'voltage': _voltage,
      'current': _current,
      'waterLevel': _waterLevel,
      'power': _power,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _dataController.add(data);
  }

  /// Get current sensor readings
  Map<String, SensorData> getCurrentReadings() {
    final now = DateTime.now();
    return {
      'temperature': SensorData(
        id: 'temp_1',
        deviceId: 'esp32_1',
        type: SensorType.temperature,
        value: _temperature,
        unit: '°C',
        timestamp: now,
        minThreshold: 18.0,
        maxThreshold: 35.0,
      ),
      'humidity': SensorData(
        id: 'hum_1',
        deviceId: 'esp32_1',
        type: SensorType.humidity,
        value: _humidity,
        unit: '%',
        timestamp: now,
        minThreshold: 30.0,
        maxThreshold: 80.0,
      ),
      'voltage': SensorData(
        id: 'volt_1',
        deviceId: 'esp32_1',
        type: SensorType.voltage,
        value: _voltage,
        unit: 'V',
        timestamp: now,
        minThreshold: 200.0,
        maxThreshold: 240.0,
      ),
      'current': SensorData(
        id: 'curr_1',
        deviceId: 'esp32_1',
        type: SensorType.current,
        value: _current,
        unit: 'A',
        timestamp: now,
        minThreshold: 0.0,
        maxThreshold: 15.0,
      ),
      'waterLevel': SensorData(
        id: 'water_1',
        deviceId: 'esp32_1',
        type: SensorType.waterLevel,
        value: _waterLevel,
        unit: '%',
        timestamp: now,
        minThreshold: 10.0,
        maxThreshold: 95.0,
      ),
      'power': SensorData(
        id: 'power_1',
        deviceId: 'esp32_1',
        type: SensorType.power,
        value: _power,
        unit: 'W',
        timestamp: now,
        minThreshold: 0.0,
        maxThreshold: 3500.0,
      ),
    };
  }

  /// Generate historical sensor data for charts
  List<SensorData> getHistoricalData(SensorType type, Duration duration) {
    final now = DateTime.now();
    final dataPoints = <SensorData>[];
    final interval = duration.inMinutes > 1440 ? 60 : 5; // hourly or 5-min intervals

    double baseValue;
    String unit;
    double variance;

    switch (type) {
      case SensorType.temperature:
        baseValue = 25.0;
        unit = '°C';
        variance = 3.0;
        break;
      case SensorType.humidity:
        baseValue = 55.0;
        unit = '%';
        variance = 10.0;
        break;
      case SensorType.voltage:
        baseValue = 220.0;
        unit = 'V';
        variance = 10.0;
        break;
      case SensorType.current:
        baseValue = 3.0;
        unit = 'A';
        variance = 2.0;
        break;
      case SensorType.waterLevel:
        baseValue = 65.0;
        unit = '%';
        variance = 5.0;
        break;
      case SensorType.power:
        baseValue = 660.0;
        unit = 'W';
        variance = 200.0;
        break;
      default:
        baseValue = 50.0;
        unit = '';
        variance = 10.0;
    }

    for (int i = duration.inMinutes; i >= 0; i -= interval) {
      final time = now.subtract(Duration(minutes: i));
      final hourFactor = sin(time.hour * pi / 12); // Daily cycle
      final value = baseValue + hourFactor * variance + (_random.nextDouble() - 0.5) * variance * 0.3;

      dataPoints.add(SensorData(
        id: '${type.name}_hist_$i',
        deviceId: 'esp32_1',
        type: type,
        value: value,
        unit: unit,
        timestamp: time,
      ));
    }

    return dataPoints;
  }

  /// Get all smart devices
  List<SmartDevice> getDevices() {
    return [
      SmartDevice(
        id: 'dev_1', name: 'Living Room Light', room: 'Living Room',
        type: DeviceType.light, isOn: true, brightness: 75,
      ),
      SmartDevice(
        id: 'dev_2', name: 'Bedroom Fan', room: 'Bedroom',
        type: DeviceType.fan, isOn: true, speed: 3,
      ),
      SmartDevice(
        id: 'dev_3', name: 'Hall AC', room: 'Living Room',
        type: DeviceType.ac, isOn: false, temperature: 24,
      ),
      SmartDevice(
        id: 'dev_4', name: 'Kitchen Light', room: 'Kitchen',
        type: DeviceType.light, isOn: true, brightness: 100,
      ),
      SmartDevice(
        id: 'dev_5', name: 'Smart TV', room: 'Living Room',
        type: DeviceType.tv, isOn: false,
      ),
      SmartDevice(
        id: 'dev_6', name: 'Front Door Lock', room: 'Entrance',
        type: DeviceType.lock, isOn: true,
      ),
      SmartDevice(
        id: 'dev_7', name: 'Security Camera', room: 'Garden',
        type: DeviceType.camera, isOn: true,
      ),
      SmartDevice(
        id: 'dev_8', name: 'Water Pump', room: 'Utility',
        type: DeviceType.waterPump, isOn: false,
      ),
      SmartDevice(
        id: 'dev_9', name: 'Alert Buzzer', room: 'Utility',
        type: DeviceType.buzzer, isOn: false,
      ),
      SmartDevice(
        id: 'dev_10', name: 'Bathroom Geyser', room: 'Bathroom',
        type: DeviceType.geyser, isOn: false, temperature: 45,
      ),
      SmartDevice(
        id: 'dev_11', name: 'Smart Plug 1', room: 'Living Room',
        type: DeviceType.plug, isOn: true,
      ),
      SmartDevice(
        id: 'dev_12', name: 'Bedroom Curtain', room: 'Bedroom',
        type: DeviceType.curtain, isOn: false,
      ),
    ];
  }

  /// Get rooms
  List<Room> getRooms() {
    return [
      Room(
        id: 'room_1', name: 'Living Room',
        icon: Icons.living, color: const Color(0xFF6C63FF),
        deviceIds: ['dev_1', 'dev_3', 'dev_5', 'dev_11'],
      ),
      Room(
        id: 'room_2', name: 'Bedroom',
        icon: Icons.bed, color: const Color(0xFF00D9FF),
        deviceIds: ['dev_2', 'dev_12'],
      ),
      Room(
        id: 'room_3', name: 'Kitchen',
        icon: Icons.kitchen, color: const Color(0xFFFF6584),
        deviceIds: ['dev_4'],
      ),
      Room(
        id: 'room_4', name: 'Bathroom',
        icon: Icons.bathtub, color: const Color(0xFF4FACFE),
        deviceIds: ['dev_10'],
      ),
      Room(
        id: 'room_5', name: 'Garden',
        icon: Icons.yard, color: const Color(0xFF00C48C),
        deviceIds: ['dev_7'],
      ),
      Room(
        id: 'room_6', name: 'Entrance',
        icon: Icons.door_front_door, color: const Color(0xFFFFAA00),
        deviceIds: ['dev_6'],
      ),
      Room(
        id: 'room_7', name: 'Utility',
        icon: Icons.build, color: const Color(0xFF667EEA),
        deviceIds: ['dev_8', 'dev_9'],
      ),
    ];
  }

  void dispose() {
    _simulationTimer?.cancel();
    _dataController.close();
  }
}
