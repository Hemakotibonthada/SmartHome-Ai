import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/models/user_model.dart';
import 'package:smart_home_ai/core/services/device_service.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  final AIService _aiService = AIService();
  Timer? _refreshTimer;

  Map<String, SensorData> _sensorData = {};
  List<AIInsight> _insights = [];
  Map<String, dynamic> _energyReport = {};
  bool _isLoading = true;
  bool _demoMode = false;

  Map<String, SensorData> get sensorData => _sensorData;
  List<AIInsight> get insights => _insights;
  Map<String, dynamic> get energyReport => _energyReport;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _demoMode;

  /// Whether there is any data to show (in live mode this may be false)
  bool get hasData => _sensorData.isNotEmpty;

  // Quick stats
  int get activeDevices => _demoMode ? 7 : 0;
  int get totalDevices => _demoMode ? 12 : 0;
  double get energyToday => (_energyReport['dailyConsumption'] ?? (_demoMode ? 12.5 : 0.0)).toDouble();
  int get alertCount => _insights.where((i) => i.priority == InsightPriority.high || i.priority == InsightPriority.critical).length;

  DashboardProvider();

  /// Called when demo mode changes — re-initializes data accordingly.
  void setDemoMode(bool value) {
    _demoMode = value;
    _deviceService.setDemoMode(value);
    _aiService.setDemoMode(value);
    if (value) {
      loadData();
      _startAutoRefresh();
    } else {
      _refreshTimer?.cancel();
      _deviceService.stopSimulation();
      _sensorData = {};
      _insights = [];
      _energyReport = {};
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startAutoRefresh() {
    if (!_demoMode) return;
    _refreshTimer?.cancel();
    _deviceService.startSimulation();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshSensorData();
    });
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (_demoMode) {
      _sensorData = _deviceService.getCurrentReadings();
      _insights = _aiService.analyzeData(_sensorData);
      _energyReport = _aiService.generateEnergyReport();
    } else {
      // Live mode: attempt real data (currently empty)
      _sensorData = {};
      _insights = [];
      _energyReport = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  void _refreshSensorData() {
    if (!_demoMode) return;
    _sensorData = _deviceService.getCurrentReadings();
    _insights = _aiService.analyzeData(_sensorData);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _deviceService.stopSimulation();
    super.dispose();
  }
}
