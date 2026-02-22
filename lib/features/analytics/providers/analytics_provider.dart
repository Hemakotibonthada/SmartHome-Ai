import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/models/user_model.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';
import 'package:smart_home_ai/core/services/device_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final DeviceService _deviceService = DeviceService();

  Map<String, dynamic> _energyReport = {};
  List<AIInsight> _insights = [];
  List<Map<String, dynamic>> _predictions = [];
  List<Map<String, dynamic>> _anomalies = [];
  String _selectedPeriod = 'Week';
  bool _isLoading = true;

  Map<String, dynamic> get energyReport => _energyReport;
  List<AIInsight> get insights => _insights;
  List<Map<String, dynamic>> get predictions => _predictions;
  List<Map<String, dynamic>> get anomalies => _anomalies;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;

  AnalyticsProvider() {
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final sensorData = _deviceService.getCurrentReadings();
    _energyReport = _aiService.generateEnergyReport();
    _insights = _aiService.analyzeData(sensorData);

    // Generate predictions
    final tempHistory = _deviceService.getHistoricalData(SensorType.temperature, const Duration(hours: 24));
    _predictions = _aiService.predictTrend(tempHistory, 6);

    // Detect anomalies
    _anomalies = _aiService.detectAnomalies(tempHistory);

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
