import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
//  DATA  MODELS
// ═══════════════════════════════════════════════════════════════════

enum LogLevel { info, warning, error, critical }

class SystemLog {
  final String id;
  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final String source;
  SystemLog({required this.id, required this.message, required this.level, required this.timestamp, this.source = 'System'});
}

class UserActivity {
  final String user;
  final String action;
  final DateTime timestamp;
  UserActivity({required this.user, required this.action, required this.timestamp});
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime lastLogin;
  final DateTime createdAt;
  final String avatarColor;
  final int devicesOwned;
  final int actionsToday;
  AdminUser({required this.id, required this.name, required this.email, required this.role, required this.status, required this.lastLogin, required this.createdAt, required this.avatarColor, this.devicesOwned = 0, this.actionsToday = 0});
}

class AIModelInfo {
  final String id;
  final String name;
  final String type;
  final String status;
  final double accuracy;
  final double loss;
  final int epochsCurrent;
  final int epochsTotal;
  final double trainingProgress;
  final DateTime lastTrained;
  final String datasetSize;
  final String latency;
  final double f1Score;
  final double precision;
  final double recall;
  final List<double> accuracyHistory;
  final List<double> lossHistory;
  final List<double> valAccuracyHistory;
  final List<double> valLossHistory;
  final String description;
  final int inferenceCount;
  final String framework;
  final String modelSize;

  AIModelInfo({
    required this.id, required this.name, required this.type, required this.status,
    required this.accuracy, required this.loss, required this.epochsCurrent,
    required this.epochsTotal, required this.trainingProgress, required this.lastTrained,
    required this.datasetSize, required this.latency, required this.f1Score,
    required this.precision, required this.recall, required this.accuracyHistory,
    required this.lossHistory, required this.valAccuracyHistory, required this.valLossHistory,
    required this.description, required this.inferenceCount, required this.framework,
    required this.modelSize,
  });

  Color get statusColor {
    switch (status) {
      case 'deployed': return const Color(0xFF00C48C);
      case 'training': return const Color(0xFF6C63FF);
      case 'queued': return const Color(0xFFFFAA00);
      case 'failed': return const Color(0xFFFF4757);
      default: return const Color(0xFF888888);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'classification': return Icons.category;
      case 'regression': return Icons.trending_up;
      case 'anomaly': return Icons.warning_amber;
      case 'recommendation': return Icons.recommend;
      case 'nlp': return Icons.chat;
      case 'forecasting': return Icons.auto_graph;
      default: return Icons.psychology;
    }
  }
}

class TrainingJob {
  final String id;
  final String modelName;
  final String status;
  final double progress;
  final int currentEpoch;
  final int totalEpochs;
  final String duration;
  final String gpu;
  final double gpuUtilization;
  final double memoryUsed;
  final DateTime startedAt;
  TrainingJob({required this.id, required this.modelName, required this.status, required this.progress, required this.currentEpoch, required this.totalEpochs, required this.duration, required this.gpu, required this.gpuUtilization, required this.memoryUsed, required this.startedAt});
}

class DeviceNode {
  final String id;
  final String name;
  final String type;
  final String status;
  final String ipAddress;
  final String firmware;
  final double temperature;
  final double uptime;
  final int dataPoints;
  final DateTime lastSeen;
  DeviceNode({required this.id, required this.name, required this.type, required this.status, required this.ipAddress, required this.firmware, required this.temperature, required this.uptime, required this.dataPoints, required this.lastSeen});
}

class APIEndpoint {
  final String path;
  final String method;
  final int calls24h;
  final double avgLatency;
  final double errorRate;
  final String status;
  APIEndpoint({required this.path, required this.method, required this.calls24h, required this.avgLatency, required this.errorRate, required this.status});
}

class BackupRecord {
  final String id;
  final String type;
  final String size;
  final DateTime timestamp;
  final String status;
  final String duration;
  BackupRecord({required this.id, required this.type, required this.size, required this.timestamp, required this.status, required this.duration});
}

class SecurityEvent {
  final String id;
  final String type;
  final String description;
  final String severity;
  final String source;
  final DateTime timestamp;
  SecurityEvent({required this.id, required this.type, required this.description, required this.severity, required this.source, required this.timestamp});
}

// ═══════════════════════════════════════════════════════════════════
//  ADMIN  PROVIDER
// ═══════════════════════════════════════════════════════════════════

class AdminProvider extends ChangeNotifier {
  bool _isLoading = true;
  final Random _random = Random();
  Timer? _updateTimer;

  int _totalUsers = 0;
  int _activeDevices = 0;
  int _totalDevices = 0;
  int _alerts = 0;
  double _uptime = 0;
  double _cpuUsage = 0;
  double _memoryUsage = 0;
  double _networkTraffic = 0;
  double _diskUsage = 0;
  int _apiCalls24h = 0;
  int _mqttMessages24h = 0;
  double _avgResponseTime = 0;

  List<SystemLog> _systemLogs = [];
  List<UserActivity> _userActivities = [];
  List<AdminUser> _users = [];
  List<AIModelInfo> _aiModels = [];
  List<TrainingJob> _trainingJobs = [];
  List<DeviceNode> _deviceNodes = [];
  List<APIEndpoint> _apiEndpoints = [];
  List<BackupRecord> _backups = [];
  List<SecurityEvent> _securityEvents = [];

  List<double> _cpuHistory = [];
  List<double> _memoryHistory = [];
  List<double> _networkHistory = [];
  List<double> _requestsPerMinute = [];

  // ── Getters ──
  bool get isLoading => _isLoading;
  int get totalUsers => _totalUsers;
  int get activeDevices => _activeDevices;
  int get totalDevices => _totalDevices;
  int get alerts => _alerts;
  double get uptime => _uptime;
  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  double get networkTraffic => _networkTraffic;
  double get diskUsage => _diskUsage;
  int get apiCalls24h => _apiCalls24h;
  int get mqttMessages24h => _mqttMessages24h;
  double get avgResponseTime => _avgResponseTime;

  List<SystemLog> get systemLogs => _systemLogs;
  List<UserActivity> get userActivities => _userActivities;
  List<AdminUser> get users => _users;
  List<AIModelInfo> get aiModels => _aiModels;
  List<TrainingJob> get trainingJobs => _trainingJobs;
  List<DeviceNode> get deviceNodes => _deviceNodes;
  List<APIEndpoint> get apiEndpoints => _apiEndpoints;
  List<BackupRecord> get backups => _backups;
  List<SecurityEvent> get securityEvents => _securityEvents;

  List<double> get cpuHistory => _cpuHistory;
  List<double> get memoryHistory => _memoryHistory;
  List<double> get networkHistory => _networkHistory;
  List<double> get requestsPerMinute => _requestsPerMinute;

  AdminProvider() {
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _totalUsers = 24;
    _activeDevices = 18;
    _totalDevices = 25;
    _alerts = 3;
    _uptime = 99.7;
    _cpuUsage = 35 + _random.nextDouble() * 30;
    _memoryUsage = 45 + _random.nextDouble() * 25;
    _networkTraffic = 12.5 + _random.nextDouble() * 10;
    _diskUsage = 58 + _random.nextDouble() * 12;
    _apiCalls24h = 14520 + _random.nextInt(3000);
    _mqttMessages24h = 89400 + _random.nextInt(10000);
    _avgResponseTime = 42 + _random.nextDouble() * 30;

    _cpuHistory = List.generate(30, (_) => 30 + _random.nextDouble() * 40);
    _memoryHistory = List.generate(30, (_) => 40 + _random.nextDouble() * 30);
    _networkHistory = List.generate(30, (_) => 5 + _random.nextDouble() * 20);
    _requestsPerMinute = List.generate(30, (_) => 50 + _random.nextDouble() * 150);

    _systemLogs = _generateSystemLogs();
    _userActivities = _generateUserActivities();
    _users = _generateUsers();
    _aiModels = _generateAIModels();
    _trainingJobs = _generateTrainingJobs();
    _deviceNodes = _generateDeviceNodes();
    _apiEndpoints = _generateAPIEndpoints();
    _backups = _generateBackups();
    _securityEvents = _generateSecurityEvents();

    _isLoading = false;
    notifyListeners();

    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateLiveMetrics());
  }

  void _updateLiveMetrics() {
    _cpuUsage = (_cpuUsage + (_random.nextDouble() - 0.5) * 8).clamp(10, 95);
    _memoryUsage = (_memoryUsage + (_random.nextDouble() - 0.5) * 4).clamp(30, 90);
    _networkTraffic = (_networkTraffic + (_random.nextDouble() - 0.5) * 3).clamp(2, 40);

    _cpuHistory = [..._cpuHistory.skip(1), _cpuUsage];
    _memoryHistory = [..._memoryHistory.skip(1), _memoryUsage];
    _networkHistory = [..._networkHistory.skip(1), _networkTraffic];
    _requestsPerMinute = [..._requestsPerMinute.skip(1), 50 + _random.nextDouble() * 150];

    for (int i = 0; i < _trainingJobs.length; i++) {
      final j = _trainingJobs[i];
      if (j.status == 'running' && j.progress < 1.0) {
        final newProg = (j.progress + 0.02 + _random.nextDouble() * 0.03).clamp(0.0, 1.0);
        final newEpoch = (newProg * j.totalEpochs).round().clamp(0, j.totalEpochs);
        _trainingJobs[i] = TrainingJob(
          id: j.id, modelName: j.modelName,
          status: newProg >= 1.0 ? 'completed' : 'running',
          progress: newProg, currentEpoch: newEpoch, totalEpochs: j.totalEpochs,
          duration: j.duration, gpu: j.gpu,
          gpuUtilization: 70 + _random.nextDouble() * 25,
          memoryUsed: j.memoryUsed, startedAt: j.startedAt,
        );
      }
    }

    notifyListeners();
  }

  // ═══════════════ DATA GENERATORS ═══════════════

  List<SystemLog> _generateSystemLogs() => [
    SystemLog(id: '1', message: 'ESP32-Node1 connected successfully', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(minutes: 2)), source: 'ESP32-Node1'),
    SystemLog(id: '2', message: 'Temperature sensor calibration complete', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(minutes: 5)), source: 'ESP32-Node1'),
    SystemLog(id: '3', message: 'High voltage detected: 248V on Phase R', level: LogLevel.warning, timestamp: DateTime.now().subtract(const Duration(minutes: 12)), source: 'ESP32-Node2'),
    SystemLog(id: '4', message: 'MQTT broker connection timeout — retrying in 5s', level: LogLevel.error, timestamp: DateTime.now().subtract(const Duration(minutes: 20)), source: 'MQTT-Broker'),
    SystemLog(id: '5', message: 'Anomaly detection model retrained — accuracy 96.2%', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(minutes: 25)), source: 'AI-Engine'),
    SystemLog(id: '6', message: 'Rate limit exceeded for IP 192.168.1.105', level: LogLevel.warning, timestamp: DateTime.now().subtract(const Duration(minutes: 35)), source: 'API-Gateway'),
    SystemLog(id: '7', message: 'Firmware update available for Node3 (v2.1.4)', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(minutes: 40)), source: 'System'),
    SystemLog(id: '8', message: 'Water level sensor reading anomaly detected', level: LogLevel.warning, timestamp: DateTime.now().subtract(const Duration(hours: 1)), source: 'ESP32-Node3'),
    SystemLog(id: '9', message: 'Auto-backup completed — 245 MB compressed', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(hours: 2)), source: 'Backup-Service'),
    SystemLog(id: '10', message: 'Failed authentication attempt from 192.168.1.105', level: LogLevel.error, timestamp: DateTime.now().subtract(const Duration(hours: 3)), source: 'Auth-Service'),
    SystemLog(id: '11', message: 'Critical: Database connection pool exhausted', level: LogLevel.critical, timestamp: DateTime.now().subtract(const Duration(hours: 4)), source: 'Database'),
    SystemLog(id: '12', message: 'AI prediction pipeline latency spike: 450ms', level: LogLevel.warning, timestamp: DateTime.now().subtract(const Duration(hours: 5)), source: 'AI-Engine'),
    SystemLog(id: '13', message: 'Motion detected — Garden camera triggered', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(hours: 6)), source: 'ESP32-Node4'),
    SystemLog(id: '14', message: 'SSL certificate renewal successful', level: LogLevel.info, timestamp: DateTime.now().subtract(const Duration(hours: 8)), source: 'API-Gateway'),
    SystemLog(id: '15', message: 'ESP32-Node5 went offline — last seen 8h ago', level: LogLevel.error, timestamp: DateTime.now().subtract(const Duration(hours: 8)), source: 'ESP32-Node5'),
  ];

  List<UserActivity> _generateUserActivities() => [
    UserActivity(user: 'Harsha B', action: 'Deployed new anomaly model v3.2', timestamp: DateTime.now().subtract(const Duration(minutes: 3))),
    UserActivity(user: 'Admin', action: 'Updated firmware on ESP32-Node2', timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
    UserActivity(user: 'Jane Smith', action: 'Modified bedroom light schedule', timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
    UserActivity(user: 'John Doe', action: 'Turned on Living Room AC', timestamp: DateTime.now().subtract(const Duration(minutes: 25))),
    UserActivity(user: 'Harsha B', action: 'Started retraining energy model', timestamp: DateTime.now().subtract(const Duration(minutes: 40))),
    UserActivity(user: 'Jane Smith', action: 'Set thermostat to 24°C', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
    UserActivity(user: 'Guest User', action: 'Checked water level status', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    UserActivity(user: 'Admin', action: 'Restarted MQTT service', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    UserActivity(user: 'John Doe', action: 'Enabled security buzzer', timestamp: DateTime.now().subtract(const Duration(hours: 8))),
    UserActivity(user: 'Harsha B', action: 'Reviewed model training metrics', timestamp: DateTime.now().subtract(const Duration(hours: 12))),
  ];

  List<AdminUser> _generateUsers() {
    final colors = ['FF6C63FF', 'FF00D9FF', 'FFFF6584', 'FF00C48C', 'FFFFAA00', 'FF9C27B0', 'FF2196F3', 'FFFF9800'];
    return [
      AdminUser(id: '1', name: 'Harsha Bonthada', email: 'harsha@circuvent.com', role: 'admin', status: 'active', lastLogin: DateTime.now().subtract(const Duration(minutes: 5)), createdAt: DateTime.now().subtract(const Duration(days: 365)), avatarColor: colors[0], devicesOwned: 25, actionsToday: 42),
      AdminUser(id: '2', name: 'Jane Smith', email: 'jane@circuvent.com', role: 'editor', status: 'active', lastLogin: DateTime.now().subtract(const Duration(hours: 1)), createdAt: DateTime.now().subtract(const Duration(days: 280)), avatarColor: colors[1], devicesOwned: 12, actionsToday: 18),
      AdminUser(id: '3', name: 'John Doe', email: 'john@circuvent.com', role: 'viewer', status: 'active', lastLogin: DateTime.now().subtract(const Duration(hours: 3)), createdAt: DateTime.now().subtract(const Duration(days: 200)), avatarColor: colors[2], devicesOwned: 8, actionsToday: 7),
      AdminUser(id: '4', name: 'Alice Johnson', email: 'alice@circuvent.com', role: 'editor', status: 'active', lastLogin: DateTime.now().subtract(const Duration(hours: 6)), createdAt: DateTime.now().subtract(const Duration(days: 150)), avatarColor: colors[3], devicesOwned: 15, actionsToday: 23),
      AdminUser(id: '5', name: 'Bob Wilson', email: 'bob@circuvent.com', role: 'viewer', status: 'suspended', lastLogin: DateTime.now().subtract(const Duration(days: 5)), createdAt: DateTime.now().subtract(const Duration(days: 120)), avatarColor: colors[4], devicesOwned: 3, actionsToday: 0),
      AdminUser(id: '6', name: 'Carol Davis', email: 'carol@circuvent.com', role: 'editor', status: 'active', lastLogin: DateTime.now().subtract(const Duration(hours: 12)), createdAt: DateTime.now().subtract(const Duration(days: 90)), avatarColor: colors[5], devicesOwned: 10, actionsToday: 14),
      AdminUser(id: '7', name: 'David Lee', email: 'david@circuvent.com', role: 'viewer', status: 'pending', lastLogin: DateTime.now().subtract(const Duration(days: 1)), createdAt: DateTime.now().subtract(const Duration(days: 7)), avatarColor: colors[6], devicesOwned: 0, actionsToday: 0),
      AdminUser(id: '8', name: 'Emma Brown', email: 'emma@circuvent.com', role: 'viewer', status: 'active', lastLogin: DateTime.now().subtract(const Duration(hours: 2)), createdAt: DateTime.now().subtract(const Duration(days: 60)), avatarColor: colors[7], devicesOwned: 6, actionsToday: 9),
    ];
  }

  List<AIModelInfo> _generateAIModels() {
    List<double> curve(double s, double e, int n) {
      final r = Random(42);
      return List.generate(n, (i) {
        final t = i / (n - 1).clamp(1, n);
        return s + (e - s) * (1 - _negExp(-3 * t)) + (r.nextDouble() - 0.5) * 0.02;
      });
    }

    List<double> lossCurve(double s, double e, int n) {
      final r = Random(43);
      return List.generate(n, (i) {
        final t = i / (n - 1).clamp(1, n);
        return s * _negExp(-3 * t) + e + (r.nextDouble() - 0.5) * 0.01;
      });
    }

    return [
      AIModelInfo(id: 'model_1', name: 'AnomalyDetector v3.2', type: 'anomaly', status: 'deployed', accuracy: 0.962, loss: 0.041, epochsCurrent: 100, epochsTotal: 100, trainingProgress: 1.0, lastTrained: DateTime.now().subtract(const Duration(hours: 6)), datasetSize: '2.4M samples', latency: '12ms', f1Score: 0.954, precision: 0.968, recall: 0.941, framework: 'TensorFlow Lite', modelSize: '4.2 MB', accuracyHistory: curve(0.5, 0.962, 100), lossHistory: lossCurve(0.8, 0.041, 100), valAccuracyHistory: curve(0.48, 0.955, 100), valLossHistory: lossCurve(0.85, 0.048, 100), description: 'Detects anomalous sensor readings, unauthorized access patterns, and equipment failure precursors in real-time.', inferenceCount: 142500),
      AIModelInfo(id: 'model_2', name: 'EnergyPredictor v2.1', type: 'forecasting', status: 'deployed', accuracy: 0.934, loss: 0.058, epochsCurrent: 80, epochsTotal: 80, trainingProgress: 1.0, lastTrained: DateTime.now().subtract(const Duration(days: 1)), datasetSize: '1.8M samples', latency: '8ms', f1Score: 0.921, precision: 0.940, recall: 0.903, framework: 'PyTorch Mobile', modelSize: '3.1 MB', accuracyHistory: curve(0.45, 0.934, 80), lossHistory: lossCurve(0.9, 0.058, 80), valAccuracyHistory: curve(0.42, 0.928, 80), valLossHistory: lossCurve(0.95, 0.065, 80), description: 'Forecasts household energy consumption patterns using LSTM networks for optimal scheduling and cost reduction.', inferenceCount: 89200),
      AIModelInfo(id: 'model_3', name: 'ComfortClassifier v1.8', type: 'classification', status: 'deployed', accuracy: 0.918, loss: 0.072, epochsCurrent: 60, epochsTotal: 60, trainingProgress: 1.0, lastTrained: DateTime.now().subtract(const Duration(days: 3)), datasetSize: '950K samples', latency: '5ms', f1Score: 0.910, precision: 0.925, recall: 0.896, framework: 'TensorFlow Lite', modelSize: '1.8 MB', accuracyHistory: curve(0.52, 0.918, 60), lossHistory: lossCurve(0.7, 0.072, 60), valAccuracyHistory: curve(0.50, 0.912, 60), valLossHistory: lossCurve(0.75, 0.080, 60), description: 'Classifies indoor comfort levels based on temperature, humidity, light, and air quality for automatic HVAC adjustment.', inferenceCount: 67800),
      AIModelInfo(id: 'model_4', name: 'DeviceRecommender v2.0', type: 'recommendation', status: 'training', accuracy: 0.847, loss: 0.134, epochsCurrent: 35, epochsTotal: 75, trainingProgress: 0.467, lastTrained: DateTime.now().subtract(const Duration(hours: 2)), datasetSize: '1.2M interactions', latency: '15ms', f1Score: 0.832, precision: 0.855, recall: 0.810, framework: 'ONNX Runtime', modelSize: '5.6 MB', accuracyHistory: curve(0.4, 0.847, 35), lossHistory: lossCurve(1.0, 0.134, 35), valAccuracyHistory: curve(0.38, 0.840, 35), valLossHistory: lossCurve(1.05, 0.145, 35), description: 'Recommends device actions, scene activations, and automation rules based on user behavior patterns and preferences.', inferenceCount: 34100),
      AIModelInfo(id: 'model_5', name: 'VoiceNLU v1.5', type: 'nlp', status: 'deployed', accuracy: 0.891, loss: 0.095, epochsCurrent: 50, epochsTotal: 50, trainingProgress: 1.0, lastTrained: DateTime.now().subtract(const Duration(days: 7)), datasetSize: '500K utterances', latency: '22ms', f1Score: 0.883, precision: 0.898, recall: 0.868, framework: 'TensorFlow Lite', modelSize: '8.4 MB', accuracyHistory: curve(0.35, 0.891, 50), lossHistory: lossCurve(1.2, 0.095, 50), valAccuracyHistory: curve(0.33, 0.885, 50), valLossHistory: lossCurve(1.25, 0.102, 50), description: 'Natural language understanding for voice commands — intent classification, entity extraction, and context handling.', inferenceCount: 28700),
      AIModelInfo(id: 'model_6', name: 'OccupancyPredictor v1.3', type: 'classification', status: 'deployed', accuracy: 0.945, loss: 0.048, epochsCurrent: 40, epochsTotal: 40, trainingProgress: 1.0, lastTrained: DateTime.now().subtract(const Duration(days: 2)), datasetSize: '780K samples', latency: '3ms', f1Score: 0.938, precision: 0.952, recall: 0.924, framework: 'TensorFlow Lite', modelSize: '1.2 MB', accuracyHistory: curve(0.55, 0.945, 40), lossHistory: lossCurve(0.6, 0.048, 40), valAccuracyHistory: curve(0.53, 0.940, 40), valLossHistory: lossCurve(0.65, 0.053, 40), description: 'Predicts room occupancy using motion, CO2, temperature delta, and light sensor fusion for smart lighting/HVAC control.', inferenceCount: 156300),
      AIModelInfo(id: 'model_7', name: 'MaintenancePredictor v1.1', type: 'regression', status: 'queued', accuracy: 0.876, loss: 0.112, epochsCurrent: 0, epochsTotal: 60, trainingProgress: 0.0, lastTrained: DateTime.now().subtract(const Duration(days: 14)), datasetSize: '350K records', latency: '18ms', f1Score: 0.862, precision: 0.880, recall: 0.845, framework: 'PyTorch Mobile', modelSize: '2.9 MB', accuracyHistory: curve(0.42, 0.876, 45), lossHistory: lossCurve(0.9, 0.112, 45), valAccuracyHistory: curve(0.40, 0.870, 45), valLossHistory: lossCurve(0.95, 0.120, 45), description: 'Predicts appliance remaining useful life and maintenance windows using vibration, temperature, and usage pattern analysis.', inferenceCount: 12400),
      AIModelInfo(id: 'model_8', name: 'SecurityThreatNet v2.4', type: 'anomaly', status: 'deployed', accuracy: 0.978, loss: 0.019, epochsCurrent: 120, epochsTotal: 120, trainingProgress: 1.0, lastTrained: DateTime.now().subtract(const Duration(hours: 18)), datasetSize: '3.1M events', latency: '7ms', f1Score: 0.971, precision: 0.982, recall: 0.960, framework: 'TensorFlow Lite', modelSize: '6.1 MB', accuracyHistory: curve(0.6, 0.978, 120), lossHistory: lossCurve(0.5, 0.019, 120), valAccuracyHistory: curve(0.58, 0.975, 120), valLossHistory: lossCurve(0.55, 0.022, 120), description: 'Multi-layer perceptron for detecting intrusions, unauthorized access, and suspicious network activity with near-zero false positives.', inferenceCount: 201000),
    ];
  }

  double _negExp(double x) => 1.0 / (1.0 + x * x / 2 + x * x * x * x / 24).clamp(0.001, double.infinity);

  List<TrainingJob> _generateTrainingJobs() => [
    TrainingJob(id: 'tj_1', modelName: 'DeviceRecommender v2.0', status: 'running', progress: 0.467, currentEpoch: 35, totalEpochs: 75, duration: '2h 14m', gpu: 'Tesla T4', gpuUtilization: 87.3, memoryUsed: 12.4, startedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 14))),
    TrainingJob(id: 'tj_2', modelName: 'MaintenancePredictor v1.1', status: 'queued', progress: 0, currentEpoch: 0, totalEpochs: 60, duration: '—', gpu: 'Tesla T4', gpuUtilization: 0, memoryUsed: 0, startedAt: DateTime.now()),
    TrainingJob(id: 'tj_3', modelName: 'AnomalyDetector v3.2', status: 'completed', progress: 1.0, currentEpoch: 100, totalEpochs: 100, duration: '5h 42m', gpu: 'Tesla T4', gpuUtilization: 0, memoryUsed: 0, startedAt: DateTime.now().subtract(const Duration(hours: 8))),
    TrainingJob(id: 'tj_4', modelName: 'SecurityThreatNet v2.4', status: 'completed', progress: 1.0, currentEpoch: 120, totalEpochs: 120, duration: '7h 18m', gpu: 'Tesla T4', gpuUtilization: 0, memoryUsed: 0, startedAt: DateTime.now().subtract(const Duration(hours: 18))),
  ];

  List<DeviceNode> _generateDeviceNodes() => [
    DeviceNode(id: 'n1', name: 'ESP32-Node1 (Living)', type: 'ESP32', status: 'online', ipAddress: '192.168.1.101', firmware: 'v2.1.3', temperature: 38.2, uptime: 99.8, dataPoints: 142500, lastSeen: DateTime.now().subtract(const Duration(seconds: 5))),
    DeviceNode(id: 'n2', name: 'ESP32-Node2 (Kitchen)', type: 'ESP32', status: 'online', ipAddress: '192.168.1.102', firmware: 'v2.1.3', temperature: 41.5, uptime: 98.2, dataPoints: 128300, lastSeen: DateTime.now().subtract(const Duration(seconds: 12))),
    DeviceNode(id: 'n3', name: 'ESP32-Node3 (Bedroom)', type: 'ESP32', status: 'online', ipAddress: '192.168.1.103', firmware: 'v2.1.0', temperature: 36.8, uptime: 99.5, dataPoints: 135800, lastSeen: DateTime.now().subtract(const Duration(seconds: 3))),
    DeviceNode(id: 'n4', name: 'ESP32-Node4 (Garden)', type: 'ESP32', status: 'online', ipAddress: '192.168.1.104', firmware: 'v2.1.3', temperature: 44.2, uptime: 97.1, dataPoints: 98400, lastSeen: DateTime.now().subtract(const Duration(seconds: 30))),
    DeviceNode(id: 'n5', name: 'ESP32-Node5 (Garage)', type: 'ESP32', status: 'offline', ipAddress: '192.168.1.105', firmware: 'v2.0.8', temperature: 0, uptime: 89.3, dataPoints: 45200, lastSeen: DateTime.now().subtract(const Duration(hours: 8))),
    DeviceNode(id: 'n6', name: 'Raspberry Pi Gateway', type: 'RPi 4', status: 'online', ipAddress: '192.168.1.1', firmware: 'v3.0.1', temperature: 52.1, uptime: 99.9, dataPoints: 890200, lastSeen: DateTime.now()),
    DeviceNode(id: 'n7', name: 'ZigBee Coordinator', type: 'CC2531', status: 'online', ipAddress: '192.168.1.50', firmware: 'v1.5.2', temperature: 32.4, uptime: 99.7, dataPoints: 567800, lastSeen: DateTime.now().subtract(const Duration(seconds: 8))),
  ];

  List<APIEndpoint> _generateAPIEndpoints() => [
    APIEndpoint(path: '/api/v1/devices', method: 'GET', calls24h: 4520, avgLatency: 23, errorRate: 0.1, status: 'healthy'),
    APIEndpoint(path: '/api/v1/sensors/data', method: 'GET', calls24h: 8940, avgLatency: 15, errorRate: 0.05, status: 'healthy'),
    APIEndpoint(path: '/api/v1/ai/predict', method: 'POST', calls24h: 2340, avgLatency: 45, errorRate: 0.3, status: 'healthy'),
    APIEndpoint(path: '/api/v1/auth/login', method: 'POST', calls24h: 156, avgLatency: 120, errorRate: 2.1, status: 'warning'),
    APIEndpoint(path: '/api/v1/scenes/activate', method: 'POST', calls24h: 890, avgLatency: 35, errorRate: 0.2, status: 'healthy'),
    APIEndpoint(path: '/api/v1/mqtt/publish', method: 'POST', calls24h: 12400, avgLatency: 8, errorRate: 0.8, status: 'healthy'),
    APIEndpoint(path: '/api/v1/analytics/report', method: 'GET', calls24h: 234, avgLatency: 250, errorRate: 1.5, status: 'warning'),
    APIEndpoint(path: '/api/v1/firmware/update', method: 'POST', calls24h: 12, avgLatency: 800, errorRate: 0, status: 'healthy'),
  ];

  List<BackupRecord> _generateBackups() => [
    BackupRecord(id: 'b1', type: 'Full', size: '245 MB', timestamp: DateTime.now().subtract(const Duration(hours: 2)), status: 'completed', duration: '3m 12s'),
    BackupRecord(id: 'b2', type: 'Incremental', size: '18 MB', timestamp: DateTime.now().subtract(const Duration(hours: 6)), status: 'completed', duration: '24s'),
    BackupRecord(id: 'b3', type: 'Full', size: '242 MB', timestamp: DateTime.now().subtract(const Duration(days: 1)), status: 'completed', duration: '3m 08s'),
    BackupRecord(id: 'b4', type: 'Incremental', size: '22 MB', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)), status: 'completed', duration: '28s'),
    BackupRecord(id: 'b5', type: 'Full', size: '238 MB', timestamp: DateTime.now().subtract(const Duration(days: 2)), status: 'failed', duration: '—'),
  ];

  List<SecurityEvent> _generateSecurityEvents() => [
    SecurityEvent(id: 's1', type: 'auth_failure', description: 'Failed login attempt — brute force detected', severity: 'high', source: '192.168.1.105', timestamp: DateTime.now().subtract(const Duration(hours: 3))),
    SecurityEvent(id: 's2', type: 'port_scan', description: 'Port scan detected from external IP', severity: 'medium', source: '203.0.113.42', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
    SecurityEvent(id: 's3', type: 'cert_expiry', description: 'SSL certificate expires in 14 days', severity: 'low', source: 'api.smarthome.local', timestamp: DateTime.now().subtract(const Duration(hours: 8))),
    SecurityEvent(id: 's4', type: 'privilege_escalation', description: 'Unauthorized admin API call blocked', severity: 'critical', source: '192.168.1.45', timestamp: DateTime.now().subtract(const Duration(hours: 12))),
    SecurityEvent(id: 's5', type: 'firmware_tamper', description: 'Firmware checksum mismatch on Node5', severity: 'high', source: 'ESP32-Node5', timestamp: DateTime.now().subtract(const Duration(days: 1))),
  ];

  // ── Actions ──
  void toggleUserStatus(String userId) {
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx >= 0) {
      final u = _users[idx];
      _users[idx] = AdminUser(id: u.id, name: u.name, email: u.email, role: u.role, status: u.status == 'active' ? 'suspended' : 'active', lastLogin: u.lastLogin, createdAt: u.createdAt, avatarColor: u.avatarColor, devicesOwned: u.devicesOwned, actionsToday: u.actionsToday);
      notifyListeners();
    }
  }

  void startModelTraining(String modelId) {
    final idx = _aiModels.indexWhere((m) => m.id == modelId);
    if (idx >= 0) {
      final m = _aiModels[idx];
      _aiModels[idx] = AIModelInfo(id: m.id, name: m.name, type: m.type, status: 'training', accuracy: m.accuracy, loss: m.loss, epochsCurrent: 0, epochsTotal: m.epochsTotal, trainingProgress: 0, lastTrained: DateTime.now(), datasetSize: m.datasetSize, latency: m.latency, f1Score: m.f1Score, precision: m.precision, recall: m.recall, accuracyHistory: m.accuracyHistory, lossHistory: m.lossHistory, valAccuracyHistory: m.valAccuracyHistory, valLossHistory: m.valLossHistory, description: m.description, inferenceCount: m.inferenceCount, framework: m.framework, modelSize: m.modelSize);
      notifyListeners();
    }
  }

  void clearLog(String logId) {
    _systemLogs.removeWhere((l) => l.id == logId);
    notifyListeners();
  }

  void clearAllLogs() {
    _systemLogs.clear();
    notifyListeners();
  }

  Map<String, dynamic> get systemHealth => {
    'cpu': _cpuUsage, 'memory': _memoryUsage, 'disk': _diskUsage,
    'network': _networkTraffic, 'uptime': _uptime, 'mqttConnections': 5,
    'activeWebSockets': 3, 'databaseSize': '245 MB', 'lastBackup': '2 hours ago',
  };

  int get deployedModels => _aiModels.where((m) => m.status == 'deployed').length;
  int get trainingModelsCount => _aiModels.where((m) => m.status == 'training').length;
  double get avgModelAccuracy => _aiModels.isEmpty ? 0 : _aiModels.map((m) => m.accuracy).reduce((a, b) => a + b) / _aiModels.length;
  int get totalInferences => _aiModels.fold(0, (sum, m) => sum + m.inferenceCount);
  int get onlineNodes => _deviceNodes.where((d) => d.status == 'online').length;
  int get offlineNodes => _deviceNodes.where((d) => d.status == 'offline').length;

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
