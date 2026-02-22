import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ========== FEATURE 31: Smart Blinds Control ==========
class SmartBlindsState {
  final String id;
  final String name;
  final String room;
  final int position; // 0-100 (0=closed, 100=open)
  final int tiltAngle; // -90 to 90
  final bool isAutoMode;
  final String schedule;
  final IconData icon;

  SmartBlindsState({
    required this.id, required this.name, required this.room,
    required this.position, this.tiltAngle = 0, this.isAutoMode = false,
    this.schedule = 'None', this.icon = Icons.blinds,
  });
}

// ========== FEATURE 32: Robot Vacuum ==========
class RobotVacuumState {
  final String id;
  final String name;
  final String status; // Cleaning, Charging, Docked, Returning, Error
  final int batteryLevel;
  final double areaCleaned; // sq meters
  final int cleaningTime; // minutes
  final String currentRoom;
  final String mode; // Auto, Spot, Edge, Turbo, Quiet
  final double dustbinLevel; // 0-100%
  final Color statusColor;
  final List<String> cleaningHistory;

  RobotVacuumState({
    required this.id, required this.name, required this.status,
    required this.batteryLevel, required this.areaCleaned,
    required this.cleaningTime, required this.currentRoom,
    required this.mode, required this.dustbinLevel,
    required this.statusColor, this.cleaningHistory = const [],
  });
}

// ========== FEATURE 33: Smart Oven ==========
class SmartOvenState {
  final String id;
  final String name;
  final bool isOn;
  final double currentTemp;
  final double targetTemp;
  final String mode; // Bake, Broil, Convection, Grill, Air Fry, Warm
  final int timerMinutes;
  final int elapsedMinutes;
  final bool preheatComplete;
  final String recipe;
  final Color statusColor;

  SmartOvenState({
    required this.id, required this.name, required this.isOn,
    required this.currentTemp, required this.targetTemp,
    required this.mode, required this.timerMinutes,
    required this.elapsedMinutes, required this.preheatComplete,
    this.recipe = '', required this.statusColor,
  });
}

// ========== FEATURE 34: Smart Washing Machine ==========
class WashingMachineState {
  final String id;
  final String name;
  final String status; // Idle, Washing, Rinsing, Spinning, Done
  final String cycle; // Normal, Delicate, Heavy, Quick, Eco
  final int progressPercent;
  final int remainingMinutes;
  final double waterTemp;
  final int spinSpeed;
  final Color statusColor;

  WashingMachineState({
    required this.id, required this.name, required this.status,
    required this.cycle, required this.progressPercent,
    required this.remainingMinutes, required this.waterTemp,
    required this.spinSpeed, required this.statusColor,
  });
}

// ========== FEATURE 35: Smart Dishwasher ==========
class DishwasherState {
  final String id;
  final String name;
  final String status;
  final String cycle; // Normal, Intensive, Eco, Quick, Rinse
  final int progressPercent;
  final int remainingMinutes;
  final bool rinseAidLow;
  final bool saltLow;
  final Color statusColor;

  DishwasherState({
    required this.id, required this.name, required this.status,
    required this.cycle, required this.progressPercent,
    required this.remainingMinutes, this.rinseAidLow = false,
    this.saltLow = false, required this.statusColor,
  });
}

// ========== FEATURE 36: Smart Garage Door ==========
class GarageDoorState {
  final String id;
  final String name;
  final bool isOpen;
  final bool isMoving;
  final String vehiclePresent;
  final DateTime lastOpened;
  final bool autoCloseEnabled;
  final int autoCloseMinutes;

  GarageDoorState({
    required this.id, required this.name, required this.isOpen,
    this.isMoving = false, required this.vehiclePresent,
    required this.lastOpened, this.autoCloseEnabled = true,
    this.autoCloseMinutes = 10,
  });
}

// ========== FEATURE 37: Smart Sprinkler ==========
class SprinklerZone {
  final String id;
  final String name;
  final bool isActive;
  final int durationMinutes;
  final String schedule;
  final double moistureLevel;
  final bool rainDelay;
  final String plantType;

  SprinklerZone({
    required this.id, required this.name, required this.isActive,
    required this.durationMinutes, required this.schedule,
    required this.moistureLevel, this.rainDelay = false,
    required this.plantType,
  });
}

// ========== FEATURE 38: Pet Feeder ==========
class PetFeederState {
  final String id;
  final String petName;
  final double foodLevel; // 0-100%
  final double waterLevel;
  final List<FeedingSchedule> schedules;
  final DateTime lastFed;
  final double portionSize; // grams
  final String foodType;

  PetFeederState({
    required this.id, required this.petName, required this.foodLevel,
    required this.waterLevel, required this.schedules,
    required this.lastFed, required this.portionSize,
    required this.foodType,
  });
}

class FeedingSchedule {
  final TimeOfDay time;
  final double portion;
  final bool isEnabled;

  FeedingSchedule({required this.time, required this.portion, this.isEnabled = true});
}

// ========== FEATURE 39: Baby Monitor ==========
class BabyMonitorState {
  final String id;
  final String babyName;
  final double roomTemp;
  final double humidity;
  final double noiseLevel;
  final bool isCrying;
  final bool motionDetected;
  final String sleepStatus; // Sleeping, Awake, Restless
  final Duration sleepDuration;
  final Color statusColor;

  BabyMonitorState({
    required this.id, required this.babyName, required this.roomTemp,
    required this.humidity, required this.noiseLevel,
    required this.isCrying, required this.motionDetected,
    required this.sleepStatus, required this.sleepDuration,
    required this.statusColor,
  });
}

// ========== FEATURE 40: EV Charger ==========
class EVChargerState {
  final String id;
  final String vehicleName;
  final String status; // Connected, Charging, Complete, Disconnected, Error
  final double chargeLevel;
  final double chargingPower; // kW
  final double energyDelivered; // kWh
  final int estimatedMinutes;
  final double estimatedCost;
  final bool isScheduled;
  final TimeOfDay? scheduledStart;
  final Color statusColor;

  EVChargerState({
    required this.id, required this.vehicleName, required this.status,
    required this.chargeLevel, required this.chargingPower,
    required this.energyDelivered, required this.estimatedMinutes,
    required this.estimatedCost, this.isScheduled = false,
    this.scheduledStart, required this.statusColor,
  });
}

// ========== FEATURE 41: Air Purifier ==========
class AirPurifierState {
  final String id;
  final String name;
  final bool isOn;
  final String mode; // Auto, Sleep, Turbo, Manual
  final int fanSpeed; // 1-5
  final int filterLife; // 0-100%
  final double pm25;
  final double pm10;
  final int aqi;
  final Color aqiColor;

  AirPurifierState({
    required this.id, required this.name, required this.isOn,
    required this.mode, required this.fanSpeed,
    required this.filterLife, required this.pm25,
    required this.pm10, required this.aqi, required this.aqiColor,
  });
}

// ========== FEATURE 42: Smart Doorbell ==========
class DoorbellEvent {
  final String id;
  final DateTime timestamp;
  final String eventType; // Ring, Motion, Package, Person
  final String? visitorName;
  final bool isAnswered;
  final String thumbnailUrl;
  final Color eventColor;

  DoorbellEvent({
    required this.id, required this.timestamp, required this.eventType,
    this.visitorName, this.isAnswered = false,
    this.thumbnailUrl = '', required this.eventColor,
  });
}

// ========== FEATURE 43: Pool Controller ==========
class PoolControllerState {
  final double waterTemp;
  final double pH;
  final double chlorine;
  final bool pumpRunning;
  final bool heaterOn;
  final String filterStatus;
  final double waterLevel;
  final int pumpTimer; // hours remaining
  final Color phColor;

  PoolControllerState({
    required this.waterTemp, required this.pH, required this.chlorine,
    required this.pumpRunning, required this.heaterOn,
    required this.filterStatus, required this.waterLevel,
    required this.pumpTimer, required this.phColor,
  });
}

// ========== FEATURE 44: Smart Mirror ==========
class SmartMirrorState {
  final String id;
  final bool isOn;
  final int brightness;
  final bool showWeather;
  final bool showCalendar;
  final bool showNews;
  final bool showFitness;
  final String currentWidget;
  final Color ambientColor;

  SmartMirrorState({
    required this.id, required this.isOn, required this.brightness,
    this.showWeather = true, this.showCalendar = true,
    this.showNews = true, this.showFitness = false,
    this.currentWidget = 'Dashboard', this.ambientColor = Colors.white,
  });
}

// ========== FEATURE 45: Predictive Maintenance AI ==========
class PredictiveMaintenanceItem {
  final String deviceName;
  final String component;
  final int daysUntilFailure;
  final double confidence;
  final String severity; // Low, Medium, High, Critical
  final String recommendation;
  final double estimatedCost;
  final Color severityColor;

  PredictiveMaintenanceItem({
    required this.deviceName, required this.component,
    required this.daysUntilFailure, required this.confidence,
    required this.severity, required this.recommendation,
    required this.estimatedCost, required this.severityColor,
  });
}

// ========== FEATURE 46: Anomaly Detection ==========
class AnomalyAlert {
  final String id;
  final DateTime timestamp;
  final String deviceName;
  final String anomalyType; // Usage Spike, Unusual Pattern, Malfunction, Leak
  final String description;
  final double severity; // 0-1
  final bool isAcknowledged;
  final String suggestedAction;
  final Color alertColor;

  AnomalyAlert({
    required this.id, required this.timestamp, required this.deviceName,
    required this.anomalyType, required this.description,
    required this.severity, this.isAcknowledged = false,
    required this.suggestedAction, required this.alertColor,
  });
}

// ========== FEATURE 47: Habit Learning ==========
class LearnedHabit {
  final String id;
  final String description;
  final String pattern;
  final double confidence;
  final int occurrences;
  final TimeOfDay typicalTime;
  final List<int> typicalDays;
  final bool isAutomated;
  final IconData icon;
  final Color color;

  LearnedHabit({
    required this.id, required this.description, required this.pattern,
    required this.confidence, required this.occurrences,
    required this.typicalTime, required this.typicalDays,
    this.isAutomated = false, required this.icon, required this.color,
  });
}

// ========== FEATURE 48: Voice Command History ==========
class VoiceCommand {
  final String id;
  final DateTime timestamp;
  final String transcript;
  final String action;
  final bool wasSuccessful;
  final double confidence;

  VoiceCommand({
    required this.id, required this.timestamp, required this.transcript,
    required this.action, required this.wasSuccessful,
    required this.confidence,
  });
}

// ========== FEATURE 49: Weather-Reactive Automation ==========
class WeatherAutomation {
  final String id;
  final String name;
  final String weatherCondition; // Rain, Hot, Cold, Windy, Humid, Storm
  final double threshold;
  final String unit;
  final List<String> actions;
  bool isEnabled;
  final IconData icon;
  final Color color;

  WeatherAutomation({
    required this.id, required this.name, required this.weatherCondition,
    required this.threshold, required this.unit,
    required this.actions, this.isEnabled = true,
    required this.icon, required this.color,
  });
}

// ========== FEATURE 50: Circadian Lighting ==========
class CircadianLightingState {
  final bool isEnabled;
  final int currentColorTemp; // Kelvin (2700-6500)
  final int currentBrightness; // 0-100
  final String currentPhase; // Dawn, Morning, Day, Evening, Night
  final TimeOfDay wakeTime;
  final TimeOfDay sleepTime;
  final Color currentColor;

  CircadianLightingState({
    required this.isEnabled, required this.currentColorTemp,
    required this.currentBrightness, required this.currentPhase,
    required this.wakeTime, required this.sleepTime,
    required this.currentColor,
  });
}

// ========== FEATURE 51: Multi-Zone HVAC ==========
class HVACZone {
  final String id;
  final String name;
  final String room;
  final double currentTemp;
  final double targetTemp;
  final String mode; // Cool, Heat, Auto, Fan, Dry
  final bool isActive;
  final int fanSpeed;
  final double humidity;
  final double energyUsage; // kWh today
  final Color modeColor;

  HVACZone({
    required this.id, required this.name, required this.room,
    required this.currentTemp, required this.targetTemp,
    required this.mode, required this.isActive,
    required this.fanSpeed, required this.humidity,
    required this.energyUsage, required this.modeColor,
  });
}

// ========== FEATURE 52: Appliance Lifecycle ==========
class ApplianceLifecycle {
  final String deviceName;
  final DateTime purchaseDate;
  final int expectedLifeYears;
  final double usageHours;
  final double healthPercent;
  final double depreciation;
  final String warrantyStatus;
  final DateTime? warrantyExpiry;
  final List<String> maintenanceHistory;

  String get applianceName => deviceName;
  double get ageInYears => DateTime.now().difference(purchaseDate).inDays / 365.0;
  int get expectedLifespan => expectedLifeYears;
  double get lifespanPercentage => (ageInYears / expectedLifeYears * 100).clamp(0, 100);
  Color get lifespanColor => lifespanPercentage < 50 ? const Color(0xFF4CAF50) : lifespanPercentage < 80 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  double get currentEfficiency => healthPercent;
  double get replacementCost => depreciation;

  ApplianceLifecycle({
    required this.deviceName, required this.purchaseDate,
    required this.expectedLifeYears, required this.usageHours,
    required this.healthPercent, required this.depreciation,
    required this.warrantyStatus, this.warrantyExpiry,
    this.maintenanceHistory = const [],
  });
}

// ========== FEATURE 53: Sleep Quality Analysis ==========
class SleepQualityData {
  final DateTime date;
  final double score; // 0-100
  final Duration totalSleep;
  final Duration deepSleep;
  final Duration remSleep;
  final Duration lightSleep;
  final int awakenings;
  final double avgRoomTemp;
  final double avgHumidity;
  final double avgNoise;
  final String recommendation;
  final Color scoreColor;

  SleepQualityData({
    required this.date, required this.score, required this.totalSleep,
    required this.deepSleep, required this.remSleep,
    required this.lightSleep, required this.awakenings,
    required this.avgRoomTemp, required this.avgHumidity,
    required this.avgNoise, required this.recommendation,
    required this.scoreColor,
  });
}

// ========== FEATURE 54: Garden/Plant Care ==========
class PlantCareData {
  final String id;
  final String plantName;
  final String species;
  final double soilMoisture;
  final double lightLevel;
  final double temperature;
  final String healthStatus;
  final DateTime lastWatered;
  final DateTime nextWatering;
  final String careAdvice;
  final IconData icon;
  final Color statusColor;

  PlantCareData({
    required this.id, required this.plantName, required this.species,
    required this.soilMoisture, required this.lightLevel,
    required this.temperature, required this.healthStatus,
    required this.lastWatered, required this.nextWatering,
    required this.careAdvice, required this.icon, required this.statusColor,
  });
}

// ========== FEATURE 55: Weather Station ==========
class WeatherStationData {
  final double temperature;
  final double humidity;
  final double pressure; // hPa
  final double windSpeed; // km/h
  final String windDirection;
  final double rainfall; // mm
  final double uvIndex;
  final double dewPoint;
  final double visibility; // km
  final String condition; // Clear, Cloudy, Rain, Storm, etc
  final IconData conditionIcon;
  final Color conditionColor;
  final List<HourlyForecast> hourlyForecast;

  WeatherStationData({
    required this.temperature, required this.humidity,
    required this.pressure, required this.windSpeed,
    required this.windDirection, required this.rainfall,
    required this.uvIndex, required this.dewPoint,
    required this.visibility, required this.condition,
    required this.conditionIcon, required this.conditionColor,
    required this.hourlyForecast,
  });
}

class HourlyForecast {
  final int hour;
  final double temp;
  final String condition;
  final IconData icon;

  HourlyForecast({required this.hour, required this.temp, required this.condition, required this.icon});
}

// ========== FEATURE 56: Home Inventory ==========
class HomeInventoryItem {
  final String id;
  final String name;
  final String category; // Electronics, Appliance, Furniture, Valuable
  final String room;
  final double purchasePrice;
  final DateTime purchaseDate;
  final String serialNumber;
  final String warrantyStatus;
  final String condition;
  final Color categoryColor;

  IconData get icon {
    switch (category) {
      case 'Electronics': return Icons.devices;
      case 'Appliance': return Icons.kitchen;
      case 'Furniture': return Icons.weekend;
      case 'Valuable': return Icons.diamond;
      default: return Icons.inventory_2;
    }
  }
  double get value => purchasePrice;

  HomeInventoryItem({
    required this.id, required this.name, required this.category,
    required this.room, required this.purchasePrice,
    required this.purchaseDate, required this.serialNumber,
    required this.warrantyStatus, required this.condition,
    required this.categoryColor,
  });
}

// ========== FEATURE 57: Notification Priority ==========
class SmartNotification {
  final String id;
  final String title;
  final String body;
  final String category; // Critical, Warning, Info, Success
  final DateTime timestamp;
  final bool isRead;
  final String source;
  final IconData icon;
  final Color color;
  final String? actionUrl;

  Color get priorityColor => color;
  String get message => body;

  SmartNotification({
    required this.id, required this.title, required this.body,
    required this.category, required this.timestamp,
    this.isRead = false, required this.source,
    required this.icon, required this.color, this.actionUrl,
  });
}

// ========== FEATURE 58: IFTTT-Style Rules ==========
class AutomationRule {
  final String id;
  final String name;
  final String triggerType; // Device, Time, Sensor, Location, Weather
  final String triggerDevice;
  final String triggerCondition;
  final String triggerValue;
  final String actionDevice;
  final String actionCommand;
  final bool isEnabled;
  final int executionCount;
  final DateTime? lastTriggered;
  final IconData icon;
  final Color color;

  AutomationRule({
    required this.id, required this.name, required this.triggerType,
    required this.triggerDevice, required this.triggerCondition,
    required this.triggerValue, required this.actionDevice,
    required this.actionCommand, this.isEnabled = true,
    this.executionCount = 0, this.lastTriggered,
    required this.icon, required this.color,
  });
}

// ========== FEATURE 59: Multi-Room Audio ==========
class AudioZone {
  final String id;
  final String room;
  final bool isPlaying;
  final String currentTrack;
  final String artist;
  final int volume;
  final String source; // Spotify, Radio, Bluetooth, AirPlay
  final bool isGrouped;
  final String? groupName;

  String get zoneName => room;

  AudioZone({
    required this.id, required this.room, required this.isPlaying,
    required this.currentTrack, required this.artist,
    required this.volume, required this.source,
    this.isGrouped = false, this.groupName,
  });
}

// ========== FEATURE 60: Home Theater ==========
class HomeTheaterState {
  final bool isActive;
  final String source; // TV, Streaming, Blu-ray, Gaming, HDMI
  final int volume;
  final String audioMode; // Stereo, Surround, Dolby, DTS
  final int brightness;
  final String aspectRatio;
  final bool projectorOn;
  final bool surroundOn;
  final List<String> connectedDevices;

  String get mode => source;
  String get projectorStatus => projectorOn ? 'On' : 'Off';
  String get soundMode => audioMode;
  String get screenPosition => aspectRatio;
  int get ambientBrightness => brightness;
  String get currentInput => source;

  HomeTheaterState({
    required this.isActive, required this.source, required this.volume,
    required this.audioMode, required this.brightness,
    required this.aspectRatio, required this.projectorOn,
    required this.surroundOn, this.connectedDevices = const [],
  });
}

// ========== FEATURE 61: Gaming Mode ==========
class GamingModeState {
  final bool isActive;
  final String gameName;
  final int networkLatency; // ms
  final double downloadSpeed; // Mbps
  final double uploadSpeed;
  final String lightingProfile;
  final int displayRefreshRate;
  final bool performanceMode;

  String get currentGame => gameName;
  String get platform => '${displayRefreshRate}Hz';
  String get displayMode => '${displayRefreshRate}Hz';
  String get networkPriority => performanceMode ? 'Priority' : 'Normal';
  String get rgbLighting => lightingProfile;
  int get ambientBrightness => 50;
  bool get doNotDisturb => performanceMode;

  GamingModeState({
    required this.isActive, required this.gameName,
    required this.networkLatency, required this.downloadSpeed,
    required this.uploadSpeed, required this.lightingProfile,
    required this.displayRefreshRate, required this.performanceMode,
  });
}

// ========== FEATURE 62: Wellness Mode ==========
class WellnessData {
  final double indoorAirScore; // 0-100
  final double stressLevel; // 0-100
  final double meditationMinutes;
  final String ambientSound; // None, Rain, Forest, Ocean, White Noise
  final int aromaDiffuserLevel; // 0-3
  final bool isMeditating;
  final List<WellnessGoal> goals;

  double get overallScore => indoorAirScore;
  Color get scoreColor => indoorAirScore > 70 ? const Color(0xFF4CAF50) : indoorAirScore > 40 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  Color get stressColor => stressLevel < 30 ? const Color(0xFF4CAF50) : stressLevel < 60 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  double get airQualityScore => indoorAirScore;
  String get currentMood => ambientSound;

  WellnessData({
    required this.indoorAirScore, required this.stressLevel,
    required this.meditationMinutes, required this.ambientSound,
    required this.aromaDiffuserLevel, required this.isMeditating,
    this.goals = const [],
  });
}

class WellnessGoal {
  final String name;
  final double progress;
  final String unit;
  final Color color;

  IconData get icon => Icons.check_circle_outline;

  WellnessGoal({required this.name, required this.progress, required this.unit, required this.color});
}

// ========== FEATURE 63: Workout Environment ==========
class WorkoutEnvironment {
  final bool isActive;
  final String workoutType; // Cardio, Yoga, HIIT, Weights, Stretching
  final int durationMinutes;
  final int caloriesBurned;
  final double roomTemp;
  final int fanSpeed;
  final String musicPlaylist;
  final bool mirrorMode;

  Duration get duration => Duration(minutes: durationMinutes);
  int get heartRate => 120;
  String get musicGenre => musicPlaylist;
  int get lightBrightness => 80;

  WorkoutEnvironment({
    required this.isActive, required this.workoutType,
    required this.durationMinutes, required this.caloriesBurned,
    required this.roomTemp, required this.fanSpeed,
    required this.musicPlaylist, required this.mirrorMode,
  });
}

// ========== FEATURE 64: Aquarium Controller ==========
class AquariumState {
  final double waterTemp;
  final double pH;
  final double ammonia;
  final double nitrate;
  final bool lightOn;
  final String lightMode; // Day, Night, Blue, Simulate
  final bool filterRunning;
  final bool heaterOn;
  final DateTime lastFed;
  final DateTime nextFeeding;
  final DateTime lastWaterChange;
  final Color phColor;

  Color get pHColor => phColor;
  Color get ammoniaColor => ammonia < 0.02 ? const Color(0xFF4CAF50) : ammonia < 0.05 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
  double get salinity => 1.025;
  int get tankSize => 200;
  int get fishCount => 12;
  String get filterStatus => filterRunning ? 'Running' : 'Off';

  AquariumState({
    required this.waterTemp, required this.pH, required this.ammonia,
    required this.nitrate, required this.lightOn,
    required this.lightMode, required this.filterRunning,
    required this.heaterOn, required this.lastFed,
    required this.nextFeeding, required this.lastWaterChange,
    required this.phColor,
  });
}

// ========== FEATURE 65: Waste Management ==========
class WasteManagementData {
  final double generalBinLevel; // 0-100
  final double recycleBinLevel;
  final double organicBinLevel;
  final DateTime nextCollectionDate;
  final String collectionType;
  final List<WasteHistory> history;
  final double monthlyWaste; // kg
  final double recyclingRate; // %

  double get generalWaste => generalBinLevel;
  Color get generalWasteColor => generalBinLevel > 80 ? const Color(0xFFF44336) : generalBinLevel > 50 ? const Color(0xFFFF9800) : const Color(0xFF795548);
  double get recycling => recycleBinLevel;
  double get composting => organicBinLevel;
  double get eWaste => 15.0;
  String get nextCollection => '${nextCollectionDate.day}/${nextCollectionDate.month}';

  WasteManagementData({
    required this.generalBinLevel, required this.recycleBinLevel,
    required this.organicBinLevel, required this.nextCollectionDate,
    required this.collectionType, this.history = const [],
    required this.monthlyWaste, required this.recyclingRate,
  });
}

class WasteHistory {
  final DateTime date;
  final String type;
  final double weight;

  WasteHistory({required this.date, required this.type, required this.weight});
}

// ========== ADVANCED HOME SERVICE ==========
class AdvancedHomeService extends ChangeNotifier {
  final Random _random = Random();
  Timer? _updateTimer;

  // Feature 31: Smart Blinds
  List<SmartBlindsState> _blinds = [];
  List<SmartBlindsState> get blinds => _blinds;

  // Feature 32: Robot Vacuum
  RobotVacuumState? _robotVacuum;
  RobotVacuumState? get robotVacuum => _robotVacuum;

  // Feature 33: Smart Oven
  SmartOvenState? _smartOven;
  SmartOvenState? get smartOven => _smartOven;

  // Feature 34: Washing Machine
  WashingMachineState? _washingMachine;
  WashingMachineState? get washingMachine => _washingMachine;

  // Feature 35: Dishwasher
  DishwasherState? _dishwasher;
  DishwasherState? get dishwasher => _dishwasher;

  // Feature 36: Garage Door
  List<GarageDoorState> _garageDoors = [];
  List<GarageDoorState> get garageDoors => _garageDoors;

  // Feature 37: Sprinklers
  List<SprinklerZone> _sprinklerZones = [];
  List<SprinklerZone> get sprinklerZones => _sprinklerZones;

  // Feature 38: Pet Feeder
  List<PetFeederState> _petFeeders = [];
  List<PetFeederState> get petFeeders => _petFeeders;

  // Feature 39: Baby Monitor
  BabyMonitorState? _babyMonitor;
  BabyMonitorState? get babyMonitor => _babyMonitor;

  // Feature 40: EV Charger
  EVChargerState? _evCharger;
  EVChargerState? get evCharger => _evCharger;

  // Feature 41: Air Purifier
  List<AirPurifierState> _airPurifiers = [];
  List<AirPurifierState> get airPurifiers => _airPurifiers;

  // Feature 42: Doorbell
  List<DoorbellEvent> _doorbellEvents = [];
  List<DoorbellEvent> get doorbellEvents => _doorbellEvents;

  // Feature 43: Pool
  PoolControllerState? _poolController;
  PoolControllerState? get poolController => _poolController;

  // Feature 44: Smart Mirror
  SmartMirrorState? _smartMirror;
  SmartMirrorState? get smartMirror => _smartMirror;

  // Feature 45: Predictive Maintenance
  List<PredictiveMaintenanceItem> _predictions = [];
  List<PredictiveMaintenanceItem> get predictions => _predictions;

  // Feature 46: Anomaly Detection
  List<AnomalyAlert> _anomalies = [];
  List<AnomalyAlert> get anomalies => _anomalies;

  // Feature 47: Habit Learning
  List<LearnedHabit> _learnedHabits = [];
  List<LearnedHabit> get learnedHabits => _learnedHabits;

  // Feature 48: Voice Commands
  List<VoiceCommand> _voiceCommands = [];
  List<VoiceCommand> get voiceCommands => _voiceCommands;

  // Feature 49: Weather Automation
  List<WeatherAutomation> _weatherAutomations = [];
  List<WeatherAutomation> get weatherAutomations => _weatherAutomations;

  // Feature 50: Circadian Lighting
  CircadianLightingState? _circadianLighting;
  CircadianLightingState? get circadianLighting => _circadianLighting;

  // Feature 51: Multi-Zone HVAC
  List<HVACZone> _hvacZones = [];
  List<HVACZone> get hvacZones => _hvacZones;

  // Feature 52: Appliance Lifecycle
  List<ApplianceLifecycle> _lifecycles = [];
  List<ApplianceLifecycle> get lifecycles => _lifecycles;

  // Feature 53: Sleep Quality
  List<SleepQualityData> _sleepHistory = [];
  List<SleepQualityData> get sleepHistory => _sleepHistory;

  // Feature 54: Plant Care
  List<PlantCareData> _plants = [];
  List<PlantCareData> get plants => _plants;

  // Feature 55: Weather Station
  WeatherStationData? _weatherStation;
  WeatherStationData? get weatherStation => _weatherStation;

  // Feature 56: Home Inventory
  List<HomeInventoryItem> _inventory = [];
  List<HomeInventoryItem> get inventory => _inventory;

  // Feature 57: Smart Notifications
  List<SmartNotification> _smartNotifications = [];
  List<SmartNotification> get smartNotifications => _smartNotifications;

  // Feature 58: Automation Rules
  List<AutomationRule> _automationRules = [];
  List<AutomationRule> get automationRules => _automationRules;

  // Feature 59: Multi-Room Audio
  List<AudioZone> _audioZones = [];
  List<AudioZone> get audioZones => _audioZones;

  // Feature 60: Home Theater
  HomeTheaterState? _homeTheater;
  HomeTheaterState? get homeTheater => _homeTheater;

  // Feature 61: Gaming Mode
  GamingModeState? _gamingMode;
  GamingModeState? get gamingMode => _gamingMode;

  // Feature 62: Wellness
  WellnessData? _wellness;
  WellnessData? get wellness => _wellness;

  // Feature 63: Workout
  WorkoutEnvironment? _workout;
  WorkoutEnvironment? get workout => _workout;

  // Feature 64: Aquarium
  AquariumState? _aquarium;
  AquariumState? get aquarium => _aquarium;

  // Feature 65: Waste Management
  WasteManagementData? _wasteManagement;
  WasteManagementData? get wasteManagement => _wasteManagement;

  AdvancedHomeService() {
    _initializeAll();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) => _updateLiveData());
  }

  void _initializeAll() {
    _initBlinds();
    _initRobotVacuum();
    _initSmartOven();
    _initWashingMachine();
    _initDishwasher();
    _initGarageDoors();
    _initSprinklers();
    _initPetFeeders();
    _initBabyMonitor();
    _initEVCharger();
    _initAirPurifiers();
    _initDoorbellEvents();
    _initPoolController();
    _initSmartMirror();
    _initPredictiveMaintenance();
    _initAnomalies();
    _initHabitLearning();
    _initVoiceCommands();
    _initWeatherAutomation();
    _initCircadianLighting();
    _initHVACZones();
    _initLifecycles();
    _initSleepQuality();
    _initPlants();
    _initWeatherStation();
    _initInventory();
    _initSmartNotifications();
    _initAutomationRules();
    _initAudioZones();
    _initHomeTheater();
    _initGamingMode();
    _initWellness();
    _initWorkout();
    _initAquarium();
    _initWasteManagement();
  }

  // ===== INITIALIZATION METHODS =====
  void _initBlinds() {
    _blinds = [
      SmartBlindsState(id: 'b1', name: 'Living Room Blinds', room: 'Living Room', position: 60, tiltAngle: 45, isAutoMode: true, schedule: '7:00 AM - Open'),
      SmartBlindsState(id: 'b2', name: 'Bedroom Blinds', room: 'Bedroom', position: 0, tiltAngle: 0, isAutoMode: true, schedule: '6:30 AM - Open'),
      SmartBlindsState(id: 'b3', name: 'Office Blinds', room: 'Office', position: 80, tiltAngle: 30, isAutoMode: false),
    ];
  }

  void _initRobotVacuum() {
    _robotVacuum = RobotVacuumState(
      id: 'rv1', name: 'RoboClean Pro', status: 'Docked', batteryLevel: 85,
      areaCleaned: 45.2, cleaningTime: 0, currentRoom: 'Dock',
      mode: 'Auto', dustbinLevel: 35, statusColor: const Color(0xFF4CAF50),
      cleaningHistory: ['Living Room - 25min', 'Bedroom - 18min', 'Kitchen - 12min'],
    );
  }

  void _initSmartOven() {
    _smartOven = SmartOvenState(
      id: 'ov1', name: 'Smart Oven Pro', isOn: false, currentTemp: 25,
      targetTemp: 180, mode: 'Bake', timerMinutes: 0, elapsedMinutes: 0,
      preheatComplete: false, statusColor: const Color(0xFF607D8B),
    );
  }

  void _initWashingMachine() {
    _washingMachine = WashingMachineState(
      id: 'wm1', name: 'Smart Washer', status: 'Idle', cycle: 'Normal',
      progressPercent: 0, remainingMinutes: 0, waterTemp: 40,
      spinSpeed: 1200, statusColor: const Color(0xFF607D8B),
    );
  }

  void _initDishwasher() {
    _dishwasher = DishwasherState(
      id: 'dw1', name: 'Smart Dishwasher', status: 'Idle', cycle: 'Normal',
      progressPercent: 0, remainingMinutes: 0,
      statusColor: const Color(0xFF607D8B),
    );
  }

  void _initGarageDoors() {
    _garageDoors = [
      GarageDoorState(id: 'gd1', name: 'Main Garage', isOpen: false,
        vehiclePresent: 'Tesla Model 3', lastOpened: DateTime.now().subtract(const Duration(hours: 3))),
      GarageDoorState(id: 'gd2', name: 'Side Garage', isOpen: false,
        vehiclePresent: 'None', lastOpened: DateTime.now().subtract(const Duration(days: 2))),
    ];
  }

  void _initSprinklers() {
    _sprinklerZones = [
      SprinklerZone(id: 'sp1', name: 'Front Lawn', isActive: false, durationMinutes: 15, schedule: '6:00 AM', moistureLevel: 45, plantType: 'Grass'),
      SprinklerZone(id: 'sp2', name: 'Back Garden', isActive: false, durationMinutes: 20, schedule: '6:30 AM', moistureLevel: 55, plantType: 'Flowers'),
      SprinklerZone(id: 'sp3', name: 'Vegetable Patch', isActive: false, durationMinutes: 10, schedule: '7:00 AM', moistureLevel: 60, plantType: 'Vegetables'),
      SprinklerZone(id: 'sp4', name: 'Side Yard', isActive: false, durationMinutes: 12, schedule: '5:30 AM', moistureLevel: 38, plantType: 'Shrubs'),
    ];
  }

  void _initPetFeeders() {
    _petFeeders = [
      PetFeederState(id: 'pf1', petName: 'Max (Dog)', foodLevel: 72, waterLevel: 85,
        schedules: [FeedingSchedule(time: const TimeOfDay(hour: 7, minute: 0), portion: 150),
          FeedingSchedule(time: const TimeOfDay(hour: 18, minute: 0), portion: 150)],
        lastFed: DateTime.now().subtract(const Duration(hours: 4)), portionSize: 150, foodType: 'Dry Kibble'),
      PetFeederState(id: 'pf2', petName: 'Luna (Cat)', foodLevel: 58, waterLevel: 90,
        schedules: [FeedingSchedule(time: const TimeOfDay(hour: 6, minute: 30), portion: 80),
          FeedingSchedule(time: const TimeOfDay(hour: 12, minute: 0), portion: 60),
          FeedingSchedule(time: const TimeOfDay(hour: 19, minute: 0), portion: 80)],
        lastFed: DateTime.now().subtract(const Duration(hours: 2)), portionSize: 80, foodType: 'Wet Food'),
    ];
  }

  void _initBabyMonitor() {
    _babyMonitor = BabyMonitorState(
      id: 'bm1', babyName: 'Baby', roomTemp: 22.5, humidity: 50,
      noiseLevel: 15, isCrying: false, motionDetected: false,
      sleepStatus: 'Sleeping', sleepDuration: const Duration(hours: 2, minutes: 30),
      statusColor: const Color(0xFF4CAF50),
    );
  }

  void _initEVCharger() {
    _evCharger = EVChargerState(
      id: 'ev1', vehicleName: 'Tesla Model 3', status: 'Charging',
      chargeLevel: 67, chargingPower: 7.4, energyDelivered: 22.5,
      estimatedMinutes: 95, estimatedCost: 45.50, isScheduled: true,
      scheduledStart: const TimeOfDay(hour: 22, minute: 0),
      statusColor: const Color(0xFF2196F3),
    );
  }

  void _initAirPurifiers() {
    _airPurifiers = [
      AirPurifierState(id: 'ap1', name: 'Living Room Purifier', isOn: true, mode: 'Auto',
        fanSpeed: 3, filterLife: 72, pm25: 12, pm10: 25, aqi: 35, aqiColor: const Color(0xFF4CAF50)),
      AirPurifierState(id: 'ap2', name: 'Bedroom Purifier', isOn: true, mode: 'Sleep',
        fanSpeed: 1, filterLife: 88, pm25: 8, pm10: 18, aqi: 22, aqiColor: const Color(0xFF4CAF50)),
    ];
  }

  void _initDoorbellEvents() {
    _doorbellEvents = [
      DoorbellEvent(id: 'db1', timestamp: DateTime.now().subtract(const Duration(hours: 1)), eventType: 'Ring', visitorName: 'John', isAnswered: true, eventColor: const Color(0xFF2196F3)),
      DoorbellEvent(id: 'db2', timestamp: DateTime.now().subtract(const Duration(hours: 3)), eventType: 'Package', eventColor: const Color(0xFF4CAF50)),
      DoorbellEvent(id: 'db3', timestamp: DateTime.now().subtract(const Duration(hours: 5)), eventType: 'Motion', eventColor: const Color(0xFFFF9800)),
      DoorbellEvent(id: 'db4', timestamp: DateTime.now().subtract(const Duration(hours: 8)), eventType: 'Person', visitorName: 'Unknown', eventColor: const Color(0xFFF44336)),
    ];
  }

  void _initPoolController() {
    _poolController = PoolControllerState(
      waterTemp: 28.5, pH: 7.2, chlorine: 1.5, pumpRunning: true,
      heaterOn: false, filterStatus: 'Clean', waterLevel: 92, pumpTimer: 4,
      phColor: const Color(0xFF4CAF50),
    );
  }

  void _initSmartMirror() {
    _smartMirror = SmartMirrorState(id: 'sm1', isOn: true, brightness: 70);
  }

  void _initPredictiveMaintenance() {
    _predictions = [
      PredictiveMaintenanceItem(deviceName: 'AC Compressor', component: 'Compressor Motor', daysUntilFailure: 45, confidence: 0.82, severity: 'Medium', recommendation: 'Schedule inspection in next 30 days', estimatedCost: 8500, severityColor: const Color(0xFFFF9800)),
      PredictiveMaintenanceItem(deviceName: 'Water Pump', component: 'Impeller Bearing', daysUntilFailure: 12, confidence: 0.91, severity: 'High', recommendation: 'Replace bearing immediately', estimatedCost: 2200, severityColor: const Color(0xFFF44336)),
      PredictiveMaintenanceItem(deviceName: 'Washing Machine', component: 'Drive Belt', daysUntilFailure: 90, confidence: 0.75, severity: 'Low', recommendation: 'Monitor vibration levels', estimatedCost: 1500, severityColor: const Color(0xFF4CAF50)),
      PredictiveMaintenanceItem(deviceName: 'HVAC Filter', component: 'Air Filter', daysUntilFailure: 8, confidence: 0.95, severity: 'Critical', recommendation: 'Replace filter NOW - efficiency dropping', estimatedCost: 500, severityColor: const Color(0xFFD32F2F)),
    ];
  }

  void _initAnomalies() {
    _anomalies = [
      AnomalyAlert(id: 'an1', timestamp: DateTime.now().subtract(const Duration(minutes: 30)), deviceName: 'Refrigerator', anomalyType: 'Usage Spike', description: 'Power consumption 40% above normal. Door may be open.', severity: 0.7, suggestedAction: 'Check refrigerator door seal', alertColor: const Color(0xFFFF9800)),
      AnomalyAlert(id: 'an2', timestamp: DateTime.now().subtract(const Duration(hours: 2)), deviceName: 'Water System', anomalyType: 'Leak', description: 'Continuous water flow detected for 45 minutes with no appliance active.', severity: 0.9, suggestedAction: 'Check for water leaks immediately', alertColor: const Color(0xFFF44336)),
      AnomalyAlert(id: 'an3', timestamp: DateTime.now().subtract(const Duration(hours: 6)), deviceName: 'Smart Lock', anomalyType: 'Unusual Pattern', description: 'Lock/unlock cycle detected 5 times in 10 minutes.', severity: 0.5, suggestedAction: 'Review security camera footage', alertColor: const Color(0xFFFF9800)),
    ];
  }

  void _initHabitLearning() {
    _learnedHabits = [
      LearnedHabit(id: 'h1', description: 'Morning coffee routine', pattern: 'Kettle ON → Kitchen light ON', confidence: 0.92, occurrences: 156, typicalTime: const TimeOfDay(hour: 6, minute: 45), typicalDays: [1,2,3,4,5], isAutomated: true, icon: Icons.coffee, color: const Color(0xFF795548)),
      LearnedHabit(id: 'h2', description: 'Evening relaxation', pattern: 'TV ON → Dim lights → AC 24°C', confidence: 0.87, occurrences: 98, typicalTime: const TimeOfDay(hour: 20, minute: 0), typicalDays: [1,2,3,4,5,6,7], icon: Icons.weekend, color: const Color(0xFF3F51B5)),
      LearnedHabit(id: 'h3', description: 'Weekend workout', pattern: 'Fan ON → Speaker ON → Bright lights', confidence: 0.78, occurrences: 45, typicalTime: const TimeOfDay(hour: 7, minute: 30), typicalDays: [6,7], icon: Icons.fitness_center, color: const Color(0xFF4CAF50)),
      LearnedHabit(id: 'h4', description: 'Late night work', pattern: 'Desk lamp ON → AC 23°C → Quiet mode', confidence: 0.85, occurrences: 72, typicalTime: const TimeOfDay(hour: 23, minute: 0), typicalDays: [1,2,3,4,5], icon: Icons.nightlight, color: const Color(0xFF9C27B0)),
      LearnedHabit(id: 'h5', description: 'Shower preparation', pattern: 'Geyser ON → Bathroom light ON → Exhaust ON', confidence: 0.94, occurrences: 200, typicalTime: const TimeOfDay(hour: 6, minute: 15), typicalDays: [1,2,3,4,5,6,7], isAutomated: true, icon: Icons.shower, color: const Color(0xFF00BCD4)),
    ];
  }

  void _initVoiceCommands() {
    _voiceCommands = [
      VoiceCommand(id: 'vc1', timestamp: DateTime.now().subtract(const Duration(minutes: 10)), transcript: 'Turn off all lights', action: 'Lights OFF - All rooms', wasSuccessful: true, confidence: 0.97),
      VoiceCommand(id: 'vc2', timestamp: DateTime.now().subtract(const Duration(minutes: 45)), transcript: 'Set AC to twenty four degrees', action: 'AC → 24°C', wasSuccessful: true, confidence: 0.93),
      VoiceCommand(id: 'vc3', timestamp: DateTime.now().subtract(const Duration(hours: 2)), transcript: 'What is the temperature?', action: 'Read sensor: 26.5°C', wasSuccessful: true, confidence: 0.95),
      VoiceCommand(id: 'vc4', timestamp: DateTime.now().subtract(const Duration(hours: 3)), transcript: 'Activate movie night', action: 'Scene: Movie Night activated', wasSuccessful: true, confidence: 0.91),
      VoiceCommand(id: 'vc5', timestamp: DateTime.now().subtract(const Duration(hours: 5)), transcript: 'Lock the front door', action: 'Front Door → Locked', wasSuccessful: true, confidence: 0.96),
    ];
  }

  void _initWeatherAutomation() {
    _weatherAutomations = [
      WeatherAutomation(id: 'wa1', name: 'Rain Protection', weatherCondition: 'Rain', threshold: 50, unit: '% chance', actions: ['Close all windows', 'Retract awning', 'Disable sprinklers'], icon: Icons.umbrella, color: const Color(0xFF2196F3)),
      WeatherAutomation(id: 'wa2', name: 'Heat Wave', weatherCondition: 'Hot', threshold: 38, unit: '°C', actions: ['Pre-cool AC to 22°C', 'Close blinds', 'Start ceiling fans'], icon: Icons.wb_sunny, color: const Color(0xFFFF5722)),
      WeatherAutomation(id: 'wa3', name: 'Cold Snap', weatherCondition: 'Cold', threshold: 5, unit: '°C', actions: ['Activate heating', 'Close all openings', 'Warm up water heater'], icon: Icons.ac_unit, color: const Color(0xFF00BCD4)),
      WeatherAutomation(id: 'wa4', name: 'Storm Protocol', weatherCondition: 'Storm', threshold: 80, unit: 'km/h', actions: ['Secure garage doors', 'Close blinds', 'Enable backup power', 'Alert family'], icon: Icons.thunderstorm, color: const Color(0xFF455A64)),
    ];
  }

  void _initCircadianLighting() {
    final hour = DateTime.now().hour;
    String phase;
    int colorTemp;
    int brightness;
    Color color;

    if (hour >= 5 && hour < 8) { phase = 'Dawn'; colorTemp = 3000; brightness = 40; color = const Color(0xFFFFCC80); }
    else if (hour >= 8 && hour < 12) { phase = 'Morning'; colorTemp = 5000; brightness = 80; color = const Color(0xFFFFF9C4); }
    else if (hour >= 12 && hour < 17) { phase = 'Day'; colorTemp = 6500; brightness = 100; color = const Color(0xFFFFFFFF); }
    else if (hour >= 17 && hour < 20) { phase = 'Evening'; colorTemp = 3500; brightness = 60; color = const Color(0xFFFFE0B2); }
    else { phase = 'Night'; colorTemp = 2700; brightness = 20; color = const Color(0xFFFFAB91); }

    _circadianLighting = CircadianLightingState(
      isEnabled: true, currentColorTemp: colorTemp, currentBrightness: brightness,
      currentPhase: phase, wakeTime: const TimeOfDay(hour: 6, minute: 30),
      sleepTime: const TimeOfDay(hour: 22, minute: 30), currentColor: color,
    );
  }

  void _initHVACZones() {
    _hvacZones = [
      HVACZone(id: 'hz1', name: 'Zone 1', room: 'Living Room', currentTemp: 26.5, targetTemp: 24, mode: 'Cool', isActive: true, fanSpeed: 3, humidity: 55, energyUsage: 4.2, modeColor: const Color(0xFF2196F3)),
      HVACZone(id: 'hz2', name: 'Zone 2', room: 'Bedroom', currentTemp: 24.0, targetTemp: 22, mode: 'Cool', isActive: true, fanSpeed: 2, humidity: 50, energyUsage: 3.1, modeColor: const Color(0xFF2196F3)),
      HVACZone(id: 'hz3', name: 'Zone 3', room: 'Kitchen', currentTemp: 28.0, targetTemp: 25, mode: 'Cool', isActive: false, fanSpeed: 0, humidity: 60, energyUsage: 0, modeColor: const Color(0xFF607D8B)),
      HVACZone(id: 'hz4', name: 'Zone 4', room: 'Office', currentTemp: 25.0, targetTemp: 23, mode: 'Auto', isActive: true, fanSpeed: 2, humidity: 48, energyUsage: 2.8, modeColor: const Color(0xFF4CAF50)),
    ];
  }

  void _initLifecycles() {
    _lifecycles = [
      ApplianceLifecycle(deviceName: 'Air Conditioner', purchaseDate: DateTime(2020, 6, 15), expectedLifeYears: 12, usageHours: 8500, healthPercent: 78, depreciation: 35, warrantyStatus: 'Expired', warrantyExpiry: DateTime(2023, 6, 15), maintenanceHistory: ['Gas refill - Jan 2023', 'Filter replaced - Aug 2023', 'Serviced - Mar 2024']),
      ApplianceLifecycle(deviceName: 'Refrigerator', purchaseDate: DateTime(2021, 3, 10), expectedLifeYears: 15, usageHours: 26280, healthPercent: 92, depreciation: 20, warrantyStatus: 'Active', warrantyExpiry: DateTime(2026, 3, 10)),
      ApplianceLifecycle(deviceName: 'Washing Machine', purchaseDate: DateTime(2019, 11, 1), expectedLifeYears: 10, usageHours: 3200, healthPercent: 65, depreciation: 50, warrantyStatus: 'Expired', warrantyExpiry: DateTime(2022, 11, 1)),
      ApplianceLifecycle(deviceName: 'Water Pump', purchaseDate: DateTime(2022, 1, 20), expectedLifeYears: 8, usageHours: 4800, healthPercent: 85, depreciation: 25, warrantyStatus: 'Active', warrantyExpiry: DateTime(2025, 1, 20)),
    ];
  }

  void _initSleepQuality() {
    _sleepHistory = List.generate(7, (i) {
      final score = 60 + _random.nextInt(35);
      return SleepQualityData(
        date: DateTime.now().subtract(Duration(days: 6 - i)),
        score: score.toDouble(),
        totalSleep: Duration(hours: 6 + _random.nextInt(3), minutes: _random.nextInt(60)),
        deepSleep: Duration(hours: 1, minutes: 30 + _random.nextInt(60)),
        remSleep: Duration(hours: 1, minutes: _random.nextInt(60)),
        lightSleep: Duration(hours: 2, minutes: _random.nextInt(60)),
        awakenings: _random.nextInt(4),
        avgRoomTemp: 22 + _random.nextDouble() * 4,
        avgHumidity: 45 + _random.nextDouble() * 15,
        avgNoise: 20 + _random.nextDouble() * 20,
        recommendation: score > 80 ? 'Great sleep! Keep room at this temperature.' : 'Try reducing room temperature by 1°C for better sleep.',
        scoreColor: score > 80 ? const Color(0xFF4CAF50) : score > 60 ? const Color(0xFFFF9800) : const Color(0xFFF44336),
      );
    });
  }

  void _initPlants() {
    _plants = [
      PlantCareData(id: 'p1', plantName: 'Indoor Fern', species: 'Nephrolepis', soilMoisture: 65, lightLevel: 300, temperature: 24, healthStatus: 'Healthy', lastWatered: DateTime.now().subtract(const Duration(hours: 12)), nextWatering: DateTime.now().add(const Duration(hours: 12)), careAdvice: 'Mist leaves daily for best results', icon: Icons.eco, statusColor: const Color(0xFF4CAF50)),
      PlantCareData(id: 'p2', plantName: 'Snake Plant', species: 'Sansevieria', soilMoisture: 30, lightLevel: 200, temperature: 25, healthStatus: 'Good', lastWatered: DateTime.now().subtract(const Duration(days: 3)), nextWatering: DateTime.now().add(const Duration(days: 4)), careAdvice: 'Low maintenance - water only when soil is dry', icon: Icons.grass, statusColor: const Color(0xFF8BC34A)),
      PlantCareData(id: 'p3', plantName: 'Tomato Plant', species: 'Solanum lycopersicum', soilMoisture: 45, lightLevel: 500, temperature: 26, healthStatus: 'Needs Water', lastWatered: DateTime.now().subtract(const Duration(days: 2)), nextWatering: DateTime.now(), careAdvice: 'Water immediately - soil moisture low', icon: Icons.local_florist, statusColor: const Color(0xFFFF9800)),
      PlantCareData(id: 'p4', plantName: 'Basil', species: 'Ocimum basilicum', soilMoisture: 70, lightLevel: 450, temperature: 25, healthStatus: 'Thriving', lastWatered: DateTime.now().subtract(const Duration(hours: 6)), nextWatering: DateTime.now().add(const Duration(hours: 18)), careAdvice: 'Perfect conditions! Harvest regularly for bushy growth', icon: Icons.spa, statusColor: const Color(0xFF4CAF50)),
    ];
  }

  void _initWeatherStation() {
    final hour = DateTime.now().hour;
    final conditions = ['Clear', 'Partly Cloudy', 'Cloudy', 'Light Rain'];
    final condition = conditions[_random.nextInt(conditions.length)];
    IconData condIcon;
    Color condColor;

    switch (condition) {
      case 'Clear': condIcon = Icons.wb_sunny; condColor = const Color(0xFFFF9800); break;
      case 'Partly Cloudy': condIcon = Icons.cloud; condColor = const Color(0xFF90CAF9); break;
      case 'Cloudy': condIcon = Icons.cloud_queue; condColor = const Color(0xFF78909C); break;
      default: condIcon = Icons.water_drop; condColor = const Color(0xFF2196F3); break;
    }

    _weatherStation = WeatherStationData(
      temperature: 25 + _random.nextDouble() * 12,
      humidity: 40 + _random.nextDouble() * 40,
      pressure: 1010 + _random.nextDouble() * 15,
      windSpeed: 5 + _random.nextDouble() * 25,
      windDirection: ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'][_random.nextInt(8)],
      rainfall: _random.nextDouble() * 5,
      uvIndex: hour >= 6 && hour <= 18 ? 2 + _random.nextDouble() * 8 : 0,
      dewPoint: 18 + _random.nextDouble() * 8,
      visibility: 5 + _random.nextDouble() * 15,
      condition: condition,
      conditionIcon: condIcon,
      conditionColor: condColor,
      hourlyForecast: List.generate(12, (i) {
        final h = (hour + i + 1) % 24;
        return HourlyForecast(
          hour: h, temp: 22 + _random.nextDouble() * 14,
          condition: conditions[_random.nextInt(conditions.length)],
          icon: h >= 6 && h <= 18 ? Icons.wb_sunny : Icons.nightlight,
        );
      }),
    );
  }

  void _initInventory() {
    _inventory = [
      HomeInventoryItem(id: 'inv1', name: 'Samsung Smart TV 55"', category: 'Electronics', room: 'Living Room', purchasePrice: 55000, purchaseDate: DateTime(2023, 1, 15), serialNumber: 'SN-TV-001', warrantyStatus: 'Active', condition: 'Excellent', categoryColor: const Color(0xFF2196F3)),
      HomeInventoryItem(id: 'inv2', name: 'Daikin AC 1.5 Ton', category: 'Appliance', room: 'Bedroom', purchasePrice: 42000, purchaseDate: DateTime(2022, 5, 10), serialNumber: 'SN-AC-001', warrantyStatus: 'Active', condition: 'Good', categoryColor: const Color(0xFF4CAF50)),
      HomeInventoryItem(id: 'inv3', name: 'LG Refrigerator', category: 'Appliance', room: 'Kitchen', purchasePrice: 38000, purchaseDate: DateTime(2021, 8, 20), serialNumber: 'SN-RF-001', warrantyStatus: 'Expired', condition: 'Good', categoryColor: const Color(0xFF4CAF50)),
      HomeInventoryItem(id: 'inv4', name: 'Bosch Washing Machine', category: 'Appliance', room: 'Utility', purchasePrice: 32000, purchaseDate: DateTime(2022, 11, 5), serialNumber: 'SN-WM-001', warrantyStatus: 'Active', condition: 'Excellent', categoryColor: const Color(0xFF4CAF50)),
      HomeInventoryItem(id: 'inv5', name: 'Jewellery Safe', category: 'Valuable', room: 'Bedroom', purchasePrice: 15000, purchaseDate: DateTime(2020, 3, 12), serialNumber: 'SN-SF-001', warrantyStatus: 'N/A', condition: 'Good', categoryColor: const Color(0xFFFF9800)),
    ];
  }

  void _initSmartNotifications() {
    _smartNotifications = [
      SmartNotification(id: 'n1', title: 'High Power Alert', body: 'Energy consumption exceeded 5kW threshold', category: 'Warning', timestamp: DateTime.now().subtract(const Duration(minutes: 15)), source: 'Energy Monitor', icon: Icons.bolt, color: const Color(0xFFFF9800)),
      SmartNotification(id: 'n2', title: 'Front Door Opened', body: 'Front door was opened 2 minutes ago', category: 'Info', timestamp: DateTime.now().subtract(const Duration(minutes: 20)), source: 'Security', icon: Icons.door_front_door, color: const Color(0xFF2196F3)),
      SmartNotification(id: 'n3', title: 'Filter Replacement Due', body: 'Air purifier filter life at 15%', category: 'Warning', timestamp: DateTime.now().subtract(const Duration(hours: 1)), source: 'Maintenance', icon: Icons.filter_alt, color: const Color(0xFFFF9800)),
      SmartNotification(id: 'n4', title: 'Water Tank Full', body: 'Water tank reached 95% capacity', category: 'Success', timestamp: DateTime.now().subtract(const Duration(hours: 2)), source: 'Water System', icon: Icons.water, color: const Color(0xFF4CAF50)),
      SmartNotification(id: 'n5', title: 'Smoke Detected!', body: 'Smoke sensor triggered in kitchen area', category: 'Critical', timestamp: DateTime.now().subtract(const Duration(hours: 4)), isRead: true, source: 'Safety', icon: Icons.local_fire_department, color: const Color(0xFFF44336)),
    ];
  }

  void _initAutomationRules() {
    _automationRules = [
      AutomationRule(id: 'ar1', name: 'Motion → Lights', triggerType: 'Sensor', triggerDevice: 'Motion Sensor', triggerCondition: 'equals', triggerValue: 'detected', actionDevice: 'Hallway Light', actionCommand: 'Turn ON for 5 min', executionCount: 234, lastTriggered: DateTime.now().subtract(const Duration(minutes: 30)), icon: Icons.motion_photos_on, color: const Color(0xFFFF9800)),
      AutomationRule(id: 'ar2', name: 'Temp → AC Auto', triggerType: 'Sensor', triggerDevice: 'Temperature', triggerCondition: 'greater than', triggerValue: '28°C', actionDevice: 'AC', actionCommand: 'Turn ON at 24°C', executionCount: 89, lastTriggered: DateTime.now().subtract(const Duration(hours: 2)), icon: Icons.thermostat_auto, color: const Color(0xFF2196F3)),
      AutomationRule(id: 'ar3', name: 'Sunset → Porch Light', triggerType: 'Time', triggerDevice: 'Clock', triggerCondition: 'at', triggerValue: 'Sunset', actionDevice: 'Porch Light', actionCommand: 'Turn ON', executionCount: 180, lastTriggered: DateTime.now().subtract(const Duration(hours: 6)), icon: Icons.wb_twilight, color: const Color(0xFF9C27B0)),
      AutomationRule(id: 'ar4', name: 'Door Open → Camera', triggerType: 'Device', triggerDevice: 'Front Door Lock', triggerCondition: 'equals', triggerValue: 'unlocked', actionDevice: 'Security Camera', actionCommand: 'Start recording', executionCount: 45, lastTriggered: DateTime.now().subtract(const Duration(hours: 4)), icon: Icons.videocam, color: const Color(0xFFF44336)),
      AutomationRule(id: 'ar5', name: 'Low Water → Pump', triggerType: 'Sensor', triggerDevice: 'Water Level', triggerCondition: 'less than', triggerValue: '20%', actionDevice: 'Water Pump', actionCommand: 'Turn ON', executionCount: 56, lastTriggered: DateTime.now().subtract(const Duration(hours: 8)), icon: Icons.water, color: const Color(0xFF00BCD4)),
    ];
  }

  void _initAudioZones() {
    _audioZones = [
      AudioZone(id: 'az1', room: 'Living Room', isPlaying: true, currentTrack: 'Blinding Lights', artist: 'The Weeknd', volume: 45, source: 'Spotify', isGrouped: true, groupName: 'Downstairs'),
      AudioZone(id: 'az2', room: 'Kitchen', isPlaying: true, currentTrack: 'Blinding Lights', artist: 'The Weeknd', volume: 30, source: 'Spotify', isGrouped: true, groupName: 'Downstairs'),
      AudioZone(id: 'az3', room: 'Bedroom', isPlaying: false, currentTrack: 'Calm Ocean', artist: 'Nature Sounds', volume: 20, source: 'Radio'),
      AudioZone(id: 'az4', room: 'Office', isPlaying: false, currentTrack: '', artist: '', volume: 50, source: 'Bluetooth'),
      AudioZone(id: 'az5', room: 'Garden', isPlaying: false, currentTrack: '', artist: '', volume: 60, source: 'AirPlay'),
    ];
  }

  void _initHomeTheater() {
    _homeTheater = HomeTheaterState(
      isActive: false, source: 'Streaming', volume: 50,
      audioMode: 'Surround', brightness: 80, aspectRatio: '16:9',
      projectorOn: false, surroundOn: false,
      connectedDevices: ['Smart TV', 'Soundbar', 'Subwoofer', 'Rear Speakers', 'Projector'],
    );
  }

  void _initGamingMode() {
    _gamingMode = GamingModeState(
      isActive: false, gameName: '', networkLatency: 12,
      downloadSpeed: 150.5, uploadSpeed: 45.2,
      lightingProfile: 'Default', displayRefreshRate: 60,
      performanceMode: false,
    );
  }

  void _initWellness() {
    _wellness = WellnessData(
      indoorAirScore: 82, stressLevel: 35, meditationMinutes: 15,
      ambientSound: 'None', aromaDiffuserLevel: 0, isMeditating: false,
      goals: [
        WellnessGoal(name: 'Meditation', progress: 0.6, unit: '30 min/day', color: const Color(0xFF9C27B0)),
        WellnessGoal(name: 'Air Quality', progress: 0.82, unit: 'AQI < 50', color: const Color(0xFF4CAF50)),
        WellnessGoal(name: 'Sleep Score', progress: 0.75, unit: '> 80/100', color: const Color(0xFF3F51B5)),
        WellnessGoal(name: 'Screen Time', progress: 0.45, unit: '< 4 hrs', color: const Color(0xFFFF9800)),
      ],
    );
  }

  void _initWorkout() {
    _workout = WorkoutEnvironment(
      isActive: false, workoutType: 'Cardio', durationMinutes: 0,
      caloriesBurned: 0, roomTemp: 24, fanSpeed: 3,
      musicPlaylist: 'Workout Mix', mirrorMode: false,
    );
  }

  void _initAquarium() {
    _aquarium = AquariumState(
      waterTemp: 26.0, pH: 7.0, ammonia: 0.02, nitrate: 10,
      lightOn: true, lightMode: 'Day', filterRunning: true,
      heaterOn: false, lastFed: DateTime.now().subtract(const Duration(hours: 8)),
      nextFeeding: DateTime.now().add(const Duration(hours: 4)),
      lastWaterChange: DateTime.now().subtract(const Duration(days: 5)),
      phColor: const Color(0xFF4CAF50),
    );
  }

  void _initWasteManagement() {
    _wasteManagement = WasteManagementData(
      generalBinLevel: 65, recycleBinLevel: 45, organicBinLevel: 80,
      nextCollectionDate: DateTime.now().add(const Duration(days: 2)),
      collectionType: 'General + Recycle',
      monthlyWaste: 45.5, recyclingRate: 38,
      history: [
        WasteHistory(date: DateTime.now().subtract(const Duration(days: 7)), type: 'General', weight: 5.2),
        WasteHistory(date: DateTime.now().subtract(const Duration(days: 7)), type: 'Recycle', weight: 3.1),
        WasteHistory(date: DateTime.now().subtract(const Duration(days: 14)), type: 'General', weight: 4.8),
      ],
    );
  }

  // ===== ACTION METHODS =====
  void toggleBlindsPosition(String id, int position) {
    final idx = _blinds.indexWhere((b) => b.id == id);
    if (idx >= 0) {
      final b = _blinds[idx];
      _blinds[idx] = SmartBlindsState(id: b.id, name: b.name, room: b.room, position: position, tiltAngle: b.tiltAngle, isAutoMode: b.isAutoMode, schedule: b.schedule);
      notifyListeners();
    }
  }

  void startRobotVacuum() {
    _robotVacuum = RobotVacuumState(
      id: 'rv1', name: _robotVacuum!.name, status: 'Cleaning',
      batteryLevel: _robotVacuum!.batteryLevel, areaCleaned: 0,
      cleaningTime: 0, currentRoom: 'Living Room', mode: _robotVacuum!.mode,
      dustbinLevel: _robotVacuum!.dustbinLevel, statusColor: const Color(0xFF2196F3),
      cleaningHistory: _robotVacuum!.cleaningHistory,
    );
    notifyListeners();
  }

  void stopRobotVacuum() {
    _robotVacuum = RobotVacuumState(
      id: 'rv1', name: _robotVacuum!.name, status: 'Returning',
      batteryLevel: _robotVacuum!.batteryLevel - 10, areaCleaned: _robotVacuum!.areaCleaned,
      cleaningTime: _robotVacuum!.cleaningTime, currentRoom: 'Returning to dock',
      mode: _robotVacuum!.mode, dustbinLevel: _robotVacuum!.dustbinLevel + 15,
      statusColor: const Color(0xFFFF9800),
      cleaningHistory: _robotVacuum!.cleaningHistory,
    );
    notifyListeners();
  }

  void toggleGarageDoor(String id) {
    final idx = _garageDoors.indexWhere((g) => g.id == id);
    if (idx >= 0) {
      final g = _garageDoors[idx];
      _garageDoors[idx] = GarageDoorState(id: g.id, name: g.name, isOpen: !g.isOpen, vehiclePresent: g.vehiclePresent, lastOpened: DateTime.now(), autoCloseEnabled: g.autoCloseEnabled, autoCloseMinutes: g.autoCloseMinutes);
      notifyListeners();
    }
  }

  void toggleSprinklerZone(String id) {
    final idx = _sprinklerZones.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      final s = _sprinklerZones[idx];
      _sprinklerZones[idx] = SprinklerZone(id: s.id, name: s.name, isActive: !s.isActive, durationMinutes: s.durationMinutes, schedule: s.schedule, moistureLevel: s.moistureLevel, rainDelay: s.rainDelay, plantType: s.plantType);
      notifyListeners();
    }
  }

  void feedPet(String id) {
    final idx = _petFeeders.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      final p = _petFeeders[idx];
      _petFeeders[idx] = PetFeederState(id: p.id, petName: p.petName, foodLevel: (p.foodLevel - 10).clamp(0, 100), waterLevel: p.waterLevel, schedules: p.schedules, lastFed: DateTime.now(), portionSize: p.portionSize, foodType: p.foodType);
      notifyListeners();
    }
  }

  void toggleAirPurifier(String id) {
    final idx = _airPurifiers.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final a = _airPurifiers[idx];
      _airPurifiers[idx] = AirPurifierState(id: a.id, name: a.name, isOn: !a.isOn, mode: a.mode, fanSpeed: a.fanSpeed, filterLife: a.filterLife, pm25: a.pm25, pm10: a.pm10, aqi: a.aqi, aqiColor: a.aqiColor);
      notifyListeners();
    }
  }

  void acknowledgeAnomaly(String id) {
    final idx = _anomalies.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final a = _anomalies[idx];
      _anomalies[idx] = AnomalyAlert(id: a.id, timestamp: a.timestamp, deviceName: a.deviceName, anomalyType: a.anomalyType, description: a.description, severity: a.severity, isAcknowledged: true, suggestedAction: a.suggestedAction, alertColor: a.alertColor);
      notifyListeners();
    }
  }

  void toggleHabitAutomation(String id) {
    final idx = _learnedHabits.indexWhere((h) => h.id == id);
    if (idx >= 0) {
      final h = _learnedHabits[idx];
      _learnedHabits[idx] = LearnedHabit(id: h.id, description: h.description, pattern: h.pattern, confidence: h.confidence, occurrences: h.occurrences, typicalTime: h.typicalTime, typicalDays: h.typicalDays, isAutomated: !h.isAutomated, icon: h.icon, color: h.color);
      notifyListeners();
    }
  }

  void toggleWeatherAutomation(String id) {
    final rule = _weatherAutomations.firstWhere((w) => w.id == id);
    rule.isEnabled = !rule.isEnabled;
    notifyListeners();
  }

  void toggleAutomationRule(String id) {
    final idx = _automationRules.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      final r = _automationRules[idx];
      _automationRules[idx] = AutomationRule(id: r.id, name: r.name, triggerType: r.triggerType, triggerDevice: r.triggerDevice, triggerCondition: r.triggerCondition, triggerValue: r.triggerValue, actionDevice: r.actionDevice, actionCommand: r.actionCommand, isEnabled: !r.isEnabled, executionCount: r.executionCount, lastTriggered: r.lastTriggered, icon: r.icon, color: r.color);
      notifyListeners();
    }
  }

  void toggleAudioZone(String id) {
    final idx = _audioZones.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final a = _audioZones[idx];
      _audioZones[idx] = AudioZone(id: a.id, room: a.room, isPlaying: !a.isPlaying, currentTrack: a.currentTrack, artist: a.artist, volume: a.volume, source: a.source, isGrouped: a.isGrouped, groupName: a.groupName);
      notifyListeners();
    }
  }

  void setAudioVolume(String id, int volume) {
    final idx = _audioZones.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      final a = _audioZones[idx];
      _audioZones[idx] = AudioZone(id: a.id, room: a.room, isPlaying: a.isPlaying, currentTrack: a.currentTrack, artist: a.artist, volume: volume, source: a.source, isGrouped: a.isGrouped, groupName: a.groupName);
      notifyListeners();
    }
  }

  void toggleHomeTheater() {
    _homeTheater = HomeTheaterState(
      isActive: !_homeTheater!.isActive, source: _homeTheater!.source,
      volume: _homeTheater!.volume, audioMode: _homeTheater!.audioMode,
      brightness: _homeTheater!.brightness, aspectRatio: _homeTheater!.aspectRatio,
      projectorOn: !_homeTheater!.isActive, surroundOn: !_homeTheater!.isActive,
      connectedDevices: _homeTheater!.connectedDevices,
    );
    notifyListeners();
  }

  void toggleGamingMode() {
    _gamingMode = GamingModeState(
      isActive: !_gamingMode!.isActive, gameName: _gamingMode!.gameName,
      networkLatency: _gamingMode!.networkLatency, downloadSpeed: _gamingMode!.downloadSpeed,
      uploadSpeed: _gamingMode!.uploadSpeed, lightingProfile: _gamingMode!.isActive ? 'Default' : 'Gaming RGB',
      displayRefreshRate: _gamingMode!.isActive ? 60 : 144,
      performanceMode: !_gamingMode!.isActive,
    );
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final idx = _smartNotifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      final n = _smartNotifications[idx];
      _smartNotifications[idx] = SmartNotification(id: n.id, title: n.title, body: n.body, category: n.category, timestamp: n.timestamp, isRead: true, source: n.source, icon: n.icon, color: n.color, actionUrl: n.actionUrl);
      notifyListeners();
    }
  }

  void setHVACZoneTemp(String id, double temp) {
    final idx = _hvacZones.indexWhere((z) => z.id == id);
    if (idx >= 0) {
      final z = _hvacZones[idx];
      _hvacZones[idx] = HVACZone(id: z.id, name: z.name, room: z.room, currentTemp: z.currentTemp, targetTemp: temp, mode: z.mode, isActive: z.isActive, fanSpeed: z.fanSpeed, humidity: z.humidity, energyUsage: z.energyUsage, modeColor: z.modeColor);
      notifyListeners();
    }
  }

  void toggleHVACZone(String id) {
    final idx = _hvacZones.indexWhere((z) => z.id == id);
    if (idx >= 0) {
      final z = _hvacZones[idx];
      _hvacZones[idx] = HVACZone(id: z.id, name: z.name, room: z.room, currentTemp: z.currentTemp, targetTemp: z.targetTemp, mode: z.mode, isActive: !z.isActive, fanSpeed: z.isActive ? 0 : 2, humidity: z.humidity, energyUsage: z.isActive ? 0 : z.energyUsage, modeColor: z.isActive ? const Color(0xFF607D8B) : const Color(0xFF2196F3));
      notifyListeners();
    }
  }

  // ===== LIVE DATA UPDATE =====
  void _updateLiveData() {
    // Update weather station
    if (_weatherStation != null) {
      _initWeatherStation();
    }

    // Update EV charger progress
    if (_evCharger != null && _evCharger!.status == 'Charging') {
      final newCharge = (_evCharger!.chargeLevel + 0.5).clamp(0.0, 100.0);
      _evCharger = EVChargerState(
        id: _evCharger!.id, vehicleName: _evCharger!.vehicleName,
        status: newCharge >= 100 ? 'Complete' : 'Charging',
        chargeLevel: newCharge, chargingPower: newCharge >= 100 ? 0 : _evCharger!.chargingPower,
        energyDelivered: _evCharger!.energyDelivered + 0.1,
        estimatedMinutes: ((100 - newCharge) * 2).round(),
        estimatedCost: _evCharger!.estimatedCost + 0.15,
        isScheduled: _evCharger!.isScheduled, scheduledStart: _evCharger!.scheduledStart,
        statusColor: newCharge >= 100 ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
      );
    }

    // Update baby monitor randomly
    if (_babyMonitor != null && _random.nextInt(5) == 0) {
      final isCrying = _random.nextInt(10) == 0;
      _babyMonitor = BabyMonitorState(
        id: 'bm1', babyName: _babyMonitor!.babyName,
        roomTemp: 21 + _random.nextDouble() * 4, humidity: 45 + _random.nextDouble() * 15,
        noiseLevel: isCrying ? 70 + _random.nextDouble() * 20 : 10 + _random.nextDouble() * 20,
        isCrying: isCrying, motionDetected: _random.nextBool(),
        sleepStatus: isCrying ? 'Awake' : 'Sleeping',
        sleepDuration: _babyMonitor!.sleepDuration + const Duration(seconds: 8),
        statusColor: isCrying ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
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
