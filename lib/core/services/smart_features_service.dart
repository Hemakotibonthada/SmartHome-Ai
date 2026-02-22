import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ========== FEATURE 1: Scene/Mood System ==========
class SceneModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SceneAction> actions;
  final String description;
  bool isActive;
  int usageCount;

  SceneModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.actions,
    required this.description,
    this.isActive = false,
    this.usageCount = 0,
  });
}

class SceneAction {
  final String deviceId;
  final String deviceName;
  final String action; // on, off, set
  final Map<String, dynamic> params;

  SceneAction({
    required this.deviceId,
    required this.deviceName,
    required this.action,
    this.params = const {},
  });
}

// ========== FEATURE 2: Scheduling System ==========
class ScheduleRule {
  final String id;
  final String name;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1=Mon..7=Sun
  final List<SceneAction> actions;
  bool isEnabled;
  DateTime? lastTriggered;

  ScheduleRule({
    required this.id,
    required this.name,
    required this.time,
    required this.daysOfWeek,
    required this.actions,
    this.isEnabled = true,
    this.lastTriggered,
  });

  String get daysLabel {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.length == 5 && !daysOfWeek.contains(6) && !daysOfWeek.contains(7)) return 'Weekdays';
    if (daysOfWeek.length == 2 && daysOfWeek.contains(6) && daysOfWeek.contains(7)) return 'Weekends';
    final names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return daysOfWeek.map((d) => names[d - 1]).join(', ');
  }
}

// ========== FEATURE 3: Comfort Index ==========
class ComfortIndex {
  final double temperature;
  final double humidity;
  final double score; // 0-100
  final String label;
  final Color color;
  final double lightLevel;
  final double noiseLevel;
  final String suggestion;

  ComfortIndex({
    required this.temperature,
    required this.humidity,
    required this.score,
    required this.label,
    required this.color,
    this.lightLevel = 350,
    this.noiseLevel = 35,
    required this.suggestion,
  });

  // Aliases for screens
  Color get scoreColor => color;
  String get level => label;
}

// ========== FEATURE 4: Air Quality Index ==========
class AirQualityData {
  final int aqi; // 0-500
  final String level; // Good, Moderate, Unhealthy...
  final Color color;
  final double gasLevel;
  final double humidity;
  final double temperature;
  final double co2;
  final double voc;
  final double pm25;
  final String healthAdvice;
  final IconData icon;

  AirQualityData({
    required this.aqi,
    required this.level,
    required this.color,
    required this.gasLevel,
    required this.humidity,
    required this.temperature,
    this.co2 = 420,
    this.voc = 180,
    this.pm25 = 12,
    required this.healthAdvice,
    required this.icon,
  });

  // Aliases
  Color get levelColor => color;
  String get recommendation => healthAdvice;
}

// ========== FEATURE 5: Device Health Score ==========
class DeviceHealthReport {
  final String deviceId;
  final String deviceName;
  final int healthScore; // 0-100
  final String status; // Excellent, Good, Fair, Poor, Critical
  final Color statusColor;
  final double uptime; // percentage
  final int errorCount;
  final DateTime? lastMaintenance;
  final DateTime? nextMaintenance;
  final List<String> issues;
  final List<String> recommendations;

  DeviceHealthReport({
    required this.deviceId,
    required this.deviceName,
    required this.healthScore,
    required this.status,
    required this.statusColor,
    required this.uptime,
    required this.errorCount,
    this.lastMaintenance,
    this.nextMaintenance,
    this.issues = const [],
    this.recommendations = const [],
  });
}

// ========== FEATURE 6: Activity Log ==========
class ActivityLogEntry {
  final String id;
  final DateTime timestamp;
  final String action;
  final String details;
  final String userId;
  final String userName;
  final ActivityCategory category;
  final IconData icon;
  final Color color;

  ActivityLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.details,
    required this.userId,
    required this.userName,
    required this.category,
    required this.icon,
    required this.color,
  });
}

enum ActivityCategory { device, sensor, automation, security, system, user }

// ========== FEATURE 7: Maintenance ==========
class MaintenanceTask {
  final String id;
  final String title;
  final String description;
  final String deviceId;
  final String deviceName;
  final DateTime dueDate;
  final MaintenancePriority priority;
  final bool isCompleted;
  final IconData icon;

  MaintenanceTask({
    required this.id,
    required this.title,
    required this.description,
    required this.deviceId,
    required this.deviceName,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.icon,
  });

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
}

enum MaintenancePriority { low, medium, high, critical }

// ========== FEATURE 8: Favorites ==========
class FavoriteItem {
  final String id;
  final String type; // device, sensor, scene, routine
  final String name;
  final IconData icon;
  final Color color;
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
    required this.addedAt,
  });
}

// ========== FEATURE 9: Geofence ==========
class GeofenceRule {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final GeofenceTrigger trigger;
  final List<SceneAction> actions;
  bool isEnabled;

  GeofenceRule({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.trigger,
    required this.actions,
    this.isEnabled = true,
  });
}

enum GeofenceTrigger { onEnter, onExit, both }

// ========== FEATURE 10: Vacation Mode ==========
class VacationModeConfig {
  bool isEnabled;
  DateTime? startDate;
  DateTime? endDate;
  bool simulateLights;
  bool simulateTV;
  bool enableSecurityAlerts;
  bool autoWaterPlants;
  List<Map<String, dynamic>> simulationSchedule;

  VacationModeConfig({
    this.isEnabled = false,
    this.startDate,
    this.endDate,
    this.simulateLights = true,
    this.simulateTV = true,
    this.enableSecurityAlerts = true,
    this.autoWaterPlants = false,
    this.simulationSchedule = const [],
  });
}

// ========== FEATURE 11: Room Occupancy ==========
class RoomOccupancy {
  final String roomName;
  final bool isOccupied;
  final int occupantCount;
  final DateTime lastMotion;
  final double occupancyPercent; // today
  final List<double> hourlyOccupancy; // 24 hours

  RoomOccupancy({
    required this.roomName,
    required this.isOccupied,
    required this.occupantCount,
    required this.lastMotion,
    required this.occupancyPercent,
    required this.hourlyOccupancy,
  });
}

// ========== FEATURE 12: Appliance Fingerprint ==========
class ApplianceFingerprint {
  final String name;
  final double typicalPower;
  final double currentPower;
  final String status;
  final Color statusColor;
  final double confidence;

  ApplianceFingerprint({
    required this.name,
    required this.typicalPower,
    required this.currentPower,
    required this.status,
    required this.statusColor,
    required this.confidence,
  });
}

// ========== SMART FEATURES SERVICE ==========
class SmartFeaturesService extends ChangeNotifier {
  final Random _random = Random();

  // Feature 1: Scenes
  List<SceneModel> _scenes = [];
  List<SceneModel> get scenes => _scenes;
  SceneModel? _activeScene;
  SceneModel? get activeScene => _activeScene;

  // Feature 2: Schedules
  List<ScheduleRule> _schedules = [];
  List<ScheduleRule> get schedules => _schedules;

  // Feature 3: Comfort Index
  ComfortIndex? _comfortIndex;
  ComfortIndex? get comfortIndex => _comfortIndex;

  // Feature 4: Air Quality
  AirQualityData? _airQuality;
  AirQualityData? get airQuality => _airQuality;

  // Feature 5: Device Health
  List<DeviceHealthReport> _healthReports = [];
  List<DeviceHealthReport> get healthReports => _healthReports;

  // Feature 6: Activity Log
  List<ActivityLogEntry> _activityLog = [];
  List<ActivityLogEntry> get activityLog => _activityLog;

  // Feature 7: Maintenance
  List<MaintenanceTask> _maintenanceTasks = [];
  List<MaintenanceTask> get maintenanceTasks => _maintenanceTasks;

  // Feature 8: Favorites
  List<FavoriteItem> _favorites = [];
  List<FavoriteItem> get favorites => _favorites;

  // Feature 9: Geofence
  List<GeofenceRule> _geofenceRules = [];
  List<GeofenceRule> get geofenceRules => _geofenceRules;

  // Feature 10: Vacation Mode
  VacationModeConfig _vacationMode = VacationModeConfig();
  VacationModeConfig get vacationMode => _vacationMode;

  // Feature 11: Room Occupancy
  List<RoomOccupancy> _roomOccupancy = [];
  List<RoomOccupancy> get roomOccupancy => _roomOccupancy;

  // Feature 12: Appliance Fingerprinting
  List<ApplianceFingerprint> _fingerprints = [];
  List<ApplianceFingerprint> get fingerprints => _fingerprints;

  // Feature 13: Quick Routines
  List<QuickRoutine> _routines = [];
  List<QuickRoutine> get routines => _routines;

  // Feature 14: Sleep/Wake Mode
  bool _sleepModeActive = false;
  bool get sleepModeActive => _sleepModeActive;
  bool _wakeModeActive = false;
  bool get wakeModeActive => _wakeModeActive;

  // Feature 15: Guest Mode
  bool _guestModeActive = false;
  bool get guestModeActive => _guestModeActive;

  // Feature 16: Emergency Protocol
  bool _emergencyActive = false;
  bool get emergencyActive => _emergencyActive;

  // Feature 17: Parental Controls
  bool _parentalControlsEnabled = false;
  bool get parentalControlsEnabled => _parentalControlsEnabled;
  List<String> _restrictedDevices = [];
  List<String> get restrictedDevices => _restrictedDevices;

  // Feature 18: Door/Window Status
  List<DoorWindowStatus> _doorWindowStatus = [];
  List<DoorWindowStatus> get doorWindowStatus => _doorWindowStatus;

  // Feature 19: Adaptive Thresholds
  Map<String, AdaptiveThreshold> _adaptiveThresholds = {};
  Map<String, AdaptiveThreshold> get adaptiveThresholds => _adaptiveThresholds;

  Timer? _updateTimer;

  SmartFeaturesService() {
    _initializeData();
    _updateTimer = Timer.periodic(const Duration(seconds: 20), (_) => _updateLiveData());
  }

  void _initializeData() {
    _initScenes();
    _initSchedules();
    _initRoutines();
    _initMaintenanceTasks();
    _initActivityLog();
    _initGeofenceRules();
    _initDoorWindowStatus();
    _initAdaptiveThresholds();
    _updateComfortIndex(26.5, 55.0);
    _updateAirQuality(350, 55.0, 26.5);
    _updateDeviceHealth();
    _updateRoomOccupancy();
    _updateFingerprints();
  }

  // ===== SCENE MANAGEMENT =====
  void _initScenes() {
    _scenes = [
      SceneModel(
        id: 'movie_night', name: 'Movie Night', icon: Icons.movie,
        color: const Color(0xFF9C27B0), description: 'Dim lights, TV on, AC at 24°C',
        actions: [
          SceneAction(deviceId: 'light_1', deviceName: 'Living Room Light', action: 'set', params: {'brightness': 30}),
          SceneAction(deviceId: 'tv_1', deviceName: 'Smart TV', action: 'on'),
          SceneAction(deviceId: 'ac_1', deviceName: 'Living Room AC', action: 'set', params: {'temperature': 24}),
        ], usageCount: 42,
      ),
      SceneModel(
        id: 'good_morning', name: 'Good Morning', icon: Icons.wb_sunny,
        color: const Color(0xFFFF9800), description: 'Lights on, curtains open, geyser on',
        actions: [
          SceneAction(deviceId: 'light_1', deviceName: 'All Lights', action: 'on'),
          SceneAction(deviceId: 'curtain_1', deviceName: 'Curtains', action: 'set', params: {'position': 100}),
          SceneAction(deviceId: 'geyser_1', deviceName: 'Geyser', action: 'on'),
        ], usageCount: 156,
      ),
      SceneModel(
        id: 'good_night', name: 'Good Night', icon: Icons.bedtime,
        color: const Color(0xFF3F51B5), description: 'All lights off, AC at 22°C, lock doors',
        actions: [
          SceneAction(deviceId: 'light_all', deviceName: 'All Lights', action: 'off'),
          SceneAction(deviceId: 'ac_1', deviceName: 'Bedroom AC', action: 'set', params: {'temperature': 22}),
          SceneAction(deviceId: 'lock_1', deviceName: 'Door Locks', action: 'on'),
        ], usageCount: 189,
      ),
      SceneModel(
        id: 'party_mode', name: 'Party Mode', icon: Icons.celebration,
        color: const Color(0xFFE91E63), description: 'Color lights, music on, AC cool',
        actions: [
          SceneAction(deviceId: 'light_1', deviceName: 'Smart Lights', action: 'set', params: {'brightness': 100, 'color': 'party'}),
          SceneAction(deviceId: 'speaker_1', deviceName: 'Speaker', action: 'on'),
          SceneAction(deviceId: 'ac_1', deviceName: 'AC', action: 'set', params: {'temperature': 22}),
        ], usageCount: 23,
      ),
      SceneModel(
        id: 'work_mode', name: 'Work From Home', icon: Icons.computer,
        color: const Color(0xFF2196F3), description: 'Bright lights, AC comfortable, minimal noise',
        actions: [
          SceneAction(deviceId: 'light_1', deviceName: 'Desk Light', action: 'set', params: {'brightness': 90}),
          SceneAction(deviceId: 'ac_1', deviceName: 'AC', action: 'set', params: {'temperature': 24}),
          SceneAction(deviceId: 'fan_1', deviceName: 'Fan', action: 'off'),
        ], usageCount: 87,
      ),
      SceneModel(
        id: 'energy_saver', name: 'Energy Saver', icon: Icons.eco,
        color: const Color(0xFF4CAF50), description: 'Turn off non-essential, optimize cooling',
        actions: [
          SceneAction(deviceId: 'light_extra', deviceName: 'Extra Lights', action: 'off'),
          SceneAction(deviceId: 'ac_1', deviceName: 'AC', action: 'set', params: {'temperature': 26}),
          SceneAction(deviceId: 'tv_1', deviceName: 'TV Standby', action: 'off'),
        ], usageCount: 65,
      ),
      SceneModel(
        id: 'cooking', name: 'Cooking Mode', icon: Icons.restaurant,
        color: const Color(0xFFFF5722), description: 'Kitchen lights, exhaust on, gas monitoring',
        actions: [
          SceneAction(deviceId: 'light_kitchen', deviceName: 'Kitchen Light', action: 'on'),
          SceneAction(deviceId: 'fan_exhaust', deviceName: 'Exhaust Fan', action: 'on'),
        ], usageCount: 34,
      ),
      SceneModel(
        id: 'reading', name: 'Reading Mode', icon: Icons.menu_book,
        color: const Color(0xFF795548), description: 'Warm light, quiet environment',
        actions: [
          SceneAction(deviceId: 'light_1', deviceName: 'Reading Lamp', action: 'set', params: {'brightness': 70, 'warmth': 80}),
          SceneAction(deviceId: 'fan_1', deviceName: 'Fan', action: 'set', params: {'speed': 1}),
        ], usageCount: 28,
      ),
    ];
  }

  void activateScene(String sceneId) {
    for (var scene in _scenes) {
      scene.isActive = scene.id == sceneId;
      if (scene.isActive) {
        scene.usageCount++;
        _activeScene = scene;
        _addActivityLog('Scene Activated', '${scene.name} scene activated', ActivityCategory.automation, Icons.auto_awesome, scene.color);
      }
    }
    notifyListeners();
  }

  void deactivateAllScenes() {
    for (var scene in _scenes) {
      scene.isActive = false;
    }
    _activeScene = null;
    notifyListeners();
  }

  // ===== SCHEDULE MANAGEMENT =====
  void _initSchedules() {
    _schedules = [
      ScheduleRule(id: 's1', name: 'Morning Lights', time: const TimeOfDay(hour: 6, minute: 30),
        daysOfWeek: [1, 2, 3, 4, 5], actions: [SceneAction(deviceId: 'light_1', deviceName: 'Lights', action: 'on')]),
      ScheduleRule(id: 's2', name: 'Night Shutdown', time: const TimeOfDay(hour: 23, minute: 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7], actions: [SceneAction(deviceId: 'light_all', deviceName: 'All Lights', action: 'off')]),
      ScheduleRule(id: 's3', name: 'AC Pre-cool', time: const TimeOfDay(hour: 17, minute: 30),
        daysOfWeek: [1, 2, 3, 4, 5], actions: [SceneAction(deviceId: 'ac_1', deviceName: 'AC', action: 'on', params: {'temp': 24})]),
      ScheduleRule(id: 's4', name: 'Weekend Geyser', time: const TimeOfDay(hour: 7, minute: 0),
        daysOfWeek: [6, 7], actions: [SceneAction(deviceId: 'geyser_1', deviceName: 'Geyser', action: 'on')]),
    ];
  }

  void toggleSchedule(String id) {
    final schedule = _schedules.firstWhere((s) => s.id == id);
    schedule.isEnabled = !schedule.isEnabled;
    notifyListeners();
  }

  void addSchedule(ScheduleRule rule) {
    _schedules.add(rule);
    notifyListeners();
  }

  // ===== ROUTINES =====
  void _initRoutines() {
    _routines = [
      QuickRoutine(id: 'r1', name: 'Sleep', icon: Icons.bedtime_rounded, color: const Color(0xFF3F51B5),
        actions: ['Dim all lights to 10%', 'Set AC to 22°C', 'Lock all doors', 'Enable security'], isFavorite: true),
      QuickRoutine(id: 'r2', name: 'Wake Up', icon: Icons.wb_sunny_rounded, color: const Color(0xFFFF9800),
        actions: ['Gradually increase lights', 'Turn on geyser', 'Open curtains', 'Play morning briefing'], isFavorite: true),
      QuickRoutine(id: 'r3', name: 'Leave Home', icon: Icons.directions_car, color: const Color(0xFF607D8B),
        actions: ['Turn off all lights', 'Turn off AC/Fan', 'Lock doors', 'Enable cameras', 'Set to away mode']),
      QuickRoutine(id: 'r4', name: 'Arrive Home', icon: Icons.home_rounded, color: const Color(0xFF4CAF50),
        actions: ['Unlock door', 'Turn on hallway light', 'Pre-cool AC based on weather', 'Disable away mode']),
      QuickRoutine(id: 'r5', name: 'Emergency', icon: Icons.emergency, color: const Color(0xFFF44336),
        actions: ['Turn on all lights to 100%', 'Sound alarm', 'Unlock all doors', 'Send emergency alert']),
      QuickRoutine(id: 'r6', name: 'Power Save', icon: Icons.battery_saver, color: const Color(0xFF009688),
        actions: ['Turn off standby devices', 'Set AC to eco mode', 'Reduce light brightness', 'Defer water pump']),
    ];
  }

  void executeRoutine(String routineId) {
    final routine = _routines.firstWhere((r) => r.id == routineId);
    routine.lastExecuted = DateTime.now();
    routine.executionCount++;
    _addActivityLog('Routine Executed', '${routine.name} routine triggered', ActivityCategory.automation, routine.icon, routine.color);
    notifyListeners();
  }

  void toggleRoutineFavorite(String routineId) {
    final routine = _routines.firstWhere((r) => r.id == routineId);
    routine.isFavorite = !routine.isFavorite;
    notifyListeners();
  }

  // ===== COMFORT INDEX =====
  void _updateComfortIndex(double temp, double humidity) {
    // Heat Index formula simplified
    double hi = temp;
    if (temp >= 27) {
      hi = -8.784 + 1.611 * temp + 2.338 * humidity - 0.1461 * temp * humidity;
    }
    double score = 100 - ((hi - 22).abs() * 5 + (humidity - 50).abs() * 0.5);
    score = score.clamp(0, 100);

    String label;
    Color color;
    String suggestion;

    if (score >= 80) {
      label = 'Excellent'; color = const Color(0xFF4CAF50); suggestion = 'Perfect comfort conditions!';
    } else if (score >= 60) {
      label = 'Good'; color = const Color(0xFF8BC34A); suggestion = 'Slightly adjust temperature for optimal comfort.';
    } else if (score >= 40) {
      label = 'Fair'; color = const Color(0xFFFF9800); suggestion = 'Consider turning on AC or adjusting humidity.';
    } else if (score >= 20) {
      label = 'Poor'; color = const Color(0xFFFF5722); suggestion = 'Environment is uncomfortable. Take action.';
    } else {
      label = 'Critical'; color = const Color(0xFFF44336); suggestion = 'Unsafe conditions detected!';
    }

    _comfortIndex = ComfortIndex(
      temperature: temp, humidity: humidity, score: score,
      label: label, color: color,
      lightLevel: 200 + _random.nextDouble() * 500,
      noiseLevel: 25 + _random.nextDouble() * 30,
      suggestion: suggestion,
    );
  }

  // ===== AIR QUALITY =====
  void _updateAirQuality(int gasLevel, double humidity, double temp) {
    int aqi;
    String level;
    Color color;
    String advice;
    IconData icon;

    if (gasLevel < 300) {
      aqi = 25 + _random.nextInt(25); level = 'Excellent'; color = const Color(0xFF4CAF50);
      advice = 'Air quality is excellent. No action needed.'; icon = Icons.eco;
    } else if (gasLevel < 600) {
      aqi = 51 + _random.nextInt(49); level = 'Good'; color = const Color(0xFF8BC34A);
      advice = 'Air quality is acceptable.'; icon = Icons.air;
    } else if (gasLevel < 1000) {
      aqi = 101 + _random.nextInt(49); level = 'Moderate'; color = const Color(0xFFFF9800);
      advice = 'Sensitive people should reduce outdoor activity.'; icon = Icons.cloud;
    } else if (gasLevel < 2000) {
      aqi = 151 + _random.nextInt(49); level = 'Unhealthy'; color = const Color(0xFFFF5722);
      advice = 'Open windows for ventilation. Consider air purifier.'; icon = Icons.warning;
    } else {
      aqi = 201 + _random.nextInt(99); level = 'Hazardous'; color = const Color(0xFFF44336);
      advice = 'DANGER: Possible gas leak! Evacuate and ventilate!'; icon = Icons.dangerous;
    }

    _airQuality = AirQualityData(
      aqi: aqi, level: level, color: color, gasLevel: gasLevel.toDouble(),
      humidity: humidity, temperature: temp,
      co2: 350 + _random.nextDouble() * 300,
      voc: 100 + _random.nextDouble() * 200,
      pm25: 5 + _random.nextDouble() * 25,
      healthAdvice: advice, icon: icon,
    );
  }

  // ===== DEVICE HEALTH =====
  void _updateDeviceHealth() {
    final devices = ['ESP32 Node 1', 'Smart Light', 'AC Unit', 'Water Pump', 'Security Camera', 'Door Lock', 'Smart TV'];
    _healthReports = devices.map((name) {
      final score = 60 + _random.nextInt(41);
      String status;
      Color color;
      if (score >= 90) { status = 'Excellent'; color = const Color(0xFF4CAF50); }
      else if (score >= 75) { status = 'Good'; color = const Color(0xFF8BC34A); }
      else if (score >= 60) { status = 'Fair'; color = const Color(0xFFFF9800); }
      else { status = 'Poor'; color = const Color(0xFFF44336); }

      return DeviceHealthReport(
        deviceId: name.toLowerCase().replaceAll(' ', '_'), deviceName: name,
        healthScore: score, status: status, statusColor: color,
        uptime: 90 + _random.nextDouble() * 10, errorCount: _random.nextInt(5),
        lastMaintenance: DateTime.now().subtract(Duration(days: 30 + _random.nextInt(60))),
        nextMaintenance: DateTime.now().add(Duration(days: _random.nextInt(30))),
        issues: score < 80 ? ['Signal strength fluctuation', 'Occasional timeout'] : [],
        recommendations: ['Update firmware', 'Check power supply', 'Clean sensor'],
      );
    }).toList();
  }

  // ===== ACTIVITY LOG =====
  void _initActivityLog() {
    _activityLog = [
      ActivityLogEntry(id: 'a1', timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        action: 'Light Turned On', details: 'Living room light switched on manually', userId: 'u1', userName: 'Admin',
        category: ActivityCategory.device, icon: Icons.lightbulb, color: const Color(0xFFFF9800)),
      ActivityLogEntry(id: 'a2', timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        action: 'AC Temperature Set', details: 'AC temperature set to 24°C', userId: 'u1', userName: 'Admin',
        category: ActivityCategory.device, icon: Icons.ac_unit, color: const Color(0xFF2196F3)),
      ActivityLogEntry(id: 'a3', timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        action: 'Motion Detected', details: 'Motion detected in hallway', userId: 'system', userName: 'System',
        category: ActivityCategory.security, icon: Icons.directions_run, color: const Color(0xFFF44336)),
      ActivityLogEntry(id: 'a4', timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        action: 'Water Pump Auto-On', details: 'Water level below 15%, pump activated', userId: 'system', userName: 'Automation',
        category: ActivityCategory.automation, icon: Icons.water_drop, color: const Color(0xFF00BCD4)),
      ActivityLogEntry(id: 'a5', timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        action: 'Energy Alert', details: 'Power consumption exceeded 5kW threshold', userId: 'system', userName: 'System',
        category: ActivityCategory.sensor, icon: Icons.bolt, color: const Color(0xFFFF5722)),
      ActivityLogEntry(id: 'a6', timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        action: 'Schedule Triggered', details: 'Night Shutdown schedule executed', userId: 'system', userName: 'Scheduler',
        category: ActivityCategory.automation, icon: Icons.schedule, color: const Color(0xFF9C27B0)),
      ActivityLogEntry(id: 'a7', timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        action: 'User Login', details: 'Admin logged in from web', userId: 'u1', userName: 'Admin',
        category: ActivityCategory.user, icon: Icons.login, color: const Color(0xFF607D8B)),
      ActivityLogEntry(id: 'a8', timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        action: 'Firmware Updated', details: 'ESP32 Node 1 firmware updated to v1.0.1', userId: 'system', userName: 'System',
        category: ActivityCategory.system, icon: Icons.system_update, color: const Color(0xFF795548)),
    ];
  }

  void _addActivityLog(String action, String details, ActivityCategory category, IconData icon, Color color) {
    _activityLog.insert(0, ActivityLogEntry(
      id: 'a${_activityLog.length + 1}', timestamp: DateTime.now(),
      action: action, details: details, userId: 'u1', userName: 'Admin',
      category: category, icon: icon, color: color,
    ));
    if (_activityLog.length > 100) _activityLog.removeLast();
  }

  // ===== MAINTENANCE =====
  void _initMaintenanceTasks() {
    _maintenanceTasks = [
      MaintenanceTask(id: 'm1', title: 'Clean DHT22 Sensor', description: 'Remove dust from temperature sensor',
        deviceId: 'dht22', deviceName: 'DHT22 Sensor', dueDate: DateTime.now().add(const Duration(days: 3)),
        priority: MaintenancePriority.medium, icon: Icons.cleaning_services),
      MaintenanceTask(id: 'm2', title: 'Replace Water Filter', description: 'Water pump filter replacement',
        deviceId: 'pump', deviceName: 'Water Pump', dueDate: DateTime.now().add(const Duration(days: 7)),
        priority: MaintenancePriority.high, icon: Icons.water_drop),
      MaintenanceTask(id: 'm3', title: 'Calibrate Gas Sensor', description: 'MQ-2 gas sensor needs recalibration',
        deviceId: 'gas', deviceName: 'Gas Sensor', dueDate: DateTime.now().add(const Duration(days: 14)),
        priority: MaintenancePriority.critical, icon: Icons.gas_meter),
      MaintenanceTask(id: 'm4', title: 'Check Relay Contacts', description: 'Inspect relay for wear and arcing',
        deviceId: 'relay', deviceName: 'Relay Module', dueDate: DateTime.now().add(const Duration(days: 30)),
        priority: MaintenancePriority.low, icon: Icons.electrical_services),
      MaintenanceTask(id: 'm5', title: 'Update Camera Firmware', description: 'Security camera has pending update',
        deviceId: 'cam', deviceName: 'Security Camera', dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: MaintenancePriority.high, icon: Icons.videocam),
    ];
  }

  void toggleMaintenanceComplete(String id) {
    final idx = _maintenanceTasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      final task = _maintenanceTasks[idx];
      _maintenanceTasks[idx] = MaintenanceTask(
        id: task.id, title: task.title, description: task.description,
        deviceId: task.deviceId, deviceName: task.deviceName, dueDate: task.dueDate,
        priority: task.priority, isCompleted: !task.isCompleted, icon: task.icon,
      );
      _addActivityLog('Maintenance ${task.isCompleted ? "Reopened" : "Completed"}',
        '${task.title} marked as ${task.isCompleted ? "incomplete" : "done"}',
        ActivityCategory.system, Icons.build, const Color(0xFF607D8B));
      notifyListeners();
    }
  }

  // ===== FAVORITES =====
  void toggleFavorite(String id, String type, String name, IconData icon, Color color) {
    final existing = _favorites.indexWhere((f) => f.id == id && f.type == type);
    if (existing >= 0) {
      _favorites.removeAt(existing);
    } else {
      _favorites.add(FavoriteItem(id: id, type: type, name: name, icon: icon, color: color, addedAt: DateTime.now()));
    }
    notifyListeners();
  }

  bool isFavorite(String id, String type) => _favorites.any((f) => f.id == id && f.type == type);

  // ===== GEOFENCE =====
  void _initGeofenceRules() {
    _geofenceRules = [
      GeofenceRule(id: 'g1', name: 'Home Zone', latitude: 17.385, longitude: 78.4867,
        radiusMeters: 200, trigger: GeofenceTrigger.both,
        actions: [SceneAction(deviceId: 'ac_1', deviceName: 'AC', action: 'on')]),
      GeofenceRule(id: 'g2', name: 'Office Zone', latitude: 17.440, longitude: 78.350,
        radiusMeters: 500, trigger: GeofenceTrigger.onExit,
        actions: [SceneAction(deviceId: 'light_all', deviceName: 'All Lights', action: 'on')]),
    ];
  }

  void toggleGeofence(String id) {
    final rule = _geofenceRules.firstWhere((g) => g.id == id);
    rule.isEnabled = !rule.isEnabled;
    notifyListeners();
  }

  // ===== VACATION MODE =====
  void toggleVacationMode() {
    _vacationMode.isEnabled = !_vacationMode.isEnabled;
    if (_vacationMode.isEnabled) {
      _vacationMode.startDate = DateTime.now();
      _addActivityLog('Vacation Mode ON', 'Vacation mode activated - simulating presence',
        ActivityCategory.automation, Icons.flight_takeoff, const Color(0xFF9C27B0));
    } else {
      _vacationMode.endDate = DateTime.now();
      _addActivityLog('Vacation Mode OFF', 'Vacation mode deactivated',
        ActivityCategory.automation, Icons.flight_land, const Color(0xFF4CAF50));
    }
    notifyListeners();
  }

  // ===== SLEEP/WAKE =====
  void toggleSleepMode() {
    _sleepModeActive = !_sleepModeActive;
    if (_sleepModeActive) {
      _wakeModeActive = false;
      _addActivityLog('Sleep Mode', 'Sleep mode activated',
        ActivityCategory.automation, Icons.bedtime, const Color(0xFF3F51B5));
    }
    notifyListeners();
  }

  void toggleWakeMode() {
    _wakeModeActive = !_wakeModeActive;
    if (_wakeModeActive) {
      _sleepModeActive = false;
      _addActivityLog('Wake Mode', 'Wake-up routine started',
        ActivityCategory.automation, Icons.wb_sunny, const Color(0xFFFF9800));
    }
    notifyListeners();
  }

  // ===== GUEST MODE =====
  void toggleGuestMode() {
    _guestModeActive = !_guestModeActive;
    _addActivityLog('Guest Mode ${_guestModeActive ? "ON" : "OFF"}',
      'Guest access ${_guestModeActive ? "enabled" : "disabled"}',
      ActivityCategory.user, Icons.person_outline, const Color(0xFF00BCD4));
    notifyListeners();
  }

  // ===== EMERGENCY =====
  void triggerEmergency() {
    _emergencyActive = true;
    _addActivityLog('EMERGENCY', 'Emergency protocol activated!',
      ActivityCategory.security, Icons.emergency, const Color(0xFFF44336));
    notifyListeners();
  }

  void cancelEmergency() {
    _emergencyActive = false;
    _addActivityLog('Emergency Cancelled', 'Emergency protocol deactivated',
      ActivityCategory.security, Icons.check_circle, const Color(0xFF4CAF50));
    notifyListeners();
  }

  // ===== PARENTAL CONTROLS =====
  void toggleParentalControls() {
    _parentalControlsEnabled = !_parentalControlsEnabled;
    notifyListeners();
  }

  void toggleDeviceRestriction(String deviceId) {
    if (_restrictedDevices.contains(deviceId)) {
      _restrictedDevices.remove(deviceId);
    } else {
      _restrictedDevices.add(deviceId);
    }
    notifyListeners();
  }

  // ===== DOOR/WINDOW STATUS =====
  void _initDoorWindowStatus() {
    _doorWindowStatus = [
      DoorWindowStatus(id: 'dw1', name: 'Front Door', type: 'door', isOpen: false, isLocked: true, room: 'Entrance',
        icon: Icons.door_front_door, lastChanged: DateTime.now().subtract(const Duration(hours: 2))),
      DoorWindowStatus(id: 'dw2', name: 'Back Door', type: 'door', isOpen: false, isLocked: true, room: 'Kitchen',
        icon: Icons.door_back_door, lastChanged: DateTime.now().subtract(const Duration(hours: 5))),
      DoorWindowStatus(id: 'dw3', name: 'Living Room Window', type: 'window', isOpen: true, isLocked: false, room: 'Living Room',
        icon: Icons.window, lastChanged: DateTime.now().subtract(const Duration(minutes: 30))),
      DoorWindowStatus(id: 'dw4', name: 'Bedroom Window', type: 'window', isOpen: false, isLocked: true, room: 'Bedroom',
        icon: Icons.window, lastChanged: DateTime.now().subtract(const Duration(hours: 8))),
      DoorWindowStatus(id: 'dw5', name: 'Garage Door', type: 'door', isOpen: false, isLocked: true, room: 'Garage',
        icon: Icons.garage, lastChanged: DateTime.now().subtract(const Duration(hours: 12))),
    ];
  }

  void toggleDoorLock(String id) {
    final item = _doorWindowStatus.firstWhere((d) => d.id == id);
    item.isLocked = !item.isLocked;
    item.lastChanged = DateTime.now();
    _addActivityLog('${item.name} ${item.isLocked ? "Locked" : "Unlocked"}',
      '${item.name} ${item.isLocked ? "locked" : "unlocked"} remotely',
      ActivityCategory.security, item.icon, item.isLocked ? const Color(0xFF4CAF50) : const Color(0xFFF44336));
    notifyListeners();
  }

  // ===== ADAPTIVE THRESHOLDS =====
  void _initAdaptiveThresholds() {
    _adaptiveThresholds = {
      'temperature': AdaptiveThreshold(sensorType: 'Temperature', currentThreshold: 35.0,
        suggestedThreshold: 33.0, unit: '°C', learningProgress: 0.78, dataPoints: 2400),
      'humidity': AdaptiveThreshold(sensorType: 'Humidity', currentThreshold: 80.0,
        suggestedThreshold: 75.0, unit: '%', learningProgress: 0.65, dataPoints: 2400),
      'voltage': AdaptiveThreshold(sensorType: 'Voltage', currentThreshold: 250.0,
        suggestedThreshold: 245.0, unit: 'V', learningProgress: 0.82, dataPoints: 1800),
      'current': AdaptiveThreshold(sensorType: 'Current', currentThreshold: 15.0,
        suggestedThreshold: 12.0, unit: 'A', learningProgress: 0.71, dataPoints: 1800),
      'water_level': AdaptiveThreshold(sensorType: 'Water Level', currentThreshold: 15.0,
        suggestedThreshold: 20.0, unit: '%', learningProgress: 0.55, dataPoints: 900),
    };
  }

  void applyAdaptiveThreshold(String key) {
    final threshold = _adaptiveThresholds[key];
    if (threshold != null) {
      _adaptiveThresholds[key] = AdaptiveThreshold(
        sensorType: threshold.sensorType, currentThreshold: threshold.suggestedThreshold,
        suggestedThreshold: threshold.suggestedThreshold, unit: threshold.unit,
        learningProgress: threshold.learningProgress, dataPoints: threshold.dataPoints,
      );
      notifyListeners();
    }
  }

  // ===== ROOM OCCUPANCY =====
  void _updateRoomOccupancy() {
    final rooms = ['Living Room', 'Bedroom', 'Kitchen', 'Bathroom', 'Office', 'Garage', 'Garden'];
    _roomOccupancy = rooms.map((room) {
      final isOccupied = _random.nextBool();
      return RoomOccupancy(
        roomName: room, isOccupied: isOccupied,
        occupantCount: isOccupied ? 1 + _random.nextInt(3) : 0,
        lastMotion: DateTime.now().subtract(Duration(minutes: _random.nextInt(120))),
        occupancyPercent: 20 + _random.nextDouble() * 60,
        hourlyOccupancy: List.generate(24, (_) => _random.nextDouble() * 100),
      );
    }).toList();
  }

  // ===== APPLIANCE FINGERPRINTING =====
  void _updateFingerprints() {
    _fingerprints = [
      ApplianceFingerprint(name: 'Refrigerator', typicalPower: 150, currentPower: 145 + _random.nextDouble() * 20,
        status: 'Normal', statusColor: const Color(0xFF4CAF50), confidence: 0.95),
      ApplianceFingerprint(name: 'Air Conditioner', typicalPower: 1200, currentPower: 1150 + _random.nextDouble() * 100,
        status: 'Normal', statusColor: const Color(0xFF4CAF50), confidence: 0.92),
      ApplianceFingerprint(name: 'Washing Machine', typicalPower: 500, currentPower: 0,
        status: 'Off', statusColor: const Color(0xFF607D8B), confidence: 0.88),
      ApplianceFingerprint(name: 'Water Heater', typicalPower: 2000, currentPower: 1980 + _random.nextDouble() * 40,
        status: 'Running', statusColor: const Color(0xFFFF9800), confidence: 0.91),
      ApplianceFingerprint(name: 'Television', typicalPower: 120, currentPower: 115 + _random.nextDouble() * 10,
        status: 'Normal', statusColor: const Color(0xFF4CAF50), confidence: 0.97),
      ApplianceFingerprint(name: 'Unknown Device', typicalPower: 0, currentPower: 45 + _random.nextDouble() * 20,
        status: 'Unidentified', statusColor: const Color(0xFFF44336), confidence: 0.34),
    ];
  }

  // ===== LIVE DATA UPDATE =====
  void _updateLiveData() {
    final temp = 22 + _random.nextDouble() * 15;
    final humidity = 40 + _random.nextDouble() * 40;
    final gas = 200 + _random.nextInt(400);

    _updateComfortIndex(temp, humidity);
    _updateAirQuality(gas, humidity, temp);

    // Randomly update occupancy
    if (_random.nextInt(3) == 0) {
      _updateRoomOccupancy();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

// ===== Additional Models =====
class QuickRoutine {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> actions;
  bool isFavorite;
  DateTime? lastExecuted;
  int executionCount;

  QuickRoutine({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.actions,
    this.isFavorite = false,
    this.lastExecuted,
    this.executionCount = 0,
  });
}

class DoorWindowStatus {
  final String id;
  final String name;
  final String type;
  bool isOpen;
  bool isLocked;
  final String room;
  final IconData icon;
  DateTime lastChanged;

  DoorWindowStatus({
    required this.id,
    required this.name,
    required this.type,
    required this.isOpen,
    required this.isLocked,
    required this.room,
    required this.icon,
    required this.lastChanged,
  });
}

class AdaptiveThreshold {
  final String sensorType;
  final double currentThreshold;
  final double suggestedThreshold;
  final String unit;
  final double learningProgress;
  final int dataPoints;

  AdaptiveThreshold({
    required this.sensorType,
    required this.currentThreshold,
    required this.suggestedThreshold,
    required this.unit,
    required this.learningProgress,
    required this.dataPoints,
  });
}
