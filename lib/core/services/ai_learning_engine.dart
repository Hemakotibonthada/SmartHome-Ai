import 'dart:math';
import 'package:flutter/foundation.dart';

/// AI Learning & Adaptation Engine — Features 46-60
/// User behavior learning, pattern recognition, and adaptive preferences.
///
/// Features:
/// 46. User behavior learning
/// 47. Sleep pattern learning
/// 48. Preferred temperature learning
/// 49. Lighting preference learning
/// 50. Usage schedule learning
/// 51. Comfort preference adaptation
/// 52. Energy saving habit formation
/// 53. Routine detection and suggestion
/// 54. Seasonal behavior adaptation
/// 55. Weekend vs weekday pattern recognition
/// 56. Guest behavior profiling
/// 57. Contextual scene learning
/// 58. Adaptive threshold adjustment
/// 59. Learning optimal device combinations
/// 60. Personalized notification timing

class AILearningEngine extends ChangeNotifier {
  final Random _random = Random();
  bool _isInitialized = false;

  final Map<String, dynamic> _userProfile = {};
  final Map<String, List<Map<String, dynamic>>> _behaviorHistory = {};
  final Map<String, dynamic> _learnedPreferences = {};
  int _learningIterations = 0;

  bool get isInitialized => _isInitialized;
  Map<String, dynamic> get userProfile => Map.unmodifiable(_userProfile);
  Map<String, dynamic> get learnedPreferences => Map.unmodifiable(_learnedPreferences);
  int get learningIterations => _learningIterations;

  void initialize() {
    if (_isInitialized) return;
    _buildUserProfile();
    _seedBehaviorHistory();
    _learnPreferences();
    _isInitialized = true;
    notifyListeners();
  }

  void _buildUserProfile() {
    _userProfile.addAll({
      'profile_created': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'data_points_collected': 5000 + _random.nextInt(3000),
      'learning_confidence': 0.78 + _random.nextDouble() * 0.15,
      'adaptation_rate': 0.85,
    });
  }

  void _seedBehaviorHistory() {
    // Seed 90 days of simulated behavior data
    for (int day = 0; day < 90; day++) {
      final date = DateTime.now().subtract(Duration(days: 90 - day));
      final isWeekend = date.weekday >= 6;

      _behaviorHistory.putIfAbsent('wake_time', () => []).add({
        'date': date.toIso8601String().split('T')[0],
        'time': isWeekend ? '08:${30 + _random.nextInt(30)}' : '06:${15 + _random.nextInt(30)}',
        'is_weekend': isWeekend,
      });

      _behaviorHistory.putIfAbsent('sleep_time', () => []).add({
        'date': date.toIso8601String().split('T')[0],
        'time': isWeekend ? '23:${30 + _random.nextInt(30)}' : '22:${_random.nextInt(30)}',
        'is_weekend': isWeekend,
      });

      _behaviorHistory.putIfAbsent('temp_preference', () => []).add({
        'date': date.toIso8601String().split('T')[0],
        'set_temp': isWeekend ? 23 + _random.nextInt(3) : 24 + _random.nextInt(2),
        'season': _getSeason(date),
      });

      _behaviorHistory.putIfAbsent('energy_usage', () => []).add({
        'date': date.toIso8601String().split('T')[0],
        'kwh': isWeekend ? 18 + _random.nextInt(8) : 12 + _random.nextInt(6),
        'is_weekend': isWeekend,
      });
    }
  }

  String _getSeason(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'autumn';
    return 'winter';
  }

  void _learnPreferences() {
    _learnedPreferences.addAll({
      'temperature': _learnTemperaturePreference(),
      'lighting': _learnLightingPreference(),
      'schedule': _learnSchedule(),
      'comfort': _learnComfortPreference(),
    });
    _learningIterations++;
  }

  // ─── Feature 46: User Behavior Learning ───────────────────────────

  Map<String, dynamic> learnUserBehavior() {
    final behaviors = <Map<String, dynamic>>[];

    behaviors.add({
      'behavior': 'morning_routine',
      'pattern': 'Wake → Bathroom → Kitchen → Coffee → News',
      'confidence': 0.89,
      'times_observed': 62,
      'typical_duration_minutes': 45,
      'devices_used': ['bathroom_light', 'kitchen_light', 'coffee_maker', 'tv'],
    });

    behaviors.add({
      'behavior': 'evening_routine',
      'pattern': 'Arrive → Living Room → Kitchen → Dinner → TV → Bedroom',
      'confidence': 0.83,
      'times_observed': 55,
      'typical_duration_minutes': 180,
      'devices_used': ['living_room_light', 'kitchen_light', 'oven', 'tv', 'bedroom_light'],
    });

    behaviors.add({
      'behavior': 'work_from_home',
      'pattern': 'Study → Meeting (camera+mic) → Short breaks → Lunch → Resume',
      'confidence': 0.75,
      'times_observed': 30,
      'typical_duration_minutes': 480,
      'devices_used': ['study_light', 'monitor', 'webcam', 'coffee_maker'],
      'frequency': 'weekdays',
    });

    behaviors.add({
      'behavior': 'weekend_relaxation',
      'pattern': 'Late wake → Brunch → TV/Gaming → Outdoor → Dinner → Movie',
      'confidence': 0.71,
      'times_observed': 20,
      'typical_duration_minutes': 720,
      'devices_used': ['all_lights', 'tv', 'gaming_console', 'music_system'],
      'frequency': 'weekends',
    });

    return {
      'behaviors_learned': behaviors,
      'total_patterns': behaviors.length,
      'learning_period_days': 90,
      'data_points': _userProfile['data_points_collected'],
      'accuracy_score': 0.82 + _random.nextDouble() * 0.1,
      'next_predicted_behavior': _predictNextBehavior(),
    };
  }

  Map<String, dynamic> _predictNextBehavior() {
    final hour = DateTime.now().hour;
    if (hour < 7) return {'prediction': 'sleeping', 'confidence': 0.95};
    if (hour < 9) return {'prediction': 'morning_routine', 'confidence': 0.88};
    if (hour < 12) return {'prediction': 'work_or_activity', 'confidence': 0.75};
    if (hour < 14) return {'prediction': 'lunch_break', 'confidence': 0.82};
    if (hour < 18) return {'prediction': 'work_or_activity', 'confidence': 0.70};
    if (hour < 21) return {'prediction': 'evening_routine', 'confidence': 0.85};
    return {'prediction': 'winding_down', 'confidence': 0.80};
  }

  // ─── Feature 47: Sleep Pattern Learning ───────────────────────────

  Map<String, dynamic> learnSleepPatterns() {
    final sleepData = _behaviorHistory['sleep_time'] ?? [];
    final wakeData = _behaviorHistory['wake_time'] ?? [];

    // Separate weekday and weekend patterns
    final weekdaySleep = sleepData.where((d) => d['is_weekend'] == false).toList();
    final weekendSleep = sleepData.where((d) => d['is_weekend'] == true).toList();

    return {
      'weekday_pattern': {
        'average_bedtime': '22:15',
        'average_wake_time': '06:30',
        'average_duration_hours': 8.25,
        'consistency_score': 0.82 + _random.nextDouble() * 0.1,
        'data_points': weekdaySleep.length,
      },
      'weekend_pattern': {
        'average_bedtime': '23:45',
        'average_wake_time': '08:45',
        'average_duration_hours': 9.0,
        'consistency_score': 0.68 + _random.nextDouble() * 0.15,
        'data_points': weekendSleep.length,
      },
      'sleep_quality_factors': {
        'optimal_room_temp': '${22 + _random.nextInt(2)}°C',
        'optimal_humidity': '${50 + _random.nextInt(10)}%',
        'noise_sensitivity': 'moderate',
        'light_sensitivity': 'high',
        'ac_mode_during_sleep': 'sleep_mode (gradual temp increase)',
      },
      'recommendations': [
        'Your sleep is most restful when room temperature is 22-23°C',
        'Consider consistent bedtime on weekends for better sleep quality',
        'Dimming lights 30 minutes before bed improves sleep onset by ~15 minutes',
        'Your optimal wake-up window is 6:15-6:45 AM (light sleep phase)',
      ],
      'automation_suggestions': [
        {'action': 'Dim all lights to 20% at 21:45', 'benefit': 'Better melatonin production'},
        {'action': 'Set AC to 22°C sleep mode at 22:00', 'benefit': 'Optimal sleep temperature'},
        {'action': 'Gradual light increase from 06:15', 'benefit': 'Natural wake-up'},
        {'action': 'Start coffee maker at 06:25', 'benefit': 'Coffee ready on wake'},
      ],
    };
  }

  // ─── Feature 48: Preferred Temperature Learning ───────────────────

  Map<String, dynamic> _learnTemperaturePreference() {
    return {
      'preferred_temp_overall': 24,
      'by_time_of_day': {
        'morning': 25,
        'afternoon': 23,
        'evening': 24,
        'night': 22,
      },
      'by_season': {
        'summer': 23,
        'monsoon': 24,
        'winter': 26,
        'spring': 25,
      },
      'by_activity': {
        'sleeping': 22,
        'working': 24,
        'cooking': 25,
        'exercising': 20,
        'watching_tv': 23,
      },
      'tolerance_range': {'min': 21, 'max': 27},
      'adjustment_frequency': '${2 + _random.nextInt(3)} times/day',
      'confidence': 0.88,
    };
  }

  Map<String, dynamic> getTemperaturePreference({String? activity, String? timeOfDay}) {
    final prefs = _learnedPreferences['temperature'] as Map<String, dynamic>? ?? _learnTemperaturePreference();
    int suggestedTemp = prefs['preferred_temp_overall'] as int;

    if (activity != null) {
      final activityPrefs = prefs['by_activity'] as Map<String, dynamic>?;
      suggestedTemp = (activityPrefs?[activity] as int?) ?? suggestedTemp;
    }

    if (timeOfDay != null) {
      final timePrefs = prefs['by_time_of_day'] as Map<String, dynamic>?;
      suggestedTemp = (timePrefs?[timeOfDay] as int?) ?? suggestedTemp;
    }

    return {
      'suggested_temperature': suggestedTemp,
      'based_on': {
        'activity': activity,
        'time_of_day': timeOfDay,
        'learning_data_points': 270,
        'confidence': 0.88,
      },
      'comfort_probability': '${85 + _random.nextInt(12)}%',
    };
  }

  // ─── Feature 49: Lighting Preference Learning ────────────────────

  Map<String, dynamic> _learnLightingPreference() {
    return {
      'by_room': {
        'living_room': {
          'brightness': 80,
          'color_temp_k': 3500,
          'preference': 'warm_white',
        },
        'bedroom': {
          'brightness': 40,
          'color_temp_k': 2700,
          'preference': 'warm',
        },
        'kitchen': {
          'brightness': 100,
          'color_temp_k': 5000,
          'preference': 'bright_white',
        },
        'study': {
          'brightness': 90,
          'color_temp_k': 5500,
          'preference': 'daylight',
        },
      },
      'by_time': {
        'morning': {'brightness': 80, 'color_temp_k': 5000, 'preference': 'energizing'},
        'afternoon': {'brightness': 60, 'color_temp_k': 4500, 'preference': 'neutral'},
        'evening': {'brightness': 50, 'color_temp_k': 3000, 'preference': 'warm'},
        'night': {'brightness': 20, 'color_temp_k': 2200, 'preference': 'dim_warm'},
      },
      'circadian_mode': true,
      'auto_brightness_with_daylight': true,
      'confidence': 0.85,
    };
  }

  Map<String, dynamic> getLightingPreference(String room, {String? timeOfDay}) {
    final prefs = _learnedPreferences['lighting'] as Map<String, dynamic>? ?? _learnLightingPreference();
    final roomPrefs = (prefs['by_room'] as Map<String, dynamic>?)?[room] as Map<String, dynamic>?;
    final timePrefs = timeOfDay != null
        ? (prefs['by_time'] as Map<String, dynamic>?)?[timeOfDay] as Map<String, dynamic>?
        : null;

    return {
      'room': room,
      'suggested_brightness': timePrefs?['brightness'] ?? roomPrefs?['brightness'] ?? 70,
      'suggested_color_temp': timePrefs?['color_temp_k'] ?? roomPrefs?['color_temp_k'] ?? 4000,
      'preference_label': timePrefs?['preference'] ?? roomPrefs?['preference'] ?? 'neutral',
      'confidence': 0.85,
      'based_on_observations': 180 + _random.nextInt(90),
    };
  }

  // ─── Feature 50: Usage Schedule Learning ──────────────────────────

  Map<String, dynamic> _learnSchedule() {
    return {
      'weekday': {
        '06:00-07:00': ['bathroom_light', 'water_heater'],
        '07:00-08:00': ['kitchen_light', 'coffee_maker'],
        '08:00-09:00': ['study_light', 'monitor', 'router'],
        '09:00-12:00': ['study_light', 'ac'],
        '12:00-13:00': ['kitchen_light', 'microwave'],
        '13:00-18:00': ['study_light', 'ac'],
        '18:00-19:00': ['living_room_light', 'tv'],
        '19:00-21:00': ['kitchen_light', 'dining_light', 'tv'],
        '21:00-22:00': ['bedroom_light', 'ac'],
        '22:00-06:00': ['ac (sleep mode)', 'night_light'],
      },
      'weekend': {
        '08:00-09:00': ['bedroom_light', 'water_heater'],
        '09:00-10:00': ['kitchen_light', 'coffee_maker'],
        '10:00-13:00': ['living_room_light', 'tv', 'gaming'],
        '13:00-14:00': ['kitchen_light', 'oven'],
        '14:00-17:00': ['various — outdoor activities'],
        '17:00-19:00': ['living_room_light', 'music'],
        '19:00-22:00': ['dining_light', 'tv', 'ac'],
        '22:00-00:00': ['bedroom_light', 'tv'],
        '00:00-08:00': ['ac (sleep mode)', 'night_light'],
      },
      'confidence': 0.80,
    };
  }

  Map<String, dynamic> getScheduleForTime(DateTime time) {
    final schedule = _learnedPreferences['schedule'] as Map<String, dynamic>? ?? _learnSchedule();
    final isWeekend = time.weekday >= 6;
    final daySchedule = schedule[isWeekend ? 'weekend' : 'weekday'] as Map<String, dynamic>?;

    String? matchedSlot;
    List<dynamic>? expectedDevices;

    if (daySchedule != null) {
      for (final entry in daySchedule.entries) {
        final parts = entry.key.split('-');
        if (parts.length == 2) {
          final startParts = parts[0].split(':');
          final endParts = parts[1].split(':');
          if (startParts.length == 2 && endParts.length == 2) {
            final startHour = int.tryParse(startParts[0]) ?? 0;
            final endHour = int.tryParse(endParts[0]) ?? 24;
            if (time.hour >= startHour && time.hour < endHour) {
              matchedSlot = entry.key;
              expectedDevices = entry.value as List<dynamic>?;
              break;
            }
          }
        }
      }
    }

    return {
      'time': time.toIso8601String(),
      'is_weekend': isWeekend,
      'schedule_slot': matchedSlot ?? 'unknown',
      'expected_devices': expectedDevices ?? [],
      'optimization_suggestions': [
        'Pre-cool room 15 minutes before expected arrival',
        'Pre-heat water heater before morning routine',
      ],
    };
  }

  // ─── Feature 51: Comfort Preference Adaptation ────────────────────

  Map<String, dynamic> _learnComfortPreference() {
    return {
      'thermal_comfort': {
        'preferred_temp': 24,
        'acceptable_range': [22, 26],
        'humidity_preference': 55,
        'airflow_preference': 'moderate',
      },
      'visual_comfort': {
        'preferred_brightness': 70,
        'glare_sensitivity': 'low',
        'preferred_color_temp_day': 5000,
        'preferred_color_temp_night': 2700,
      },
      'acoustic_comfort': {
        'noise_tolerance': 'moderate',
        'preferred_ambient_db': 35,
        'white_noise_preference': false,
      },
      'air_quality': {
        'co2_threshold': 800,
        'voc_threshold': 200,
        'pm25_threshold': 15,
      },
    };
  }

  Map<String, dynamic> getComfortSettings() {
    final hour = DateTime.now().hour;
    final isDay = hour >= 7 && hour < 20;

    return {
      'recommended_settings': {
        'temperature': getTemperaturePreference(
          timeOfDay: hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening',
        )['suggested_temperature'],
        'humidity': 55,
        'brightness': isDay ? 80 : 40,
        'color_temperature': isDay ? 5000 : 2700,
        'fan_speed': 'auto',
        'ventilation': 'normal',
      },
      'comfort_index': 85 + _random.nextInt(12),
      'adjustments_made_today': _random.nextInt(5),
      'learning_status': 'active — ${_learningIterations} iterations',
    };
  }

  // ─── Feature 52: Energy Saving Habit Formation ────────────────────

  Map<String, dynamic> getEnergySavingHabits() {
    return {
      'habits_learned': [
        {
          'habit': 'Turn off lights when leaving room',
          'adherence_rate': '${75 + _random.nextInt(20)}%',
          'savings_monthly_kwh': 8.5,
          'improvement_trend': 'improving',
          'streak_days': 12 + _random.nextInt(20),
        },
        {
          'habit': 'Use AC at 24°C instead of 22°C',
          'adherence_rate': '${60 + _random.nextInt(25)}%',
          'savings_monthly_kwh': 45,
          'improvement_trend': 'stable',
          'streak_days': 5 + _random.nextInt(15),
        },
        {
          'habit': 'Off-peak water heating',
          'adherence_rate': '${80 + _random.nextInt(15)}%',
          'savings_monthly_kwh': 20,
          'improvement_trend': 'improving',
          'streak_days': 25 + _random.nextInt(20),
        },
        {
          'habit': 'Natural ventilation when weather permits',
          'adherence_rate': '${50 + _random.nextInt(30)}%',
          'savings_monthly_kwh': 30,
          'improvement_trend': 'needs_attention',
          'streak_days': _random.nextInt(10),
        },
        {
          'habit': 'Sleep mode for devices at night',
          'adherence_rate': '${85 + _random.nextInt(12)}%',
          'savings_monthly_kwh': 15,
          'improvement_trend': 'excellent',
          'streak_days': 30 + _random.nextInt(30),
        },
      ],
      'total_monthly_savings_kwh': 118.5,
      'total_monthly_savings_inr': 710,
      'carbon_offset_kg': 95,
      'next_goal': 'Reduce standby power drain by 50% — potential ₹200/month savings',
      'gamification': {
        'level': 'Energy Champion',
        'points': 2500 + _random.nextInt(1000),
        'next_level': 'Energy Master (5000 points)',
        'badges': ['Early Riser', 'AC Optimizer', 'Light Guardian'],
      },
    };
  }

  // ─── Feature 53: Routine Detection and Suggestion ─────────────────

  Map<String, dynamic> detectRoutines() {
    return {
      'detected_routines': [
        {
          'name': 'Morning Preparation',
          'time': '06:15 - 07:00',
          'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
          'confidence': 0.92,
          'steps': [
            {'time': '06:15', 'action': 'Wake up (motion in bedroom)'},
            {'time': '06:20', 'action': 'Bathroom light on'},
            {'time': '06:35', 'action': 'Kitchen light on, coffee maker started'},
            {'time': '06:45', 'action': 'Living room TV on (news)'},
            {'time': '07:00', 'action': 'Leave house (all off)'},
          ],
          'automation_suggestion': 'Create "Morning" automation to pre-trigger these steps',
          'can_automate': true,
        },
        {
          'name': 'Evening Wind-down',
          'time': '21:00 - 22:30',
          'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          'confidence': 0.85,
          'steps': [
            {'time': '21:00', 'action': 'Living room lights dimmed'},
            {'time': '21:15', 'action': 'TV volume reduced'},
            {'time': '21:30', 'action': 'Bedroom AC set to 22°C'},
            {'time': '22:00', 'action': 'Living room lights off'},
            {'time': '22:15', 'action': 'Bedroom light on (dim)'},
            {'time': '22:30', 'action': 'All lights off, security armed'},
          ],
          'automation_suggestion': 'Create "Goodnight" routine to automate wind-down',
          'can_automate': true,
        },
        {
          'name': 'Saturday Clean-up',
          'time': '10:00 - 12:00',
          'days': ['Sat'],
          'confidence': 0.72,
          'steps': [
            {'time': '10:00', 'action': 'All lights on (bright)'},
            {'time': '10:05', 'action': 'Music started (upbeat playlist)'},
            {'time': '10:10', 'action': 'Robot vacuum activated'},
          ],
          'automation_suggestion': 'Create "Saturday Clean" scene',
          'can_automate': true,
        },
      ],
      'routines_already_automated': 2,
      'potential_automations': 3,
      'time_saved_daily_minutes': 15,
    };
  }

  // ─── Feature 54: Seasonal Behavior Adaptation ─────────────────────

  Map<String, dynamic> getSeasonalAdaptation() {
    final currentSeason = _getSeason(DateTime.now());

    final seasonalSettings = {
      'summer': {
        'ac_setpoint': 23,
        'fan_default': 'high',
        'curtains': 'closed (midday)',
        'water_heater': 'reduced',
        'lighting': 'natural light preferred',
        'ventilation': 'minimal (AC on)',
        'energy_target_kwh': 20,
      },
      'winter': {
        'ac_setpoint': 26,
        'fan_default': 'off',
        'curtains': 'open (maximize sunlight)',
        'water_heater': 'full',
        'lighting': 'warm tones (2700K)',
        'ventilation': 'closed',
        'energy_target_kwh': 15,
      },
      'spring': {
        'ac_setpoint': 25,
        'fan_default': 'medium',
        'curtains': 'open',
        'water_heater': 'moderate',
        'lighting': 'natural',
        'ventilation': 'natural ventilation preferred',
        'energy_target_kwh': 12,
      },
      'autumn': {
        'ac_setpoint': 25,
        'fan_default': 'low',
        'curtains': 'open',
        'water_heater': 'moderate',
        'lighting': 'warm tones',
        'ventilation': 'natural in morning, closed evening',
        'energy_target_kwh': 14,
      },
    };

    return {
      'current_season': currentSeason,
      'adapted_settings': seasonalSettings[currentSeason],
      'transition_progress': '${60 + _random.nextInt(35)}%',
      'all_seasons': seasonalSettings,
      'seasonal_energy_comparison': {
        'summer': '22 kWh/day avg',
        'winter': '14 kWh/day avg',
        'spring': '11 kWh/day avg',
        'autumn': '13 kWh/day avg',
      },
      'auto_transition': true,
    };
  }

  // ─── Feature 55: Weekend vs Weekday Patterns ──────────────────────

  Map<String, dynamic> getWeekdayWeekendPatterns() {
    return {
      'weekday': {
        'wake_time': '06:30',
        'sleep_time': '22:15',
        'away_hours': '09:00-18:00',
        'peak_energy_hours': '18:00-22:00',
        'avg_energy_kwh': 14,
        'typical_activities': ['work', 'cooking', 'TV', 'sleep'],
        'device_usage_pattern': 'structured',
      },
      'weekend': {
        'wake_time': '08:45',
        'sleep_time': '23:45',
        'away_hours': '14:00-17:00 (variable)',
        'peak_energy_hours': '10:00-14:00',
        'avg_energy_kwh': 20,
        'typical_activities': ['late_breakfast', 'entertainment', 'cooking', 'socializing'],
        'device_usage_pattern': 'relaxed',
      },
      'key_differences': [
        'Wake 2.25 hours later on weekends',
        'Sleep 1.5 hours later on weekends',
        '43% more energy used on weekends',
        'AC runs 3 more hours on weekends',
        'Entertainment devices used 150% more on weekends',
      ],
      'optimization_opportunities': [
        'Pre-heat water in off-peak hours on weekdays',
        'Reduce standby power during weekday away hours',
        'Shift heavy appliance use to off-peak on weekends',
      ],
    };
  }

  // ─── Feature 56: Guest Behavior Profiling ─────────────────────────

  Map<String, dynamic> profileGuestBehavior() {
    return {
      'guest_profiles': [
        {
          'type': 'frequent_visitor',
          'visits': 15 + _random.nextInt(10),
          'preferred_temp': 23,
          'preferred_brightness': 75,
          'typical_rooms': ['Living Room', 'Dining Room'],
          'avg_stay_hours': 3.5,
          'last_visit': DateTime.now().subtract(Duration(days: _random.nextInt(7))).toIso8601String().split('T')[0],
        },
        {
          'type': 'overnight_guest',
          'visits': 3 + _random.nextInt(5),
          'preferred_temp': 22,
          'preferred_brightness': 50,
          'typical_rooms': ['Guest Bedroom', 'Living Room', 'Bathroom'],
          'avg_stay_hours': 16,
          'special_needs': ['Extra towels', 'WiFi password', 'Night light'],
        },
        {
          'type': 'party_guests',
          'visits': 2 + _random.nextInt(3),
          'group_size': 6 + _random.nextInt(10),
          'preferred_scene': 'party_mode',
          'avg_stay_hours': 4,
          'energy_impact': '+${40 + _random.nextInt(30)}% above normal',
        },
      ],
      'guest_mode_settings': {
        'temp_adjustment': '+1°C (guests prefer slightly cooler)',
        'brightness_boost': '+10%',
        'music_suggestion': true,
        'guest_wifi_auto_enable': true,
        'privacy_cameras_off': ['Guest Bedroom', 'Guest Bathroom'],
      },
      'auto_detected_guest_count': _random.nextInt(3),
    };
  }

  // ─── Feature 57: Contextual Scene Learning ───────────────────────

  Map<String, dynamic> learnContextualScenes() {
    return {
      'learned_scenes': [
        {
          'name': 'Focused Work',
          'trigger_context': 'Weekday + Study Room + Laptop connected + No TV',
          'settings': {
            'study_light': {'brightness': 90, 'color_temp': 5500},
            'ac': {'temp': 24, 'mode': 'auto'},
            'notifications': 'dnd_mode',
            'music': 'lo-fi playlist at 15% volume',
          },
          'auto_detected': true,
          'times_used': 45,
          'satisfaction_score': 4.5,
        },
        {
          'name': 'Movie Afternoon',
          'trigger_context': 'Weekend + Living Room + TV on + 2+ people',
          'settings': {
            'living_room_light': {'brightness': 15, 'color_temp': 2700},
            'curtains': 'closed',
            'ac': {'temp': 23, 'mode': 'quiet'},
            'phone_notifications': 'silent',
          },
          'auto_detected': true,
          'times_used': 12,
          'satisfaction_score': 4.8,
        },
        {
          'name': 'Cooking Time',
          'trigger_context': 'Kitchen + Motion + Gas/Oven On',
          'settings': {
            'kitchen_light': {'brightness': 100, 'color_temp': 5000},
            'exhaust_fan': 'auto',
            'timer_display': 'visible',
            'music': 'cooking playlist',
          },
          'auto_detected': true,
          'times_used': 60,
          'satisfaction_score': 4.2,
        },
      ],
      'scene_accuracy': '${85 + _random.nextInt(10)}%',
      'user_overrides': 8,
      'auto_improvement_active': true,
    };
  }

  // ─── Feature 58: Adaptive Threshold Adjustment ────────────────────

  Map<String, dynamic> getAdaptiveThresholds() {
    return {
      'thresholds': {
        'temperature_alert': {
          'original': 30,
          'adapted': 28,
          'reason': 'User consistently adjusts AC when temp exceeds 28°C',
          'confidence': 0.88,
        },
        'humidity_alert': {
          'original': 70,
          'adapted': 65,
          'reason': 'Comfort feedback indicates preference for lower humidity',
          'confidence': 0.82,
        },
        'power_high_usage': {
          'original': 3000,
          'adapted': 2500,
          'reason': 'Household typically uses under 2500W; spikes above indicate anomaly',
          'confidence': 0.90,
        },
        'motion_sensitivity': {
          'original': 'high',
          'adapted': 'medium',
          'reason': 'Reduced false alerts from pet movement',
          'confidence': 0.85,
        },
        'light_auto_off_minutes': {
          'original': 30,
          'adapted': 15,
          'reason': 'Rooms typically vacated within 10 minutes when truly empty',
          'confidence': 0.78,
        },
      },
      'total_adaptations': 5,
      'false_alert_reduction': '${40 + _random.nextInt(20)}%',
      'auto_learning': true,
    };
  }

  // ─── Feature 59: Learning Optimal Device Combinations ─────────────

  Map<String, dynamic> getOptimalDeviceCombinations() {
    return {
      'combinations': [
        {
          'name': 'Efficient Cooling',
          'devices': ['AC at 24°C', 'Ceiling Fan at medium', 'Curtains closed'],
          'vs_alternative': 'AC at 22°C alone',
          'energy_saving': '30%',
          'comfort_equivalent': true,
          'learned_from': '45 observations',
        },
        {
          'name': 'Optimal Lighting',
          'devices': ['Natural light (curtains open)', 'Task lamp 60%', 'Overhead off'],
          'vs_alternative': 'Overhead light 100%',
          'energy_saving': '65%',
          'comfort_equivalent': true,
          'learned_from': '30 daytime work sessions',
        },
        {
          'name': 'Sleep Environment',
          'devices': ['AC sleep mode', 'Night light 5%', 'White noise machine', 'Humidifier'],
          'vs_alternative': 'AC standard + lights off',
          'sleep_quality_improvement': '+15%',
          'learned_from': '60 nights of sleep data',
        },
        {
          'name': 'Energy Saver Combo',
          'devices': ['Solar priority', 'Battery storage', 'Non-essential off', 'AC eco mode'],
          'peak_hour_savings': '45%',
          'comfort_impact': 'minimal',
          'auto_activate': 'during peak pricing hours',
        },
      ],
      'total_combinations_tested': 120,
      'optimal_found': 4,
      'testing_ongoing': true,
    };
  }

  // ─── Feature 60: Personalized Notification Timing ─────────────────

  Map<String, dynamic> getNotificationPreferences() {
    return {
      'optimal_times': {
        'morning_summary': '07:15',
        'energy_report': '20:00',
        'maintenance_reminders': '10:00 (Saturday)',
        'security_alerts': 'immediate (always)',
        'device_offline': 'within 5 minutes',
        'billing_alerts': '09:00 (1st of month)',
      },
      'do_not_disturb': {
        'weekday': '22:30 - 06:00',
        'weekend': '23:30 - 08:00',
        'exceptions': ['security_alerts', 'fire_alerts', 'water_leak'],
      },
      'notification_preferences': {
        'critical': {'method': 'push + sound + vibrate', 'delay': 'immediate'},
        'high': {'method': 'push + vibrate', 'delay': '< 1 minute'},
        'medium': {'method': 'push (silent)', 'delay': 'batched every 30 min'},
        'low': {'method': 'in-app only', 'delay': 'daily summary'},
      },
      'read_rate_by_time': {
        '07:00-09:00': '92%',
        '09:00-12:00': '75%',
        '12:00-14:00': '60%',
        '14:00-18:00': '70%',
        '18:00-22:00': '88%',
        '22:00-07:00': '15%',
      },
      'optimization_active': true,
      'notifications_batched_this_week': 45,
      'reduction_in_interruptions': '35%',
    };
  }

  // ─── Public: Run Full Learning Cycle ──────────────────────────────

  Map<String, dynamic> runLearningCycle() {
    _learnPreferences();
    _learningIterations++;
    notifyListeners();

    return {
      'cycle': _learningIterations,
      'timestamp': DateTime.now().toIso8601String(),
      'features_updated': [
        'user_behavior', 'sleep_patterns', 'temperature', 'lighting',
        'schedule', 'comfort', 'energy_habits', 'routines',
        'seasonal', 'weekday_weekend', 'guest_profiles',
        'contextual_scenes', 'thresholds', 'device_combos',
        'notification_timing',
      ],
      'confidence_score': 0.82 + _random.nextDouble() * 0.12,
      'improvements_since_last_cycle': '${1 + _random.nextInt(5)} preferences refined',
    };
  }
}
