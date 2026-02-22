import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/services/device_service.dart';

class SensorProvider extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  Timer? _refreshTimer;

  Map<String, SensorData> _currentReadings = {};
  Map<SensorType, List<SensorData>> _historicalData = {};
  SensorType _selectedSensor = SensorType.temperature;
  String _selectedTimeRange = '24h';
  bool _isLoading = true;

  Map<String, SensorData> get currentReadings => _currentReadings;
  Map<SensorType, List<SensorData>> get historicalData => _historicalData;
  SensorType get selectedSensor => _selectedSensor;
  String get selectedTimeRange => _selectedTimeRange;
  bool get isLoading => _isLoading;

  List<SensorData> get currentSensorHistory =>
      _historicalData[_selectedSensor] ?? [];

  SensorProvider() {
    loadSensorData();
    _startMonitoring();
  }

  void _startMonitoring() {
    _deviceService.startSimulation();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _currentReadings = _deviceService.getCurrentReadings();
      notifyListeners();
    });
  }

  Future<void> loadSensorData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _currentReadings = _deviceService.getCurrentReadings();

    // Load historical data for all sensor types
    final duration = _getTimeRangeDuration();
    for (final type in SensorType.values) {
      _historicalData[type] = _deviceService.getHistoricalData(type, duration);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedSensor(SensorType type) {
    _selectedSensor = type;
    notifyListeners();
  }

  void setTimeRange(String range) {
    _selectedTimeRange = range;
    final duration = _getTimeRangeDuration();
    for (final type in SensorType.values) {
      _historicalData[type] = _deviceService.getHistoricalData(type, duration);
    }
    notifyListeners();
  }

  Duration _getTimeRangeDuration() {
    switch (_selectedTimeRange) {
      case '1h':
        return const Duration(hours: 1);
      case '6h':
        return const Duration(hours: 6);
      case '24h':
        return const Duration(hours: 24);
      case '7d':
        return const Duration(days: 7);
      case '30d':
        return const Duration(days: 30);
      default:
        return const Duration(hours: 24);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _deviceService.stopSimulation();
    super.dispose();
  }
}
