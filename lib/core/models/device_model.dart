import 'package:flutter/material.dart';

class SmartDevice {
  final String id;
  final String name;
  final String room;
  final DeviceType type;
  final bool isOnline;
  bool isOn;
  double? brightness;
  double? speed;
  double? temperature;
  String? color;
  final Map<String, dynamic>? metadata;
  final DateTime lastUpdated;

  SmartDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    this.isOnline = true,
    this.isOn = false,
    this.brightness,
    this.speed,
    this.temperature,
    this.color,
    this.metadata,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory SmartDevice.fromJson(Map<String, dynamic> json) {
    return SmartDevice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      room: json['room'] ?? '',
      type: DeviceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DeviceType.light,
      ),
      isOnline: json['isOnline'] ?? true,
      isOn: json['isOn'] ?? false,
      brightness: json['brightness']?.toDouble(),
      speed: json['speed']?.toDouble(),
      temperature: json['temperature']?.toDouble(),
      color: json['color'],
      metadata: json['metadata'],
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'room': room,
        'type': type.name,
        'isOnline': isOnline,
        'isOn': isOn,
        'brightness': brightness,
        'speed': speed,
        'temperature': temperature,
        'color': color,
        'metadata': metadata,
        'lastUpdated': lastUpdated.toIso8601String(),
      };
}

enum DeviceType {
  light,
  fan,
  ac,
  tv,
  speaker,
  lock,
  camera,
  thermostat,
  curtain,
  plug,
  buzzer,
  motor,
  waterPump,
  geyser,
  refrigerator,
  // ===== NEW DEVICES =====
  smartBlinds,
  robotVacuum,
  smartOven,
  washingMachine,
  dishwasher,
  dryer,
  garageDoor,
  sprinkler,
  petFeeder,
  babyMonitor,
  smokeDetector,
  smartMirror,
  evCharger,
  poolController,
  wineCooler,
  doorbell,
  airPurifier,
  humidifier,
  dehumidifier,
  robotMower,
  smartFaucet,
  smartScale,
  smartBed,
  projector,
  gameConsole,
  ceilingFan,
  exhaustFan,
  waterHeater,
  solarInverter,
  batteryStorage,
  windTurbine,
  generator,
  intercom,
  smartSwitch,
  motionSensor,
  smokeSensor,
}

extension DeviceTypeExtension on DeviceType {
  String get displayName {
    switch (this) {
      case DeviceType.light: return 'Light';
      case DeviceType.fan: return 'Fan';
      case DeviceType.ac: return 'Air Conditioner';
      case DeviceType.tv: return 'Television';
      case DeviceType.speaker: return 'Speaker';
      case DeviceType.lock: return 'Smart Lock';
      case DeviceType.camera: return 'Camera';
      case DeviceType.thermostat: return 'Thermostat';
      case DeviceType.curtain: return 'Curtain';
      case DeviceType.plug: return 'Smart Plug';
      case DeviceType.buzzer: return 'Buzzer';
      case DeviceType.motor: return 'Motor';
      case DeviceType.waterPump: return 'Water Pump';
      case DeviceType.geyser: return 'Geyser';
      case DeviceType.refrigerator: return 'Refrigerator';
      case DeviceType.smartBlinds: return 'Smart Blinds';
      case DeviceType.robotVacuum: return 'Robot Vacuum';
      case DeviceType.smartOven: return 'Smart Oven';
      case DeviceType.washingMachine: return 'Washing Machine';
      case DeviceType.dishwasher: return 'Dishwasher';
      case DeviceType.dryer: return 'Dryer';
      case DeviceType.garageDoor: return 'Garage Door';
      case DeviceType.sprinkler: return 'Sprinkler';
      case DeviceType.petFeeder: return 'Pet Feeder';
      case DeviceType.babyMonitor: return 'Baby Monitor';
      case DeviceType.smokeDetector: return 'Smoke Detector';
      case DeviceType.smartMirror: return 'Smart Mirror';
      case DeviceType.evCharger: return 'EV Charger';
      case DeviceType.poolController: return 'Pool Controller';
      case DeviceType.wineCooler: return 'Wine Cooler';
      case DeviceType.doorbell: return 'Smart Doorbell';
      case DeviceType.airPurifier: return 'Air Purifier';
      case DeviceType.humidifier: return 'Humidifier';
      case DeviceType.dehumidifier: return 'Dehumidifier';
      case DeviceType.robotMower: return 'Robot Mower';
      case DeviceType.smartFaucet: return 'Smart Faucet';
      case DeviceType.smartScale: return 'Smart Scale';
      case DeviceType.smartBed: return 'Smart Bed';
      case DeviceType.projector: return 'Projector';
      case DeviceType.gameConsole: return 'Game Console';
      case DeviceType.ceilingFan: return 'Ceiling Fan';
      case DeviceType.exhaustFan: return 'Exhaust Fan';
      case DeviceType.waterHeater: return 'Water Heater';
      case DeviceType.solarInverter: return 'Solar Inverter';
      case DeviceType.batteryStorage: return 'Battery Storage';
      case DeviceType.windTurbine: return 'Wind Turbine';
      case DeviceType.generator: return 'Generator';
      case DeviceType.intercom: return 'Intercom';
      case DeviceType.smartSwitch: return 'Smart Switch';
      case DeviceType.motionSensor: return 'Motion Sensor';
      case DeviceType.smokeSensor: return 'Smoke Sensor';
    }
  }

  IconData get icon {
    switch (this) {
      case DeviceType.light: return Icons.lightbulb_outline;
      case DeviceType.fan: return Icons.air;
      case DeviceType.ac: return Icons.ac_unit;
      case DeviceType.tv: return Icons.tv;
      case DeviceType.speaker: return Icons.speaker;
      case DeviceType.lock: return Icons.lock_outline;
      case DeviceType.camera: return Icons.videocam_outlined;
      case DeviceType.thermostat: return Icons.device_thermostat;
      case DeviceType.curtain: return Icons.blinds;
      case DeviceType.plug: return Icons.power;
      case DeviceType.buzzer: return Icons.notifications_active;
      case DeviceType.motor: return Icons.settings;
      case DeviceType.waterPump: return Icons.water;
      case DeviceType.geyser: return Icons.hot_tub;
      case DeviceType.refrigerator: return Icons.kitchen;
      case DeviceType.smartBlinds: return Icons.blinds_closed;
      case DeviceType.robotVacuum: return Icons.cleaning_services;
      case DeviceType.smartOven: return Icons.microwave;
      case DeviceType.washingMachine: return Icons.local_laundry_service;
      case DeviceType.dishwasher: return Icons.countertops;
      case DeviceType.dryer: return Icons.dry_cleaning;
      case DeviceType.garageDoor: return Icons.garage;
      case DeviceType.sprinkler: return Icons.grass;
      case DeviceType.petFeeder: return Icons.pets;
      case DeviceType.babyMonitor: return Icons.child_care;
      case DeviceType.smokeDetector: return Icons.smoke_free;
      case DeviceType.smartMirror: return Icons.smart_button;
      case DeviceType.evCharger: return Icons.ev_station;
      case DeviceType.poolController: return Icons.pool;
      case DeviceType.wineCooler: return Icons.wine_bar;
      case DeviceType.doorbell: return Icons.doorbell;
      case DeviceType.airPurifier: return Icons.air;
      case DeviceType.humidifier: return Icons.water_drop;
      case DeviceType.dehumidifier: return Icons.deblur;
      case DeviceType.robotMower: return Icons.content_cut;
      case DeviceType.smartFaucet: return Icons.bathroom;
      case DeviceType.smartScale: return Icons.monitor_weight;
      case DeviceType.smartBed: return Icons.bed;
      case DeviceType.projector: return Icons.videocam;
      case DeviceType.gameConsole: return Icons.sports_esports;
      case DeviceType.ceilingFan: return Icons.mode_fan_off;
      case DeviceType.exhaustFan: return Icons.air;
      case DeviceType.waterHeater: return Icons.water;
      case DeviceType.solarInverter: return Icons.solar_power;
      case DeviceType.batteryStorage: return Icons.battery_charging_full;
      case DeviceType.windTurbine: return Icons.wind_power;
      case DeviceType.generator: return Icons.electrical_services;
      case DeviceType.intercom: return Icons.record_voice_over;
      case DeviceType.smartSwitch: return Icons.toggle_on;
      case DeviceType.motionSensor: return Icons.sensors;
      case DeviceType.smokeSensor: return Icons.smoke_free;
    }
  }

  Color get color {
    switch (this) {
      case DeviceType.light: return const Color(0xFFFFE66D);
      case DeviceType.fan: return const Color(0xFF4FACFE);
      case DeviceType.ac: return const Color(0xFF00D9FF);
      case DeviceType.tv: return const Color(0xFF6C63FF);
      case DeviceType.speaker: return const Color(0xFFFF6584);
      case DeviceType.lock: return const Color(0xFF00C48C);
      case DeviceType.camera: return const Color(0xFFFF4757);
      case DeviceType.thermostat: return const Color(0xFFFF6B6B);
      case DeviceType.curtain: return const Color(0xFFA78BFA);
      case DeviceType.plug: return const Color(0xFFFFAA00);
      case DeviceType.buzzer: return const Color(0xFFFF6348);
      case DeviceType.motor: return const Color(0xFF667EEA);
      case DeviceType.waterPump: return const Color(0xFF00B4D8);
      case DeviceType.geyser: return const Color(0xFFF093FB);
      case DeviceType.refrigerator: return const Color(0xFF48DBFB);
      case DeviceType.smartBlinds: return const Color(0xFFB39DDB);
      case DeviceType.robotVacuum: return const Color(0xFF26A69A);
      case DeviceType.smartOven: return const Color(0xFFE65100);
      case DeviceType.washingMachine: return const Color(0xFF0288D1);
      case DeviceType.dishwasher: return const Color(0xFF00897B);
      case DeviceType.dryer: return const Color(0xFF8D6E63);
      case DeviceType.garageDoor: return const Color(0xFF546E7A);
      case DeviceType.sprinkler: return const Color(0xFF66BB6A);
      case DeviceType.petFeeder: return const Color(0xFFFFB74D);
      case DeviceType.babyMonitor: return const Color(0xFFF48FB1);
      case DeviceType.smokeDetector: return const Color(0xFFEF5350);
      case DeviceType.smartMirror: return const Color(0xFF90CAF9);
      case DeviceType.evCharger: return const Color(0xFF43A047);
      case DeviceType.poolController: return const Color(0xFF29B6F6);
      case DeviceType.wineCooler: return const Color(0xFF8E24AA);
      case DeviceType.doorbell: return const Color(0xFF5C6BC0);
      case DeviceType.airPurifier: return const Color(0xFF80DEEA);
      case DeviceType.humidifier: return const Color(0xFF4DD0E1);
      case DeviceType.dehumidifier: return const Color(0xFFFFCC80);
      case DeviceType.robotMower: return const Color(0xFF81C784);
      case DeviceType.smartFaucet: return const Color(0xFF4FC3F7);
      case DeviceType.smartScale: return const Color(0xFFCE93D8);
      case DeviceType.smartBed: return const Color(0xFF7986CB);
      case DeviceType.projector: return const Color(0xFF9575CD);
      case DeviceType.gameConsole: return const Color(0xFFE040FB);
      case DeviceType.ceilingFan: return const Color(0xFF64B5F6);
      case DeviceType.exhaustFan: return const Color(0xFF90A4AE);
      case DeviceType.waterHeater: return const Color(0xFFE57373);
      case DeviceType.solarInverter: return const Color(0xFFFFD54F);
      case DeviceType.batteryStorage: return const Color(0xFF4DB6AC);
      case DeviceType.windTurbine: return const Color(0xFF81D4FA);
      case DeviceType.generator: return const Color(0xFFA1887F);
      case DeviceType.intercom: return const Color(0xFF7E57C2);
      case DeviceType.smartSwitch: return const Color(0xFF42A5F5);
      case DeviceType.motionSensor: return const Color(0xFFAED581);
      case DeviceType.smokeSensor: return const Color(0xFFFF8A65);
    }
  }

  bool get hasSlider {
    return this == DeviceType.light ||
        this == DeviceType.fan ||
        this == DeviceType.ac ||
        this == DeviceType.thermostat ||
        this == DeviceType.speaker ||
        this == DeviceType.smartBlinds ||
        this == DeviceType.humidifier ||
        this == DeviceType.dehumidifier ||
        this == DeviceType.airPurifier ||
        this == DeviceType.ceilingFan ||
        this == DeviceType.waterHeater ||
        this == DeviceType.projector;
  }
}

class Room {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> deviceIds;
  final String? imageUrl;

  Room({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.deviceIds = const [],
    this.imageUrl,
  });
}

class Schedule {
  final String id;
  final String deviceId;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final List<int> daysOfWeek;
  final bool isEnabled;
  final String action;

  Schedule({
    required this.id,
    required this.deviceId,
    required this.startTime,
    this.endTime,
    required this.daysOfWeek,
    this.isEnabled = true,
    required this.action,
  });
}
