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
  bool _demoMode = false;

  Map<String, dynamic> get energyReport => _energyReport;
  List<AIInsight> get insights => _insights;
  List<Map<String, dynamic>> get predictions => _predictions;
  List<Map<String, dynamic>> get anomalies => _anomalies;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _demoMode;

  /// Whether there is any data to show
  bool get hasData => _energyReport.isNotEmpty || _insights.isNotEmpty;

  AnalyticsProvider();

  /// Called when demo mode changes.
  void setDemoMode(bool value) {
    _demoMode = value;
    _aiService.setDemoMode(value);
    _deviceService.setDemoMode(value);
    if (value) {
      loadAnalytics();
    } else {
      _energyReport = {};
      _insights = [];
      _predictions = [];
      _anomalies = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (_demoMode) {
      final sensorData = _deviceService.getCurrentReadings();
      _energyReport = _aiService.generateEnergyReport();
      _insights = _aiService.analyzeData(sensorData);

      // Generate predictions
      final tempHistory = _deviceService.getHistoricalData(SensorType.temperature, const Duration(hours: 24));
      _predictions = _aiService.predictTrend(tempHistory, 6);

      // Detect anomalies
      _anomalies = _aiService.detectAnomalies(tempHistory);
    } else {
      _energyReport = {};
      _insights = [];
      _predictions = [];
      _anomalies = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }
}
