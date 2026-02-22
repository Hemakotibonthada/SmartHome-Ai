class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final UserRole role;
  final String? homeId;
  final DateTime createdAt;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = UserRole.user,
    this.homeId,
    DateTime? createdAt,
    this.preferences,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.user,
      ),
      homeId: json['homeId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': role.name,
        'homeId': homeId,
        'createdAt': createdAt.toIso8601String(),
        'preferences': preferences,
      };
}

enum UserRole {
  admin,
  user,
  guest,
}

class AIInsight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final InsightPriority priority;
  final double? potentialSaving;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? actionSuggestion;

  AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.priority = InsightPriority.medium,
    this.potentialSaving,
    DateTime? timestamp,
    this.data,
    this.actionSuggestion,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum InsightType {
  energySaving,
  anomalyDetection,
  usagePattern,
  maintenance,
  safety,
  comfort,
  waterManagement,
}

enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

class EnergyStats {
  final double totalConsumption;
  final double dailyAverage;
  final double monthlyEstimate;
  final double costEstimate;
  final double peakUsage;
  final double offPeakUsage;
  final List<HourlyUsage> hourlyData;
  final List<DailyUsage> weeklyData;

  EnergyStats({
    required this.totalConsumption,
    required this.dailyAverage,
    required this.monthlyEstimate,
    required this.costEstimate,
    required this.peakUsage,
    required this.offPeakUsage,
    required this.hourlyData,
    required this.weeklyData,
  });
}

class HourlyUsage {
  final int hour;
  final double usage;

  HourlyUsage({required this.hour, required this.usage});
}

class DailyUsage {
  final String day;
  final double usage;

  DailyUsage({required this.day, required this.usage});
}
