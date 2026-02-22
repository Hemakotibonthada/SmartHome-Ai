import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/models/user_model.dart';
import 'package:smart_home_ai/core/services/device_service.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DeviceService _deviceService = DeviceService();
  final AIService _aiService = AIService();
  Timer? _refreshTimer;

  Map<String, SensorData> _sensorData = {};
  List<AIInsight> _insights = [];
  Map<String, dynamic> _energyReport = {};
  bool _isLoading = true;

  Map<String, SensorData> get sensorData => _sensorData;
  List<AIInsight> get insights => _insights;
  Map<String, dynamic> get energyReport => _energyReport;
  bool get isLoading => _isLoading;

  // Quick stats
  int get activeDevices => 7;
  int get totalDevices => 12;
  double get energyToday => (_energyReport['dailyConsumption'] ?? 12.5).toDouble();
  int get alertCount => _insights.where((i) => i.priority == InsightPriority.high || i.priority == InsightPriority.critical).length;

  DashboardProvider() {
    loadData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
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

    _sensorData = _deviceService.getCurrentReadings();
    _insights = _aiService.analyzeData(_sensorData);
    _energyReport = _aiService.generateEnergyReport();

    _isLoading = false;
    notifyListeners();
  }

  void _refreshSensorData() {
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
