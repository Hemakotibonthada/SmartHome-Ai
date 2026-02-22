import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ========== FEATURE 66: Facial Recognition Access ==========
class FaceRecognitionEntry {
  final String id;
  final String personName;
  final DateTime timestamp;
  final String accessPoint;
  final bool isAuthorized;
  final double confidence;
  final String thumbnailUrl;
  final Color statusColor;

  bool get isKnown => isAuthorized;
  String get camera => accessPoint;
  String get accessLevel => isAuthorized ? 'Authorized' : 'Unknown';

  FaceRecognitionEntry({
    required this.id, required this.personName, required this.timestamp,
    required this.accessPoint, required this.isAuthorized,
    required this.confidence, this.thumbnailUrl = '',
    required this.statusColor,
  });
}

// ========== FEATURE 67: Intruder Detection ==========
class IntruderAlert {
  final String id;
  final DateTime timestamp;
  final String zone;
  final String detectionType; // Motion, Face, Sound, Perimeter
  final String severity; // Low, Medium, High, Critical
  final bool isActive;
  final String cameraFeed;
  final List<String> actionsTriggered;
  final Color severityColor;

  bool get isResolved => !isActive;
  String get alertType => detectionType;
  String get location => zone;
  String get camera => cameraFeed;
  String get threatLevel => severity;
  String get actionTaken => actionsTriggered.isNotEmpty ? actionsTriggered.join(', ') : '';

  IntruderAlert({
    required this.id, required this.timestamp, required this.zone,
    required this.detectionType, required this.severity,
    required this.isActive, this.cameraFeed = '',
    this.actionsTriggered = const [], required this.severityColor,
  });
}

// ========== FEATURE 68: Panic Button ==========
class PanicButtonState {
  final bool isTriggered;
  final DateTime? triggeredAt;
  final String? triggeredBy;
  final List<String> emergencyActions;
  final List<String> notifiedContacts;
  final bool silentMode;

  List<String> get emergencyContacts => notifiedContacts;

  PanicButtonState({
    this.isTriggered = false, this.triggeredAt, this.triggeredBy,
    this.emergencyActions = const [], this.notifiedContacts = const [],
    this.silentMode = false,
  });
}

// ========== FEATURE 69: Package Delivery ==========
class PackageDelivery {
  final String id;
  final DateTime timestamp;
  final String carrier;
  final String status; // Detected, Delivered, Collected, Missing
  final String location;
  final bool isCollected;
  final Color statusColor;

  String get trackingNumber => id.substring(0, 8).toUpperCase();
  String get deliveryLocation => location;

  PackageDelivery({
    required this.id, required this.timestamp, required this.carrier,
    required this.status, required this.location,
    this.isCollected = false, required this.statusColor,
  });
}

// ========== FEATURE 70: Visitor Log ==========
class VisitorEntry {
  final String id;
  final String name;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final String purpose;
  final String accessMethod; // Doorbell, Key, Code, Face
  final bool isApproved;

  bool get isAllowed => isApproved;
  String get entryPoint => accessMethod;

  VisitorEntry({
    required this.id, required this.name, required this.arrivalTime,
    this.departureTime, required this.purpose,
    required this.accessMethod, this.isApproved = true,
  });
}

// ========== FEATURE 71: Fire Evacuation ==========
class EvacuationRoute {
  final String id;
  final String name;
  final List<String> waypoints;
  final String exitPoint;
  final bool isActive;
  final int estimatedSeconds;
  final Color routeColor;

  bool get isClear => isActive;
  List<String> get path => waypoints;
  int get estimatedTime => estimatedSeconds;

  EvacuationRoute({
    required this.id, required this.name, required this.waypoints,
    required this.exitPoint, this.isActive = false,
    required this.estimatedSeconds, required this.routeColor,
  });
}

// ========== FEATURE 72: Flood Detection ==========
class FloodSensor {
  final String id;
  final String location;
  final bool isDetected;
  final double waterLevel; // mm
  final DateTime lastChecked;
  final String status; // Normal, Warning, Alert, Critical
  final Color statusColor;

  bool get isAlarm => isDetected;
  double get humidity => 65.0;

  FloodSensor({
    required this.id, required this.location, required this.isDetected,
    required this.waterLevel, required this.lastChecked,
    required this.status, required this.statusColor,
  });
}

// ========== FEATURE 73: Security Camera Analytics ==========
class CameraAnalytics {
  final String cameraId;
  final String cameraName;
  final String location;
  final int personsDetected;
  final int vehiclesDetected;
  final int motionEvents;
  final double storageUsed; // GB
  final bool isRecording;
  final String quality; // 1080p, 4K, etc
  final double uptime;

  int get peopleCount => personsDetected;
  int get vehicleCount => vehiclesDetected;
  int get animalCount => 0;

  CameraAnalytics({
    required this.cameraId, required this.cameraName,
    required this.location, required this.personsDetected,
    required this.vehiclesDetected, required this.motionEvents,
    required this.storageUsed, required this.isRecording,
    required this.quality, required this.uptime,
  });
}

// ========== FEATURE 74: Access Control Timeline ==========
class AccessEvent {
  final String id;
  final DateTime timestamp;
  final String personName;
  final String accessPoint;
  final String action; // Entry, Exit, Denied, Override
  final String method; // Key, Code, Biometric, Remote
  final Color actionColor;

  bool get wasGranted => action != 'Denied';
  String get userName => personName;
  String get location => accessPoint;

  AccessEvent({
    required this.id, required this.timestamp, required this.personName,
    required this.accessPoint, required this.action,
    required this.method, required this.actionColor,
  });
}

// ========== FEATURE 75: Perimeter Security ==========
class PerimeterZone {
  final String id;
  final String name;
  final String type; // Fence, Gate, Wall, Virtual
  final bool isArmed;
  final bool isBreached;
  final String sensorType; // IR, Vibration, Camera, Laser
  final double length; // meters
  final Color statusColor;

  int get sensitivity => 85;

  PerimeterZone({
    required this.id, required this.name, required this.type,
    required this.isArmed, this.isBreached = false,
    required this.sensorType, required this.length,
    required this.statusColor,
  });
}

// ========== FEATURE 76: Neighborhood Safety ==========
class NeighborhoodAlert {
  final String id;
  final DateTime timestamp;
  final String alertType; // Crime, Accident, Weather, Utility
  final String description;
  final String severity;
  final double distance; // km
  final Color alertColor;

  IconData get icon {
    switch (alertType) {
      case 'Crime': return Icons.warning;
      case 'Accident': return Icons.car_crash;
      case 'Weather': return Icons.thunderstorm;
      case 'Utility': return Icons.construction;
      default: return Icons.info;
    }
  }
  Color get color => alertColor;
  String get reportedBy => severity;

  NeighborhoodAlert({
    required this.id, required this.timestamp, required this.alertType,
    required this.description, required this.severity,
    required this.distance, required this.alertColor,
  });
}

// ========== FEATURE 77: Rainwater Harvesting ==========
class RainwaterSystem {
  final double tankLevel; // 0-100%
  final double tankCapacity; // liters
  final double todayCollected; // liters
  final double monthlyCollected;
  final double yearlyCollected;
  final bool isCollecting;
  final double flowRate; // liters/min
  final String filterStatus;
  final double waterSavedCost;

  Color get tankColor => tankLevel > 70 ? const Color(0xFF4CAF50) : tankLevel > 30 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  double get currentVolume => tankCapacity * tankLevel / 100;
  double get totalSaved => waterSavedCost;
  double get waterQualityPh => 7.2;
  String get pumpStatus => isCollecting ? 'Active' : 'Idle';

  RainwaterSystem({
    required this.tankLevel, required this.tankCapacity,
    required this.todayCollected, required this.monthlyCollected,
    required this.yearlyCollected, required this.isCollecting,
    required this.flowRate, required this.filterStatus,
    required this.waterSavedCost,
  });
}

// ========== FEATURE 78: Carbon Tracking ==========
class CarbonTrackingData {
  final double dailyEmissions; // kg CO2
  final double weeklyEmissions;
  final double monthlyEmissions;
  final double yearlyEmissions;
  final double target; // monthly target
  final List<CarbonSource> sources;
  final double offsetCredits;
  final String ecoRating; // A, B, C, D, F
  final Color ratingColor;

  double get todayEmissions => dailyEmissions;
  Color get emissionColor => dailyEmissions < 5 ? const Color(0xFF4CAF50) : dailyEmissions < 10 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  double get totalOffset => offsetCredits;
  int get treesEquivalent => (offsetCredits / 22).round();

  CarbonTrackingData({
    required this.dailyEmissions, required this.weeklyEmissions,
    required this.monthlyEmissions, required this.yearlyEmissions,
    required this.target, required this.sources,
    required this.offsetCredits, required this.ecoRating,
    required this.ratingColor,
  });
}

class CarbonSource {
  final String name;
  final double emissions; // kg
  final double percentage;
  final IconData icon;
  final Color color;

  CarbonSource({
    required this.name, required this.emissions, required this.percentage,
    required this.icon, required this.color,
  });
}

// ========== FEATURE 79: Green Energy Score ==========
class GreenEnergyScore {
  final int score; // 0-100
  final String grade; // A+, A, B, C, D, F
  final double renewablePercent;
  final double gridPercent;
  final double solarContribution;
  final double windContribution;
  final double batteryContribution;
  final List<GreenTip> tips;
  final Color gradeColor;

  Color get scoreColor => gradeColor;
  double get renewablePercentage => renewablePercent;
  double get solarGeneration => solarContribution;
  double get gridReduction => 100 - gridPercent;

  GreenEnergyScore({
    required this.score, required this.grade,
    required this.renewablePercent, required this.gridPercent,
    required this.solarContribution, required this.windContribution,
    required this.batteryContribution, this.tips = const [],
    required this.gradeColor,
  });
}

class GreenTip {
  final String title;
  final String description;
  final String impact;
  final IconData icon;

  String get tip => description;
  Color get impactColor => impact == 'High' ? const Color(0xFF4CAF50) : impact == 'Medium' ? const Color(0xFFFF9800) : const Color(0xFF2196F3);

  GreenTip({required this.title, required this.description, required this.impact, required this.icon});
}

// ========== FEATURE 80: Network Health ==========
class NetworkHealthData {
  final double downloadSpeed;
  final double uploadSpeed;
  final int latency;
  final int connectedDevices;
  final double bandwidth; // Mbps total
  final double bandwidthUsed;
  final String routerStatus;
  final double wifiSignalStrength;
  final List<NetworkDevice> devices;
  final Color healthColor;

  Color get latencyColor => latency < 20 ? const Color(0xFF4CAF50) : latency < 50 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  String get uptime => '99.8%';
  String get routerModel => routerStatus;
  String get wifiBand => '${wifiSignalStrength.toStringAsFixed(0)} dBm';

  NetworkHealthData({
    required this.downloadSpeed, required this.uploadSpeed,
    required this.latency, required this.connectedDevices,
    required this.bandwidth, required this.bandwidthUsed,
    required this.routerStatus, required this.wifiSignalStrength,
    this.devices = const [], required this.healthColor,
  });
}

class NetworkDevice {
  final String name;
  final String ip;
  final String mac;
  final double bandwidth;
  final bool isOnline;
  final String type;

  String get ipAddress => ip;

  NetworkDevice({
    required this.name, required this.ip, required this.mac,
    required this.bandwidth, required this.isOnline,
    required this.type,
  });
}

// ========== FEATURE 81: Family Profiles ==========
class FamilyMember {
  final String id;
  final String name;
  final String role; // Admin, Adult, Child, Guest
  final String avatarInitial;
  final Color avatarColor;
  final bool isHome;
  final DateTime? lastSeen;
  final List<String> permissions;
  final Map<String, bool> deviceAccess;

  String get currentRoom => 'Living Room';
  bool get hasGeofence => permissions.contains('geofence');
  bool get hasFaceRecognition => permissions.contains('face');
  bool get hasAppAccess => permissions.contains('app');
  int get devicesAllowed => deviceAccess.values.where((v) => v).length;

  FamilyMember({
    required this.id, required this.name, required this.role,
    required this.avatarInitial, required this.avatarColor,
    this.isHome = false, this.lastSeen,
    this.permissions = const [], this.deviceAccess = const {},
  });
}

// ========== FEATURE 82: Firmware Manager ==========
class FirmwareDevice {
  final String deviceId;
  final String deviceName;
  final String currentVersion;
  final String latestVersion;
  final bool updateAvailable;
  final String status; // Up to date, Update Available, Updating, Error
  final double updateProgress;
  final DateTime lastUpdated;
  final Color statusColor;

  String get id => deviceId;
  bool get hasUpdate => updateAvailable;
  bool get isUpdating => status == 'Updating';
  IconData get statusIcon {
    if (isUpdating) return Icons.system_update;
    if (hasUpdate) return Icons.download;
    return Icons.check_circle;
  }

  FirmwareDevice({
    required this.deviceId, required this.deviceName,
    required this.currentVersion, required this.latestVersion,
    required this.updateAvailable, required this.status,
    this.updateProgress = 0, required this.lastUpdated,
    required this.statusColor,
  });
}

// ========== FEATURE 83: Smart Home Score ==========
class SmartHomeScore {
  final int overallScore; // 0-100
  final int securityScore;
  final int energyScore;
  final int automationScore;
  final int comfortScore;
  final int connectivityScore;
  final String grade;
  final Color gradeColor;
  final List<ScoreImprovement> improvements;

  Color get scoreColor => gradeColor;
  int get rank => 100 - overallScore;

  SmartHomeScore({
    required this.overallScore, required this.securityScore,
    required this.energyScore, required this.automationScore,
    required this.comfortScore, required this.connectivityScore,
    required this.grade, required this.gradeColor,
    this.improvements = const [],
  });
}

class ScoreImprovement {
  final String area;
  final String suggestion;
  final int pointsGain;
  final IconData icon;

  Color get impactColor => pointsGain > 10 ? const Color(0xFF4CAF50) : pointsGain > 5 ? const Color(0xFFFF9800) : const Color(0xFF2196F3);

  ScoreImprovement({required this.area, required this.suggestion, required this.pointsGain, required this.icon});
}

// ========== FEATURE 84: Energy Audit ==========
class EnergyAuditReport {
  final DateTime generatedAt;
  final double totalConsumption;
  final double estimatedWaste;
  final double potentialSavings;
  final String efficiencyGrade;
  final List<AuditFinding> findings;
  final List<AuditRecommendation> recommendations;
  final Color gradeColor;

  String get grade => efficiencyGrade;
  double get monthlyCost => totalConsumption * 0.12;
  double get efficiencyScore => totalConsumption > 0 ? ((1 - estimatedWaste / totalConsumption) * 100).clamp(0, 100) : 100;
  Color get efficiencyColor => efficiencyScore > 80 ? const Color(0xFF4CAF50) : efficiencyScore > 60 ? const Color(0xFFFF9800) : const Color(0xFFF44336);

  EnergyAuditReport({
    required this.generatedAt, required this.totalConsumption,
    required this.estimatedWaste, required this.potentialSavings,
    required this.efficiencyGrade, this.findings = const [],
    this.recommendations = const [], required this.gradeColor,
  });
}

class AuditFinding {
  final String area;
  final String finding;
  final String severity;
  final double wastage;
  final Color color;

  bool get isPositive => severity == 'Good';

  AuditFinding({required this.area, required this.finding, required this.severity, required this.wastage, required this.color});
}

class AuditRecommendation {
  final String title;
  final String description;
  final double savings;
  final String paybackPeriod;
  final IconData icon;

  String get recommendation => description;
  double get estimatedSavings => savings;
  String get roiMonths => paybackPeriod;

  AuditRecommendation({required this.title, required this.description, required this.savings, required this.paybackPeriod, required this.icon});
}

// ========== FEATURE 85: Service Provider Directory ==========
class ServiceProvider {
  final String id;
  final String name;
  final String category; // Electrician, Plumber, HVAC, Security, Cleaning
  final double rating;
  final String phone;
  final String email;
  final bool isAvailable;
  final double distanceKm;
  final Color categoryColor;

  String get specialty => category;
  IconData get icon {
    switch (category.toLowerCase()) {
      case 'electrician': return Icons.electric_bolt;
      case 'plumber': return Icons.plumbing;
      case 'hvac': return Icons.hvac;
      case 'security': return Icons.security;
      case 'cleaning': return Icons.cleaning_services;
      default: return Icons.build;
    }
  }

  ServiceProvider({
    required this.id, required this.name, required this.category,
    required this.rating, required this.phone, required this.email,
    required this.isAvailable, required this.distanceKm,
    required this.categoryColor,
  });
}

// ========== SECURITY & LIFESTYLE SERVICE ==========
class SecurityLifestyleService extends ChangeNotifier {
  final Random _random = Random();
  Timer? _updateTimer;

  // Feature 66: Face Recognition
  List<FaceRecognitionEntry> _faceRecognitions = [];
  List<FaceRecognitionEntry> get faceRecognitions => _faceRecognitions;

  // Feature 67: Intruder Detection
  List<IntruderAlert> _intruderAlerts = [];
  List<IntruderAlert> get intruderAlerts => _intruderAlerts;

  // Feature 68: Panic Button
  PanicButtonState _panicButton = PanicButtonState();
  PanicButtonState get panicButton => _panicButton;

  // Feature 69: Package Delivery
  List<PackageDelivery> _packages = [];
  List<PackageDelivery> get packages => _packages;

  // Feature 70: Visitor Log
  List<VisitorEntry> _visitors = [];
  List<VisitorEntry> get visitors => _visitors;

  // Feature 71: Evacuation Routes
  List<EvacuationRoute> _evacuationRoutes = [];
  List<EvacuationRoute> get evacuationRoutes => _evacuationRoutes;

  // Feature 72: Flood Sensors
  List<FloodSensor> _floodSensors = [];
  List<FloodSensor> get floodSensors => _floodSensors;

  // Feature 73: Camera Analytics
  List<CameraAnalytics> _cameraAnalytics = [];
  List<CameraAnalytics> get cameraAnalytics => _cameraAnalytics;

  // Feature 74: Access Events
  List<AccessEvent> _accessEvents = [];
  List<AccessEvent> get accessEvents => _accessEvents;

  // Feature 75: Perimeter
  List<PerimeterZone> _perimeterZones = [];
  List<PerimeterZone> get perimeterZones => _perimeterZones;

  // Feature 76: Neighborhood Alerts
  List<NeighborhoodAlert> _neighborhoodAlerts = [];
  List<NeighborhoodAlert> get neighborhoodAlerts => _neighborhoodAlerts;

  // Feature 77: Rainwater
  RainwaterSystem? _rainwater;
  RainwaterSystem? get rainwater => _rainwater;

  // Feature 78: Carbon Tracking
  CarbonTrackingData? _carbonTracking;
  CarbonTrackingData? get carbonTracking => _carbonTracking;

  // Feature 79: Green Energy
  GreenEnergyScore? _greenScore;
  GreenEnergyScore? get greenScore => _greenScore;

  // Feature 80: Network Health
  NetworkHealthData? _networkHealth;
  NetworkHealthData? get networkHealth => _networkHealth;

  // Feature 81: Family Profiles
  List<FamilyMember> _familyMembers = [];
  List<FamilyMember> get familyMembers => _familyMembers;

  // Feature 82: Firmware Manager
  List<FirmwareDevice> _firmwareDevices = [];
  List<FirmwareDevice> get firmwareDevices => _firmwareDevices;

  // Feature 83: Smart Home Score
  SmartHomeScore? _homeScore;
  SmartHomeScore? get homeScore => _homeScore;

  // Feature 84: Energy Audit
  EnergyAuditReport? _energyAudit;
  EnergyAuditReport? get energyAudit => _energyAudit;

  // Feature 85: Service Providers
  List<ServiceProvider> _serviceProviders = [];
  List<ServiceProvider> get serviceProviders => _serviceProviders;

  SecurityLifestyleService() {
    _initializeAll();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateLiveData());
  }

  void _initializeAll() {
    _initFaceRecognition();
    _initIntruderAlerts();
    _initPackages();
    _initVisitors();
    _initEvacuationRoutes();
    _initFloodSensors();
    _initCameraAnalytics();
    _initAccessEvents();
    _initPerimeter();
    _initNeighborhoodAlerts();
    _initRainwater();
    _initCarbonTracking();
    _initGreenScore();
    _initNetworkHealth();
    _initFamilyMembers();
    _initFirmwareDevices();
    _initHomeScore();
    _initEnergyAudit();
    _initServiceProviders();
  }

  void _initFaceRecognition() {
    _faceRecognitions = [
      FaceRecognitionEntry(id: 'fr1', personName: 'Admin', timestamp: DateTime.now().subtract(const Duration(hours: 1)), accessPoint: 'Front Door', isAuthorized: true, confidence: 0.97, statusColor: const Color(0xFF4CAF50)),
      FaceRecognitionEntry(id: 'fr2', personName: 'Family Member', timestamp: DateTime.now().subtract(const Duration(hours: 3)), accessPoint: 'Garage', isAuthorized: true, confidence: 0.94, statusColor: const Color(0xFF4CAF50)),
      FaceRecognitionEntry(id: 'fr3', personName: 'Unknown', timestamp: DateTime.now().subtract(const Duration(hours: 5)), accessPoint: 'Front Door', isAuthorized: false, confidence: 0.45, statusColor: const Color(0xFFF44336)),
      FaceRecognitionEntry(id: 'fr4', personName: 'Delivery Person', timestamp: DateTime.now().subtract(const Duration(hours: 8)), accessPoint: 'Front Gate', isAuthorized: false, confidence: 0.82, statusColor: const Color(0xFFFF9800)),
    ];
  }

  void _initIntruderAlerts() {
    _intruderAlerts = [
      IntruderAlert(id: 'ia1', timestamp: DateTime.now().subtract(const Duration(days: 2)), zone: 'Backyard', detectionType: 'Motion', severity: 'Low', isActive: false, actionsTriggered: ['Camera recording started', 'Floodlight ON'], severityColor: const Color(0xFFFF9800)),
      IntruderAlert(id: 'ia2', timestamp: DateTime.now().subtract(const Duration(days: 5)), zone: 'Front Porch', detectionType: 'Person', severity: 'Medium', isActive: false, actionsTriggered: ['Alert sent', 'Camera recording', 'Siren warning'], severityColor: const Color(0xFFF44336)),
    ];
  }

  void _initPackages() {
    _packages = [
      PackageDelivery(id: 'pkg1', timestamp: DateTime.now().subtract(const Duration(hours: 2)), carrier: 'Amazon', status: 'Delivered', location: 'Front Porch', statusColor: const Color(0xFF4CAF50)),
      PackageDelivery(id: 'pkg2', timestamp: DateTime.now().subtract(const Duration(hours: 6)), carrier: 'FedEx', status: 'Collected', location: 'Front Door', isCollected: true, statusColor: const Color(0xFF2196F3)),
      PackageDelivery(id: 'pkg3', timestamp: DateTime.now().subtract(const Duration(days: 1)), carrier: 'DHL', status: 'Collected', location: 'Mailbox', isCollected: true, statusColor: const Color(0xFF2196F3)),
    ];
  }

  void _initVisitors() {
    _visitors = [
      VisitorEntry(id: 'v1', name: 'John (Friend)', arrivalTime: DateTime.now().subtract(const Duration(hours: 2)), departureTime: DateTime.now().subtract(const Duration(hours: 1)), purpose: 'Social Visit', accessMethod: 'Doorbell'),
      VisitorEntry(id: 'v2', name: 'Plumber', arrivalTime: DateTime.now().subtract(const Duration(days: 1)), departureTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 2)), purpose: 'Maintenance', accessMethod: 'Code'),
      VisitorEntry(id: 'v3', name: 'Courier', arrivalTime: DateTime.now().subtract(const Duration(hours: 6)), purpose: 'Delivery', accessMethod: 'Doorbell'),
    ];
  }

  void _initEvacuationRoutes() {
    _evacuationRoutes = [
      EvacuationRoute(id: 'er1', name: 'Primary Exit', waypoints: ['Room → Hallway', 'Hallway → Front Door', 'Front Door → Assembly Point'], exitPoint: 'Front Door', estimatedSeconds: 45, routeColor: const Color(0xFF4CAF50)),
      EvacuationRoute(id: 'er2', name: 'Secondary Exit', waypoints: ['Room → Kitchen', 'Kitchen → Back Door', 'Back Door → Garden'], exitPoint: 'Back Door', estimatedSeconds: 55, routeColor: const Color(0xFFFF9800)),
      EvacuationRoute(id: 'er3', name: 'Emergency Exit', waypoints: ['Room → Window', 'Window → Ground', 'Ground → Assembly Point'], exitPoint: 'Bedroom Window', estimatedSeconds: 30, routeColor: const Color(0xFFF44336)),
    ];
  }

  void _initFloodSensors() {
    _floodSensors = [
      FloodSensor(id: 'fs1', location: 'Basement', isDetected: false, waterLevel: 0, lastChecked: DateTime.now(), status: 'Normal', statusColor: const Color(0xFF4CAF50)),
      FloodSensor(id: 'fs2', location: 'Bathroom', isDetected: false, waterLevel: 0, lastChecked: DateTime.now(), status: 'Normal', statusColor: const Color(0xFF4CAF50)),
      FloodSensor(id: 'fs3', location: 'Kitchen Sink', isDetected: false, waterLevel: 0, lastChecked: DateTime.now(), status: 'Normal', statusColor: const Color(0xFF4CAF50)),
      FloodSensor(id: 'fs4', location: 'Laundry Room', isDetected: false, waterLevel: 0, lastChecked: DateTime.now(), status: 'Normal', statusColor: const Color(0xFF4CAF50)),
    ];
  }

  void _initCameraAnalytics() {
    _cameraAnalytics = [
      CameraAnalytics(cameraId: 'cam1', cameraName: 'Front Door Cam', location: 'Entrance', personsDetected: 12, vehiclesDetected: 5, motionEvents: 45, storageUsed: 12.5, isRecording: true, quality: '4K', uptime: 99.8),
      CameraAnalytics(cameraId: 'cam2', cameraName: 'Backyard Cam', location: 'Garden', personsDetected: 3, vehiclesDetected: 0, motionEvents: 28, storageUsed: 8.2, isRecording: true, quality: '1080p', uptime: 99.5),
      CameraAnalytics(cameraId: 'cam3', cameraName: 'Garage Cam', location: 'Garage', personsDetected: 2, vehiclesDetected: 8, motionEvents: 15, storageUsed: 6.1, isRecording: true, quality: '1080p', uptime: 98.2),
      CameraAnalytics(cameraId: 'cam4', cameraName: 'Indoor Cam', location: 'Living Room', personsDetected: 24, vehiclesDetected: 0, motionEvents: 67, storageUsed: 15.3, isRecording: false, quality: '1080p', uptime: 95.0),
    ];
  }

  void _initAccessEvents() {
    _accessEvents = [
      AccessEvent(id: 'ae1', timestamp: DateTime.now().subtract(const Duration(hours: 1)), personName: 'Admin', accessPoint: 'Front Door', action: 'Entry', method: 'Biometric', actionColor: const Color(0xFF4CAF50)),
      AccessEvent(id: 'ae2', timestamp: DateTime.now().subtract(const Duration(hours: 3)), personName: 'Family', accessPoint: 'Garage', action: 'Entry', method: 'Remote', actionColor: const Color(0xFF4CAF50)),
      AccessEvent(id: 'ae3', timestamp: DateTime.now().subtract(const Duration(hours: 5)), personName: 'Unknown', accessPoint: 'Front Door', action: 'Denied', method: 'Code', actionColor: const Color(0xFFF44336)),
      AccessEvent(id: 'ae4', timestamp: DateTime.now().subtract(const Duration(hours: 8)), personName: 'Admin', accessPoint: 'Front Door', action: 'Exit', method: 'Key', actionColor: const Color(0xFF2196F3)),
      AccessEvent(id: 'ae5', timestamp: DateTime.now().subtract(const Duration(hours: 12)), personName: 'Guest', accessPoint: 'Side Door', action: 'Entry', method: 'Code', actionColor: const Color(0xFFFF9800)),
    ];
  }

  void _initPerimeter() {
    _perimeterZones = [
      PerimeterZone(id: 'pz1', name: 'North Fence', type: 'Fence', isArmed: true, sensorType: 'Vibration', length: 25, statusColor: const Color(0xFF4CAF50)),
      PerimeterZone(id: 'pz2', name: 'South Wall', type: 'Wall', isArmed: true, sensorType: 'IR', length: 20, statusColor: const Color(0xFF4CAF50)),
      PerimeterZone(id: 'pz3', name: 'Front Gate', type: 'Gate', isArmed: true, sensorType: 'Camera', length: 5, statusColor: const Color(0xFF4CAF50)),
      PerimeterZone(id: 'pz4', name: 'Garden Virtual', type: 'Virtual', isArmed: false, sensorType: 'Laser', length: 30, statusColor: const Color(0xFF607D8B)),
    ];
  }

  void _initNeighborhoodAlerts() {
    _neighborhoodAlerts = [
      NeighborhoodAlert(id: 'na1', timestamp: DateTime.now().subtract(const Duration(hours: 4)), alertType: 'Weather', description: 'Heavy rainfall warning for next 3 hours', severity: 'Medium', distance: 0, alertColor: const Color(0xFF2196F3)),
      NeighborhoodAlert(id: 'na2', timestamp: DateTime.now().subtract(const Duration(days: 1)), alertType: 'Utility', description: 'Scheduled power outage tomorrow 2 PM - 5 PM', severity: 'Low', distance: 0.5, alertColor: const Color(0xFFFF9800)),
      NeighborhoodAlert(id: 'na3', timestamp: DateTime.now().subtract(const Duration(days: 3)), alertType: 'Crime', description: 'Vehicle break-in reported on neighboring street', severity: 'High', distance: 0.3, alertColor: const Color(0xFFF44336)),
    ];
  }

  void _initRainwater() {
    _rainwater = RainwaterSystem(
      tankLevel: 62, tankCapacity: 5000, todayCollected: 45,
      monthlyCollected: 850, yearlyCollected: 12500, isCollecting: false,
      flowRate: 0, filterStatus: 'Clean', waterSavedCost: 2500,
    );
  }

  void _initCarbonTracking() {
    _carbonTracking = CarbonTrackingData(
      dailyEmissions: 8.5, weeklyEmissions: 55, monthlyEmissions: 220,
      yearlyEmissions: 2650, target: 200,
      sources: [
        CarbonSource(name: 'Electricity', emissions: 120, percentage: 55, icon: Icons.bolt, color: const Color(0xFFFF9800)),
        CarbonSource(name: 'Heating/Cooling', emissions: 50, percentage: 23, icon: Icons.thermostat, color: const Color(0xFF2196F3)),
        CarbonSource(name: 'Water Heating', emissions: 25, percentage: 11, icon: Icons.hot_tub, color: const Color(0xFFF44336)),
        CarbonSource(name: 'Appliances', emissions: 15, percentage: 7, icon: Icons.kitchen, color: const Color(0xFF4CAF50)),
        CarbonSource(name: 'EV Charging', emissions: 10, percentage: 4, icon: Icons.ev_station, color: const Color(0xFF9C27B0)),
      ],
      offsetCredits: 50, ecoRating: 'B', ratingColor: const Color(0xFF8BC34A),
    );
  }

  void _initGreenScore() {
    _greenScore = GreenEnergyScore(
      score: 72, grade: 'B+', renewablePercent: 45, gridPercent: 55,
      solarContribution: 35, windContribution: 5, batteryContribution: 5,
      gradeColor: const Color(0xFF8BC34A),
      tips: [
        GreenTip(title: 'Add Battery Storage', description: 'Store excess solar energy for night use', impact: '+15 points', icon: Icons.battery_charging_full),
        GreenTip(title: 'Upgrade to LED', description: 'Replace remaining CFL bulbs with LEDs', impact: '+5 points', icon: Icons.lightbulb),
        GreenTip(title: 'Smart Scheduling', description: 'Run heavy appliances during solar peak', impact: '+8 points', icon: Icons.schedule),
      ],
    );
  }

  void _initNetworkHealth() {
    _networkHealth = NetworkHealthData(
      downloadSpeed: 150 + _random.nextDouble() * 50, uploadSpeed: 50 + _random.nextDouble() * 20,
      latency: 5 + _random.nextInt(15), connectedDevices: 24,
      bandwidth: 200, bandwidthUsed: 85 + _random.nextDouble() * 30,
      routerStatus: 'Online', wifiSignalStrength: 75 + _random.nextDouble() * 20,
      healthColor: const Color(0xFF4CAF50),
      devices: [
        NetworkDevice(name: 'Smart TV', ip: '192.168.1.10', mac: 'AA:BB:CC:DD:EE:01', bandwidth: 15.5, isOnline: true, type: 'Entertainment'),
        NetworkDevice(name: 'ESP32 Node 1', ip: '192.168.1.20', mac: 'AA:BB:CC:DD:EE:02', bandwidth: 0.5, isOnline: true, type: 'IoT'),
        NetworkDevice(name: 'Security Camera', ip: '192.168.1.30', mac: 'AA:BB:CC:DD:EE:03', bandwidth: 8.2, isOnline: true, type: 'Security'),
        NetworkDevice(name: 'Robot Vacuum', ip: '192.168.1.40', mac: 'AA:BB:CC:DD:EE:04', bandwidth: 0.3, isOnline: true, type: 'IoT'),
        NetworkDevice(name: 'Laptop', ip: '192.168.1.50', mac: 'AA:BB:CC:DD:EE:05', bandwidth: 25.0, isOnline: true, type: 'Computer'),
        NetworkDevice(name: 'Phone', ip: '192.168.1.51', mac: 'AA:BB:CC:DD:EE:06', bandwidth: 12.0, isOnline: true, type: 'Mobile'),
      ],
    );
  }

  void _initFamilyMembers() {
    _familyMembers = [
      FamilyMember(id: 'fm1', name: 'Admin', role: 'Admin', avatarInitial: 'A', avatarColor: const Color(0xFF6C63FF), isHome: true, lastSeen: DateTime.now(), permissions: ['All'], deviceAccess: {'all': true}),
      FamilyMember(id: 'fm2', name: 'Spouse', role: 'Adult', avatarInitial: 'S', avatarColor: const Color(0xFFFF6584), isHome: true, lastSeen: DateTime.now(), permissions: ['Devices', 'Scenes', 'Security']),
      FamilyMember(id: 'fm3', name: 'Child 1', role: 'Child', avatarInitial: 'K', avatarColor: const Color(0xFF4CAF50), isHome: true, lastSeen: DateTime.now(), permissions: ['Limited Devices'], deviceAccess: {'tv': true, 'light': true, 'speaker': true}),
      FamilyMember(id: 'fm4', name: 'Guest', role: 'Guest', avatarInitial: 'G', avatarColor: const Color(0xFF607D8B), isHome: false, lastSeen: DateTime.now().subtract(const Duration(days: 3)), permissions: ['Basic']),
    ];
  }

  void _initFirmwareDevices() {
    _firmwareDevices = [
      FirmwareDevice(deviceId: 'fw1', deviceName: 'ESP32 Main Node', currentVersion: 'v1.0.1', latestVersion: 'v1.0.3', updateAvailable: true, status: 'Update Available', lastUpdated: DateTime.now().subtract(const Duration(days: 30)), statusColor: const Color(0xFFFF9800)),
      FirmwareDevice(deviceId: 'fw2', deviceName: 'Smart Lock', currentVersion: 'v2.1.0', latestVersion: 'v2.1.0', updateAvailable: false, status: 'Up to date', lastUpdated: DateTime.now().subtract(const Duration(days: 7)), statusColor: const Color(0xFF4CAF50)),
      FirmwareDevice(deviceId: 'fw3', deviceName: 'Security Camera', currentVersion: 'v3.5.2', latestVersion: 'v3.6.0', updateAvailable: true, status: 'Update Available', lastUpdated: DateTime.now().subtract(const Duration(days: 45)), statusColor: const Color(0xFFFF9800)),
      FirmwareDevice(deviceId: 'fw4', deviceName: 'Smart Thermostat', currentVersion: 'v1.2.0', latestVersion: 'v1.2.0', updateAvailable: false, status: 'Up to date', lastUpdated: DateTime.now().subtract(const Duration(days: 14)), statusColor: const Color(0xFF4CAF50)),
      FirmwareDevice(deviceId: 'fw5', deviceName: 'Robot Vacuum', currentVersion: 'v4.0.1', latestVersion: 'v4.1.0', updateAvailable: true, status: 'Update Available', lastUpdated: DateTime.now().subtract(const Duration(days: 60)), statusColor: const Color(0xFFFF9800)),
    ];
  }

  void _initHomeScore() {
    _homeScore = SmartHomeScore(
      overallScore: 78, securityScore: 85, energyScore: 72,
      automationScore: 80, comfortScore: 76, connectivityScore: 82,
      grade: 'B+', gradeColor: const Color(0xFF8BC34A),
      improvements: [
        ScoreImprovement(area: 'Energy', suggestion: 'Install smart power strips for standby reduction', pointsGain: 5, icon: Icons.power),
        ScoreImprovement(area: 'Security', suggestion: 'Add motion sensors to remaining rooms', pointsGain: 3, icon: Icons.sensors),
        ScoreImprovement(area: 'Automation', suggestion: 'Create more IFTTT-style rules for daily routines', pointsGain: 4, icon: Icons.auto_fix_high),
        ScoreImprovement(area: 'Comfort', suggestion: 'Add humidity sensors to bedrooms', pointsGain: 3, icon: Icons.water_drop),
      ],
    );
  }

  void _initEnergyAudit() {
    _energyAudit = EnergyAuditReport(
      generatedAt: DateTime.now().subtract(const Duration(days: 7)),
      totalConsumption: 450, estimatedWaste: 65, potentialSavings: 1200,
      efficiencyGrade: 'B', gradeColor: const Color(0xFF8BC34A),
      findings: [
        AuditFinding(area: 'HVAC', finding: 'AC running 2 hours more than optimal', severity: 'Medium', wastage: 25, color: const Color(0xFFFF9800)),
        AuditFinding(area: 'Lighting', finding: '3 rooms with lights on while unoccupied', severity: 'Low', wastage: 8, color: const Color(0xFF2196F3)),
        AuditFinding(area: 'Standby', finding: '12 devices consuming standby power', severity: 'Low', wastage: 15, color: const Color(0xFF9C27B0)),
        AuditFinding(area: 'Water Heating', finding: 'Geyser heating during off-hours', severity: 'High', wastage: 17, color: const Color(0xFFF44336)),
      ],
      recommendations: [
        AuditRecommendation(title: 'Optimize AC Schedule', description: 'Reduce AC usage by 2 hours daily using occupancy detection', savings: 400, paybackPeriod: 'Immediate', icon: Icons.ac_unit),
        AuditRecommendation(title: 'Motion-Based Lighting', description: 'Install motion sensors in hallways and bathrooms', savings: 200, paybackPeriod: '3 months', icon: Icons.lightbulb),
        AuditRecommendation(title: 'Smart Power Strips', description: 'Eliminate standby power with smart strips', savings: 350, paybackPeriod: '6 months', icon: Icons.power),
        AuditRecommendation(title: 'Solar Water Heater', description: 'Install solar water heater to reduce geyser usage', savings: 250, paybackPeriod: '18 months', icon: Icons.solar_power),
      ],
    );
  }

  void _initServiceProviders() {
    _serviceProviders = [
      ServiceProvider(id: 'sp1', name: 'QuickFix Electricals', category: 'Electrician', rating: 4.8, phone: '+91 98765 43210', email: 'quickfix@email.com', isAvailable: true, distanceKm: 2.5, categoryColor: const Color(0xFFFF9800)),
      ServiceProvider(id: 'sp2', name: 'PipeMaster Plumbing', category: 'Plumber', rating: 4.5, phone: '+91 98765 43211', email: 'pipemaster@email.com', isAvailable: true, distanceKm: 3.2, categoryColor: const Color(0xFF2196F3)),
      ServiceProvider(id: 'sp3', name: 'CoolAir HVAC Services', category: 'HVAC', rating: 4.7, phone: '+91 98765 43212', email: 'coolair@email.com', isAvailable: false, distanceKm: 5.0, categoryColor: const Color(0xFF00BCD4)),
      ServiceProvider(id: 'sp4', name: 'SecureHome Systems', category: 'Security', rating: 4.9, phone: '+91 98765 43213', email: 'securehome@email.com', isAvailable: true, distanceKm: 4.1, categoryColor: const Color(0xFFF44336)),
      ServiceProvider(id: 'sp5', name: 'CleanPro Services', category: 'Cleaning', rating: 4.3, phone: '+91 98765 43214', email: 'cleanpro@email.com', isAvailable: true, distanceKm: 1.8, categoryColor: const Color(0xFF4CAF50)),
    ];
  }

  // ===== ACTION METHODS =====
  void triggerPanicButton() {
    _panicButton = PanicButtonState(
      isTriggered: true, triggeredAt: DateTime.now(), triggeredBy: 'Admin',
      emergencyActions: ['All lights ON at 100%', 'Siren activated', 'All doors unlocked', 'Emergency contacts notified', 'Camera recording started'],
      notifiedContacts: ['Police', 'Family Member 1', 'Neighbor'],
    );
    notifyListeners();
  }

  void cancelPanicButton() {
    _panicButton = PanicButtonState();
    notifyListeners();
  }

  void collectPackage(String id) {
    final idx = _packages.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      final p = _packages[idx];
      _packages[idx] = PackageDelivery(id: p.id, timestamp: p.timestamp, carrier: p.carrier, status: 'Collected', location: p.location, isCollected: true, statusColor: const Color(0xFF2196F3));
      notifyListeners();
    }
  }

  void togglePerimeterZone(String id) {
    final idx = _perimeterZones.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      final p = _perimeterZones[idx];
      _perimeterZones[idx] = PerimeterZone(id: p.id, name: p.name, type: p.type, isArmed: !p.isArmed, sensorType: p.sensorType, length: p.length, statusColor: !p.isArmed ? const Color(0xFF4CAF50) : const Color(0xFF607D8B));
      notifyListeners();
    }
  }

  void startFirmwareUpdate(String deviceId) {
    final idx = _firmwareDevices.indexWhere((f) => f.deviceId == deviceId);
    if (idx >= 0) {
      final f = _firmwareDevices[idx];
      _firmwareDevices[idx] = FirmwareDevice(deviceId: f.deviceId, deviceName: f.deviceName, currentVersion: f.currentVersion, latestVersion: f.latestVersion, updateAvailable: true, status: 'Updating', updateProgress: 0, lastUpdated: f.lastUpdated, statusColor: const Color(0xFF2196F3));
      notifyListeners();

      // Simulate update progress
      Timer.periodic(const Duration(seconds: 2), (timer) {
        final currentIdx = _firmwareDevices.indexWhere((fw) => fw.deviceId == deviceId);
        if (currentIdx >= 0) {
          final current = _firmwareDevices[currentIdx];
          final newProgress = (current.updateProgress + 0.2).clamp(0.0, 1.0);
          if (newProgress >= 1.0) {
            _firmwareDevices[currentIdx] = FirmwareDevice(deviceId: current.deviceId, deviceName: current.deviceName, currentVersion: current.latestVersion, latestVersion: current.latestVersion, updateAvailable: false, status: 'Up to date', updateProgress: 1, lastUpdated: DateTime.now(), statusColor: const Color(0xFF4CAF50));
            timer.cancel();
          } else {
            _firmwareDevices[currentIdx] = FirmwareDevice(deviceId: current.deviceId, deviceName: current.deviceName, currentVersion: current.currentVersion, latestVersion: current.latestVersion, updateAvailable: true, status: 'Updating', updateProgress: newProgress, lastUpdated: current.lastUpdated, statusColor: const Color(0xFF2196F3));
          }
          notifyListeners();
        }
      });
    }
  }

  void toggleFamilyMemberHome(String id) {
    final idx = _familyMembers.indexWhere((f) => f.id == id);
    if (idx >= 0) {
      final f = _familyMembers[idx];
      _familyMembers[idx] = FamilyMember(id: f.id, name: f.name, role: f.role, avatarInitial: f.avatarInitial, avatarColor: f.avatarColor, isHome: !f.isHome, lastSeen: DateTime.now(), permissions: f.permissions, deviceAccess: f.deviceAccess);
      notifyListeners();
    }
  }

  void _updateLiveData() {
    // Update network health
    if (_networkHealth != null) {
      _networkHealth = NetworkHealthData(
        downloadSpeed: 130 + _random.nextDouble() * 70,
        uploadSpeed: 40 + _random.nextDouble() * 30,
        latency: 5 + _random.nextInt(20),
        connectedDevices: _networkHealth!.connectedDevices,
        bandwidth: _networkHealth!.bandwidth,
        bandwidthUsed: 70 + _random.nextDouble() * 50,
        routerStatus: 'Online',
        wifiSignalStrength: 70 + _random.nextDouble() * 25,
        devices: _networkHealth!.devices,
        healthColor: const Color(0xFF4CAF50),
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
