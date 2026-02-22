import 'package:flutter/material.dart';

class SensorData {
  final String id;
  final String deviceId;
  final SensorType type;
  final double value;
  final String unit;
  final DateTime timestamp;
  final double? minThreshold;
  final double? maxThreshold;

  SensorData({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.minThreshold,
    this.maxThreshold,
  });

  bool get isAlert {
    if (minThreshold != null && value < minThreshold!) return true;
    if (maxThreshold != null && value > maxThreshold!) return true;
    return false;
  }

  double get normalizedValue {
    final min = minThreshold ?? 0;
    final max = maxThreshold ?? 100;
    return ((value - min) / (max - min)).clamp(0.0, 1.0);
  }

  String get formattedValue => '${value.toStringAsFixed(1)} $unit';

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'] ?? '',
      deviceId: json['deviceId'] ?? '',
      type: SensorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SensorType.temperature,
      ),
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      minThreshold: json['minThreshold']?.toDouble(),
      maxThreshold: json['maxThreshold']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'type': type.name,
        'value': value,
        'unit': unit,
        'timestamp': timestamp.toIso8601String(),
        'minThreshold': minThreshold,
        'maxThreshold': maxThreshold,
      };
}

enum SensorType {
  temperature,
  humidity,
  voltage,
  current,
  power,
  waterLevel,
  ultrasonic,
  motion,
  light,
  gas,
  smoke,
}

extension SensorTypeExtension on SensorType {
  String get displayName {
    switch (this) {
      case SensorType.temperature:
        return 'Temperature';
      case SensorType.humidity:
        return 'Humidity';
      case SensorType.voltage:
        return 'Voltage';
      case SensorType.current:
        return 'Current';
      case SensorType.power:
        return 'Power';
      case SensorType.waterLevel:
        return 'Water Level';
      case SensorType.ultrasonic:
        return 'Distance';
      case SensorType.motion:
        return 'Motion';
      case SensorType.light:
        return 'Light';
      case SensorType.gas:
        return 'Gas';
      case SensorType.smoke:
        return 'Smoke';
    }
  }

  String get unit {
    switch (this) {
      case SensorType.temperature:
        return '°C';
      case SensorType.humidity:
        return '%';
      case SensorType.voltage:
        return 'V';
      case SensorType.current:
        return 'A';
      case SensorType.power:
        return 'W';
      case SensorType.waterLevel:
        return '%';
      case SensorType.ultrasonic:
        return 'cm';
      case SensorType.motion:
        return '';
      case SensorType.light:
        return 'lux';
      case SensorType.gas:
        return 'ppm';
      case SensorType.smoke:
        return 'ppm';
    }
  }

  IconData get icon {
    switch (this) {
      case SensorType.temperature:
        return Icons.thermostat;
      case SensorType.humidity:
        return Icons.water_drop;
      case SensorType.voltage:
        return Icons.bolt;
      case SensorType.current:
        return Icons.electrical_services;
      case SensorType.power:
        return Icons.power;
      case SensorType.waterLevel:
        return Icons.water;
      case SensorType.ultrasonic:
        return Icons.sensors;
      case SensorType.motion:
        return Icons.directions_walk;
      case SensorType.light:
        return Icons.light_mode;
      case SensorType.gas:
        return Icons.cloud;
      case SensorType.smoke:
        return Icons.smoke_free;
    }
  }

  Color get color {
    switch (this) {
      case SensorType.temperature:
        return const Color(0xFFFF6B6B);
      case SensorType.humidity:
        return const Color(0xFF4FACFE);
      case SensorType.voltage:
        return const Color(0xFFF093FB);
      case SensorType.current:
        return const Color(0xFFFFAA00);
      case SensorType.power:
        return const Color(0xFFFF6584);
      case SensorType.waterLevel:
        return const Color(0xFF667EEA);
      case SensorType.ultrasonic:
        return const Color(0xFF00C48C);
      case SensorType.motion:
        return const Color(0xFF6C63FF);
      case SensorType.light:
        return const Color(0xFFFFE66D);
      case SensorType.gas:
        return const Color(0xFFFF4757);
      case SensorType.smoke:
        return const Color(0xFFFF6348);
    }
  }
}
