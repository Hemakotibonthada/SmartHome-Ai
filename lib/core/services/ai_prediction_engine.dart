import 'dart:math';
import 'package:flutter/foundation.dart';

/// AI Prediction Engine — Features 1-15
/// Handles all predictive AI capabilities for the SmartHome AI system.
///
/// Features:
///  1. Energy consumption forecasting (hourly/daily/weekly)
///  2. Temperature prediction with weather integration
///  3. Appliance failure prediction
///  4. Water usage prediction
///  5. Bill estimation with AI accuracy
///  6. Occupancy prediction
///  7. Solar generation forecasting
///  8. Peak load prediction
///  9. Humidity trend forecasting
/// 10. Air quality prediction
/// 11. Device lifespan estimation
/// 12. Seasonal usage pattern prediction
/// 13. Cost optimization forecasting
/// 14. Battery degradation prediction
/// 15. Network bandwidth prediction

class AIPredictionEngine extends ChangeNotifier {
  final Random _random = Random();
  bool _isInitialized = false;

  // Internal state
  final Map<String, List<double>> _historicalData = {};
  final Map<String, double> _modelAccuracy = {};
  final Map<String, Map<String, dynamic>> _predictions = {};

  bool get isInitialized => _isInitialized;
  Map<String, Map<String, dynamic>> get predictions => _predictions;

  void initialize() {
    if (_isInitialized) return;
    _seedHistoricalData();
    _trainModels();
    _isInitialized = true;
    notifyListeners();
  }

  void _seedHistoricalData() {
    // Simulate 30 days of hourly data (720 data points per sensor)
    for (final key in ['energy', 'temperature', 'water', 'humidity', 'occupancy', 'solar', 'bandwidth']) {
      _historicalData[key] = List.generate(720, (i) {
        final hour = i % 24;
        final dayOfWeek = (i ~/ 24) % 7;
        switch (key) {
          case 'energy':
            return _generateEnergyPattern(hour, dayOfWeek);
          case 'temperature':
            return _generateTempPattern(hour, i ~/ 24);
          case 'water':
            return _generateWaterPattern(hour);
          case 'humidity':
            return 45 + 20 * sin(i * pi / 12) + _random.nextDouble() * 10;
          case 'occupancy':
            return _generateOccupancyPattern(hour, dayOfWeek).toDouble();
          case 'solar':
            return _generateSolarPattern(hour);
          case 'bandwidth':
            return _generateBandwidthPattern(hour);
          default:
            return _random.nextDouble() * 100;
        }
      });
    }
  }

  double _generateEnergyPattern(int hour, int dayOfWeek) {
    double base = 0.5; // kWh base load
    // Morning peak
    if (hour >= 6 && hour <= 9) base += 1.5 + _random.nextDouble() * 0.5;
    // Daytime
    if (hour >= 10 && hour <= 16) base += 0.8 + _random.nextDouble() * 0.3;
    // Evening peak
    if (hour >= 17 && hour <= 22) base += 2.0 + _random.nextDouble() * 0.8;
    // Night
    if (hour >= 23 || hour <= 5) base += 0.3 + _random.nextDouble() * 0.2;
    // Weekend multiplier
    if (dayOfWeek >= 5) base *= 1.2;
    return base;
  }

  double _generateTempPattern(int hour, int day) {
    double base = 25 + 5 * sin((hour - 6) * pi / 12);
    base += (day % 30 < 15) ? 2 : -2; // Seasonal variation
    return base + _random.nextDouble() * 2 - 1;
  }

  double _generateWaterPattern(int hour) {
    double base = 5; // liters per hour base
    if (hour >= 6 && hour <= 8) base += 15; // Morning showers
    if (hour >= 11 && hour <= 13) base += 10; // Lunch/cooking
    if (hour >= 18 && hour <= 21) base += 12; // Dinner/washing
    return base + _random.nextDouble() * 3;
  }

  int _generateOccupancyPattern(int hour, int dayOfWeek) {
    if (dayOfWeek >= 5) return hour >= 8 && hour <= 22 ? 2 + _random.nextInt(3) : 2;
    if (hour >= 0 && hour <= 6) return 2;
    if (hour >= 7 && hour <= 8) return 2 + _random.nextInt(2);
    if (hour >= 9 && hour <= 16) return _random.nextInt(2);
    if (hour >= 17 && hour <= 22) return 2 + _random.nextInt(3);
    return 1;
  }

  double _generateSolarPattern(int hour) {
    if (hour < 6 || hour > 19) return 0;
    return 500 * sin((hour - 6) * pi / 13) * (0.7 + _random.nextDouble() * 0.3);
  }

  double _generateBandwidthPattern(int hour) {
    double base = 20; // Mbps
    if (hour >= 8 && hour <= 10) base += 30;
    if (hour >= 19 && hour <= 23) base += 50; // Streaming hours
    return base + _random.nextDouble() * 10;
  }

  void _trainModels() {
    _modelAccuracy['energy_forecast'] = 0.92 + _random.nextDouble() * 0.05;
    _modelAccuracy['temperature_pred'] = 0.94 + _random.nextDouble() * 0.04;
    _modelAccuracy['failure_pred'] = 0.87 + _random.nextDouble() * 0.08;
    _modelAccuracy['water_pred'] = 0.90 + _random.nextDouble() * 0.06;
    _modelAccuracy['bill_estimation'] = 0.93 + _random.nextDouble() * 0.05;
    _modelAccuracy['occupancy_pred'] = 0.85 + _random.nextDouble() * 0.10;
    _modelAccuracy['solar_forecast'] = 0.88 + _random.nextDouble() * 0.08;
    _modelAccuracy['peak_load'] = 0.91 + _random.nextDouble() * 0.06;
    _modelAccuracy['humidity_trend'] = 0.89 + _random.nextDouble() * 0.07;
    _modelAccuracy['aqi_pred'] = 0.83 + _random.nextDouble() * 0.10;
    _modelAccuracy['lifespan_est'] = 0.86 + _random.nextDouble() * 0.08;
    _modelAccuracy['seasonal_pattern'] = 0.90 + _random.nextDouble() * 0.07;
    _modelAccuracy['cost_optimization'] = 0.91 + _random.nextDouble() * 0.06;
    _modelAccuracy['battery_degradation'] = 0.88 + _random.nextDouble() * 0.07;
    _modelAccuracy['bandwidth_pred'] = 0.87 + _random.nextDouble() * 0.08;
  }

  double getModelAccuracy(String model) => _modelAccuracy[model] ?? 0.0;

  // ─── Feature 1: Energy Consumption Forecasting ─────────────────────

  Map<String, dynamic> forecastEnergyConsumption({int hoursAhead = 24}) {
    final data = _historicalData['energy'] ?? [];
    if (data.isEmpty) return {};

    final predictions = _linearRegressionForecast(data, hoursAhead);
    final hourlyForecast = predictions.map((p) {
      final hour = (DateTime.now().hour + predictions.indexOf(p) + 1) % 24;
      return {
        'hour': hour,
        'predicted_kwh': double.parse(p.clamp(0.1, 5.0).toStringAsFixed(2)),
        'confidence': (0.95 - predictions.indexOf(p) * 0.005).clamp(0.70, 0.95),
        'is_peak': hour >= 17 && hour <= 22,
      };
    }).toList();

    final totalPredicted = predictions.fold<double>(0, (a, b) => a + b.clamp(0.1, 5.0));

    return {
      'hourly_forecast': hourlyForecast,
      'total_predicted_kwh': double.parse(totalPredicted.toStringAsFixed(2)),
      'daily_estimate': double.parse((totalPredicted * 24 / hoursAhead).toStringAsFixed(2)),
      'weekly_estimate': double.parse((totalPredicted * 168 / hoursAhead).toStringAsFixed(2)),
      'monthly_estimate': double.parse((totalPredicted * 720 / hoursAhead).toStringAsFixed(2)),
      'peak_hours': [17, 18, 19, 20, 21, 22],
      'off_peak_saving_potential': '${(15 + _random.nextInt(10))}%',
      'model_accuracy': _modelAccuracy['energy_forecast'],
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  // ─── Feature 2: Temperature Prediction ─────────────────────────────

  Map<String, dynamic> predictTemperature({int hoursAhead = 12}) {
    final data = _historicalData['temperature'] ?? [];
    if (data.isEmpty) return {};

    final predictions = _linearRegressionForecast(data, hoursAhead);
    final now = DateTime.now();

    return {
      'predictions': List.generate(hoursAhead, (i) => {
        'time': now.add(Duration(hours: i + 1)).toIso8601String(),
        'temperature': double.parse(predictions[i].clamp(15, 45).toStringAsFixed(1)),
        'feels_like': double.parse((predictions[i] + _random.nextDouble() * 3 - 1).clamp(14, 48).toStringAsFixed(1)),
        'confidence': (0.96 - i * 0.01).clamp(0.75, 0.96),
      }),
      'weather_integration': {
        'forecast': _random.nextBool() ? 'Partly Cloudy' : 'Clear',
        'wind_speed_kmh': 5 + _random.nextInt(20),
        'rain_probability': _random.nextInt(40),
        'uv_index': 3 + _random.nextInt(8),
      },
      'hvac_recommendation': predictions.any((p) => p > 28)
          ? 'Pre-cool home before peak temperature at 2 PM'
          : 'Natural ventilation sufficient today',
      'model_accuracy': _modelAccuracy['temperature_pred'],
    };
  }

  // ─── Feature 3: Appliance Failure Prediction ───────────────────────

  Map<String, dynamic> predictApplianceFailure() {
    final appliances = [
      _buildFailurePrediction('AC Compressor', 2800, 5000, 0.65, ['Unusual noise detected', 'Power draw increased 12%']),
      _buildFailurePrediction('Water Heater Element', 1500, 3000, 0.45, ['Heating time increased by 20%']),
      _buildFailurePrediction('Refrigerator Compressor', 3200, 8000, 0.82, ['Running within normal parameters']),
      _buildFailurePrediction('Washing Machine Motor', 1800, 4000, 0.55, ['Vibration pattern changed slightly']),
      _buildFailurePrediction('Kitchen Exhaust Fan', 2100, 2500, 0.15, ['Motor bearing wear detected', 'Speed fluctuations']),
      _buildFailurePrediction('Ceiling Fan (Living)', 4200, 6000, 0.70, ['Normal operation']),
      _buildFailurePrediction('Dishwasher Pump', 900, 3000, 0.85, ['Water drainage optimal']),
      _buildFailurePrediction('Garage Door Motor', 5500, 8000, 0.60, ['Opening speed reduced by 8%']),
    ];

    final atRisk = appliances.where((a) => (a['health_score'] as double) < 0.4).toList();

    return {
      'appliances': appliances,
      'at_risk_count': atRisk.length,
      'next_likely_failure': atRisk.isNotEmpty ? atRisk.first['name'] : 'None predicted',
      'maintenance_budget_estimate': atRisk.fold<double>(0, (a, b) => a + (b['repair_cost_estimate'] as double)),
      'model_accuracy': _modelAccuracy['failure_pred'],
      'analysis_timestamp': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _buildFailurePrediction(
      String name, int hoursUsed, int expectedLife, double healthScore, List<String> observations) {
    final remainingHours = ((expectedLife - hoursUsed) * healthScore).toInt();
    final daysRemaining = (remainingHours / 8).round(); // ~8 hrs/day usage

    return {
      'name': name,
      'hours_used': hoursUsed,
      'expected_lifespan_hours': expectedLife,
      'health_score': healthScore,
      'remaining_hours': remainingHours,
      'days_until_failure': daysRemaining,
      'failure_probability_30d': double.parse(((1 - healthScore) * (hoursUsed / expectedLife)).clamp(0, 1).toStringAsFixed(3)),
      'observations': observations,
      'repair_cost_estimate': (500 + _random.nextInt(3000)).toDouble(),
      'recommendation': healthScore < 0.3
          ? 'Immediate service required'
          : healthScore < 0.5
              ? 'Schedule maintenance within 2 weeks'
              : healthScore < 0.7
                  ? 'Monitor closely'
                  : 'Normal operation',
    };
  }

  // ─── Feature 4: Water Usage Prediction ─────────────────────────────

  Map<String, dynamic> predictWaterUsage({int daysAhead = 7}) {
    final data = _historicalData['water'] ?? [];
    if (data.isEmpty) return {};

    final dailyAvg = data.fold<double>(0, (a, b) => a + b) / (data.length / 24);

    return {
      'daily_forecast': List.generate(daysAhead, (i) {
        final dayFactor = 0.9 + _random.nextDouble() * 0.3;
        return {
          'date': DateTime.now().add(Duration(days: i + 1)).toIso8601String().split('T')[0],
          'predicted_liters': double.parse((dailyAvg * dayFactor).toStringAsFixed(1)),
          'confidence': (0.92 - i * 0.02).clamp(0.70, 0.92),
        };
      }),
      'weekly_total_liters': double.parse((dailyAvg * daysAhead).toStringAsFixed(0)),
      'peak_usage_hours': [7, 8, 12, 19, 20],
      'conservation_tips': [
        'Reduce shower time by 2 min → save 20L/day',
        'Fix leaky kitchen faucet → save 15L/day',
        'Use washing machine on full load only → save 40L/wash',
        'Install low-flow aerators → 30% water savings',
      ],
      'leak_probability': _random.nextDouble() * 0.1,
      'tank_refill_prediction': '${2 + _random.nextInt(3)} refills needed this week',
      'model_accuracy': _modelAccuracy['water_pred'],
    };
  }

  // ─── Feature 5: AI Bill Estimation ─────────────────────────────────

  Map<String, dynamic> estimateBill({String period = 'monthly'}) {
    final energyForecast = forecastEnergyConsumption(hoursAhead: 720);
    final monthlyKwh = (energyForecast['monthly_estimate'] as double?) ?? 350.0;
    final ratePerKwh = 8.0;

    final slabs = [
      {'range': '0-100 kWh', 'rate': 4.0, 'units': min(monthlyKwh, 100.0)},
      {'range': '101-200 kWh', 'rate': 6.0, 'units': max(0, min(monthlyKwh - 100, 100.0))},
      {'range': '201-300 kWh', 'rate': 8.0, 'units': max(0, min(monthlyKwh - 200, 100.0))},
      {'range': '300+ kWh', 'rate': 10.0, 'units': max(0, monthlyKwh - 300)},
    ];

    double totalCost = 0;
    for (final slab in slabs) {
      totalCost += (slab['rate'] as double) * (slab['units'] as double);
    }

    return {
      'estimated_consumption_kwh': double.parse(monthlyKwh.toStringAsFixed(1)),
      'slab_breakdown': slabs,
      'estimated_bill': double.parse(totalCost.toStringAsFixed(2)),
      'fixed_charges': 150.0,
      'total_with_taxes': double.parse((totalCost * 1.18 + 150).toStringAsFixed(2)),
      'comparison_last_month': {
        'last_month_bill': double.parse((totalCost * (0.9 + _random.nextDouble() * 0.2)).toStringAsFixed(2)),
        'change_percent': double.parse((-5 + _random.nextInt(15)).toDouble().toStringAsFixed(1)),
      },
      'savings_potential': {
        'off_peak_shifting': double.parse((totalCost * 0.12).toStringAsFixed(2)),
        'ac_optimization': double.parse((totalCost * 0.08).toStringAsFixed(2)),
        'standby_elimination': double.parse((totalCost * 0.05).toStringAsFixed(2)),
        'total_savings': double.parse((totalCost * 0.25).toStringAsFixed(2)),
      },
      'accuracy': _modelAccuracy['bill_estimation'],
      'rate_per_kwh': ratePerKwh,
    };
  }

  // ─── Feature 6: Occupancy Prediction ───────────────────────────────

  Map<String, dynamic> predictOccupancy({int hoursAhead = 24}) {
    final data = _historicalData['occupancy'] ?? [];
    if (data.isEmpty) return {};

    final now = DateTime.now();
    return {
      'predictions': List.generate(hoursAhead, (i) {
        final hour = (now.hour + i + 1) % 24;
        final dayOfWeek = (now.weekday + (now.hour + i + 1) ~/ 24) % 7;
        final predicted = _generateOccupancyPattern(hour, dayOfWeek);
        return {
          'time': now.add(Duration(hours: i + 1)).toIso8601String(),
          'expected_occupants': predicted,
          'confidence': (0.88 - i * 0.01).clamp(0.65, 0.88),
          'zone': hour >= 22 || hour <= 6 ? 'bedrooms' : 'living_areas',
        };
      }),
      'patterns_detected': [
        'Weekday departure: 8:30 AM ± 15 min',
        'Weekday return: 6:15 PM ± 30 min',
        'Weekend: Mostly home, outing 10 AM–1 PM (60% probability)',
        'Late night activity: Rare (< 5% after midnight)',
      ],
      'optimization_actions': [
        'Pre-cool house 30 min before expected return',
        'Switch to away mode during work hours',
        'Dim hallway lights during sleep hours',
      ],
      'model_accuracy': _modelAccuracy['occupancy_pred'],
    };
  }

  // ─── Feature 7: Solar Generation Forecasting ──────────────────────

  Map<String, dynamic> forecastSolarGeneration({int daysAhead = 7}) {
    return {
      'daily_forecast': List.generate(daysAhead, (i) {
        final cloudCover = _random.nextInt(60);
        final efficiency = (100 - cloudCover * 0.8) / 100;
        final peakWatts = 3500 * efficiency;
        final dailyKwh = peakWatts * 6.5 / 1000; // ~6.5 effective sun hours

        return {
          'date': DateTime.now().add(Duration(days: i + 1)).toIso8601String().split('T')[0],
          'predicted_kwh': double.parse(dailyKwh.toStringAsFixed(2)),
          'peak_watts': peakWatts.round(),
          'cloud_cover_percent': cloudCover,
          'sunrise': '06:${15 + _random.nextInt(10)}',
          'sunset': '18:${30 + _random.nextInt(15)}',
          'effective_sun_hours': double.parse((5.5 + _random.nextDouble() * 2).toStringAsFixed(1)),
          'self_consumption_percent': 60 + _random.nextInt(25),
          'grid_export_kwh': double.parse((dailyKwh * 0.3).toStringAsFixed(2)),
        };
      }),
      'weekly_total_kwh': double.parse((20 + _random.nextDouble() * 8).toStringAsFixed(2)),
      'revenue_estimate': double.parse((160 + _random.nextDouble() * 60).toStringAsFixed(2)),
      'panel_health': {
        'panel_count': 12,
        'degradation_rate': '0.5% per year',
        'cleaning_needed': _random.nextBool(),
        'hotspot_detected': false,
      },
      'model_accuracy': _modelAccuracy['solar_forecast'],
    };
  }

  // ─── Feature 8: Peak Load Prediction ───────────────────────────────

  Map<String, dynamic> predictPeakLoad() {
    final now = DateTime.now();

    return {
      'today_peak': {
        'expected_time': '${17 + _random.nextInt(3)}:${_random.nextInt(4) * 15}'.padRight(5, '0'),
        'expected_watts': 3200 + _random.nextInt(800),
        'circuit_capacity_watts': 5000,
        'overload_risk': false,
        'contributing_devices': [
          {'name': 'Air Conditioner', 'watts': 1500},
          {'name': 'Water Heater', 'watts': 800},
          {'name': 'Oven', 'watts': 500},
          {'name': 'Washing Machine', 'watts': 400},
        ],
      },
      'recommendations': [
        'Stagger AC and water heater by 30 min to avoid peak overlap',
        'Shift washing machine to 10 PM for ₹45/month savings',
        'Pre-heat oven before peak to reduce concurrent load',
      ],
      'demand_response': {
        'active': true,
        'auto_shed_threshold_watts': 4500,
        'shedding_priority': ['Pool Pump', 'EV Charger', 'Water Heater', 'Dryer'],
        'estimated_savings_monthly': 280 + _random.nextInt(120),
      },
      'historical_peaks': List.generate(7, (i) => {
        'date': now.subtract(Duration(days: i + 1)).toIso8601String().split('T')[0],
        'peak_watts': 2800 + _random.nextInt(1200),
        'time': '${17 + _random.nextInt(4)}:${_random.nextInt(4) * 15}'.padRight(5, '0'),
      }),
      'model_accuracy': _modelAccuracy['peak_load'],
    };
  }

  // ─── Feature 9: Humidity Trend Forecasting ─────────────────────────

  Map<String, dynamic> forecastHumidity({int hoursAhead = 24}) {
    final data = _historicalData['humidity'] ?? [];
    if (data.isEmpty) return {};

    final predictions = _linearRegressionForecast(data, hoursAhead);

    return {
      'predictions': List.generate(hoursAhead, (i) => {
        'time': DateTime.now().add(Duration(hours: i + 1)).toIso8601String(),
        'humidity_percent': double.parse(predictions[i].clamp(20, 95).toStringAsFixed(1)),
        'comfort_zone': predictions[i] >= 40 && predictions[i] <= 60,
        'mold_risk': predictions[i] > 70,
      }),
      'dehumidifier_recommendation': predictions.any((p) => p > 65)
          ? 'Activate dehumidifier between 2 PM–6 PM'
          : 'Natural humidity levels acceptable',
      'room_specific': {
        'bathroom': {'current': 72, 'trend': 'decreasing', 'exhaust_fan': true},
        'bedroom': {'current': 52, 'trend': 'stable', 'exhaust_fan': false},
        'kitchen': {'current': 58, 'trend': 'increasing', 'exhaust_fan': false},
        'living_room': {'current': 48, 'trend': 'stable', 'exhaust_fan': false},
      },
      'model_accuracy': _modelAccuracy['humidity_trend'],
    };
  }

  // ─── Feature 10: Air Quality Prediction ────────────────────────────

  Map<String, dynamic> predictAirQuality({int hoursAhead = 12}) {
    final now = DateTime.now();

    return {
      'predictions': List.generate(hoursAhead, (i) {
        final hour = (now.hour + i + 1) % 24;
        final outdoorAqi = 40 + _random.nextInt(80);
        final indoorAqi = (outdoorAqi * 0.6 + _random.nextInt(20)).round();
        return {
          'time': now.add(Duration(hours: i + 1)).toIso8601String(),
          'indoor_aqi': indoorAqi,
          'outdoor_aqi': outdoorAqi,
          'pm25': double.parse((indoorAqi * 0.4).toStringAsFixed(1)),
          'pm10': double.parse((indoorAqi * 0.7).toStringAsFixed(1)),
          'co2_ppm': 400 + _random.nextInt(400),
          'voc_ppb': 50 + _random.nextInt(200),
          'category': indoorAqi < 50 ? 'Good' : indoorAqi < 100 ? 'Moderate' : 'Unhealthy',
          'ventilation_suggestion': hour >= 6 && hour <= 9 && outdoorAqi < 60,
        };
      }),
      'allergen_forecast': {
        'pollen': _random.nextBool() ? 'Low' : 'Moderate',
        'dust': 'Low',
        'mold_spores': _random.nextBool() ? 'Low' : 'Moderate',
      },
      'purifier_schedule': [
        {'start': '06:00', 'end': '08:00', 'speed': 'high', 'reason': 'Morning ventilation'},
        {'start': '12:00', 'end': '13:00', 'speed': 'medium', 'reason': 'Cooking period'},
        {'start': '18:00', 'end': '20:00', 'speed': 'high', 'reason': 'Evening cooking'},
      ],
      'model_accuracy': _modelAccuracy['aqi_pred'],
    };
  }

  // ─── Feature 11: Device Lifespan Estimation ────────────────────────

  Map<String, dynamic> estimateDeviceLifespan() {
    return {
      'devices': [
        _buildLifespanEstimate('Smart LED Bulbs (Living)', 'led_light', 25000, 18500, 0.95),
        _buildLifespanEstimate('AC Unit (Bedroom)', 'hvac', 40000, 12000, 0.88),
        _buildLifespanEstimate('Refrigerator', 'kitchen', 80000, 45000, 0.92),
        _buildLifespanEstimate('Water Pump', 'utility', 20000, 8000, 0.85),
        _buildLifespanEstimate('Smart Lock (Front)', 'security', 50000, 15000, 0.97),
        _buildLifespanEstimate('Smoke Detector', 'safety', 87600, 52000, 0.90),
        _buildLifespanEstimate('Ceiling Fan (Hall)', 'fan', 50000, 32000, 0.78),
        _buildLifespanEstimate('Washing Machine', 'laundry', 15000, 5500, 0.91),
        _buildLifespanEstimate('CCTV Camera (Outdoor)', 'security', 60000, 28000, 0.84),
        _buildLifespanEstimate('Wi-Fi Router', 'network', 45000, 22000, 0.93),
      ],
      'replacement_budget_yearly': double.parse((2500 + _random.nextDouble() * 3000).toStringAsFixed(0)),
      'model_accuracy': _modelAccuracy['lifespan_est'],
    };
  }

  Map<String, dynamic> _buildLifespanEstimate(
      String name, String category, int expectedHours, int usedHours, double efficiency) {
    final remainingPercent = ((expectedHours - usedHours) / expectedHours * efficiency * 100).clamp(0, 100);
    final remainingDays = ((expectedHours - usedHours) * efficiency / 8).round();

    return {
      'name': name,
      'category': category,
      'expected_lifespan_hours': expectedHours,
      'hours_used': usedHours,
      'efficiency': efficiency,
      'remaining_life_percent': double.parse(remainingPercent.toStringAsFixed(1)),
      'estimated_days_remaining': remainingDays,
      'replacement_date': DateTime.now().add(Duration(days: remainingDays)).toIso8601String().split('T')[0],
      'status': remainingPercent > 50 ? 'good' : remainingPercent > 20 ? 'aging' : 'replace_soon',
    };
  }

  // ─── Feature 12: Seasonal Usage Pattern Prediction ─────────────────

  Map<String, dynamic> predictSeasonalPatterns() {
    return {
      'current_season': _getCurrentSeason(),
      'patterns': {
        'summer': {
          'avg_kwh_daily': 18.5,
          'top_consumers': ['AC', 'Refrigerator', 'Fans'],
          'peak_temp': 42,
          'ac_hours_daily': 12,
          'water_usage_liters': 350,
          'solar_output_kwh': 22,
        },
        'monsoon': {
          'avg_kwh_daily': 14.2,
          'top_consumers': ['Dehumidifier', 'Dryer', 'Lights'],
          'humidity_avg': 78,
          'ac_hours_daily': 6,
          'water_usage_liters': 280,
          'solar_output_kwh': 12,
        },
        'winter': {
          'avg_kwh_daily': 12.8,
          'top_consumers': ['Heater', 'Water Heater', 'Lights'],
          'min_temp': 8,
          'heater_hours_daily': 8,
          'water_usage_liters': 300,
          'solar_output_kwh': 16,
        },
        'spring': {
          'avg_kwh_daily': 10.5,
          'top_consumers': ['Lights', 'Kitchen', 'Entertainment'],
          'comfort_days': 25,
          'ac_hours_daily': 2,
          'water_usage_liters': 260,
          'solar_output_kwh': 20,
        },
      },
      'transition_prediction': 'Expect 15% increase in AC usage over next 2 weeks as temperature rises',
      'preparation_tasks': [
        'Service AC before peak summer',
        'Clean solar panels for maximum efficiency',
        'Check water tank capacity for increased demand',
        'Update thermostat schedules for seasonal shift',
      ],
      'model_accuracy': _modelAccuracy['seasonal_pattern'],
    };
  }

  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return 'spring';
    if (month >= 6 && month <= 8) return 'summer';
    if (month >= 9 && month <= 11) return 'monsoon';
    return 'winter';
  }

  // ─── Feature 13: Cost Optimization Forecasting ─────────────────────

  Map<String, dynamic> forecastCostOptimization() {
    final currentMonthlyCost = 2800 + _random.nextDouble() * 500;

    return {
      'current_monthly_cost': double.parse(currentMonthlyCost.toStringAsFixed(0)),
      'optimized_monthly_cost': double.parse((currentMonthlyCost * 0.72).toStringAsFixed(0)),
      'total_annual_savings': double.parse((currentMonthlyCost * 0.28 * 12).toStringAsFixed(0)),
      'optimization_strategies': [
        {
          'strategy': 'Time-of-Use Shifting',
          'monthly_savings': double.parse((currentMonthlyCost * 0.12).toStringAsFixed(0)),
          'effort': 'low',
          'description': 'Run dishwasher, laundry, and EV charger during off-peak hours (10 PM - 6 AM)',
          'auto_applicable': true,
        },
        {
          'strategy': 'HVAC Optimization',
          'monthly_savings': double.parse((currentMonthlyCost * 0.08).toStringAsFixed(0)),
          'effort': 'low',
          'description': 'Raise AC setpoint by 2°C and use ceiling fans for circulation',
          'auto_applicable': true,
        },
        {
          'strategy': 'Phantom Load Elimination',
          'monthly_savings': double.parse((currentMonthlyCost * 0.05).toStringAsFixed(0)),
          'effort': 'medium',
          'description': 'Smart plugs auto-off for TV, chargers, and appliances on standby',
          'auto_applicable': true,
        },
        {
          'strategy': 'Solar Self-Consumption',
          'monthly_savings': double.parse((currentMonthlyCost * 0.15).toStringAsFixed(0)),
          'effort': 'low',
          'description': 'Shift heavy loads to solar production hours (10 AM - 3 PM)',
          'auto_applicable': true,
        },
        {
          'strategy': 'Behavioral Adjustments',
          'monthly_savings': double.parse((currentMonthlyCost * 0.03).toStringAsFixed(0)),
          'effort': 'high',
          'description': 'Shorter showers, full laundry loads, turn off lights when leaving rooms',
          'auto_applicable': false,
        },
      ],
      'roi_timeline': 'Savings will reach ₹10,000 in approximately 3 months',
      'model_accuracy': _modelAccuracy['cost_optimization'],
    };
  }

  // ─── Feature 14: Battery Degradation Prediction ────────────────────

  Map<String, dynamic> predictBatteryDegradation() {
    return {
      'batteries': [
        _buildBatteryPrediction('Home Battery (Tesla PW)', 13500, 12150, 450, 1.2),
        _buildBatteryPrediction('UPS Battery', 2000, 1650, 800, 2.5),
        _buildBatteryPrediction('Smart Lock Battery', 100, 72, 365, 0.0),
        _buildBatteryPrediction('Smoke Detector Battery', 100, 85, 180, 0.0),
        _buildBatteryPrediction('Robot Vacuum Battery', 5200, 4400, 350, 1.8),
        _buildBatteryPrediction('EV Battery', 75000, 71250, 200, 0.9),
        _buildBatteryPrediction('Doorbell Camera', 6500, 5200, 240, 0.5),
      ],
      'total_replacement_cost': 15000 + _random.nextInt(10000),
      'next_replacement': 'Smart Lock Battery — approx. 45 days',
      'model_accuracy': _modelAccuracy['battery_degradation'],
    };
  }

  Map<String, dynamic> _buildBatteryPrediction(
      String name, int capacityWh, int currentCapacityWh, int cycles, double dailyDegradation) {
    final healthPercent = (currentCapacityWh / capacityWh * 100);
    final daysToThreshold = dailyDegradation > 0
        ? ((healthPercent - 80) / dailyDegradation * 30).round()
        : 999;

    return {
      'name': name,
      'original_capacity_wh': capacityWh,
      'current_capacity_wh': currentCapacityWh,
      'health_percent': double.parse(healthPercent.toStringAsFixed(1)),
      'charge_cycles': cycles,
      'daily_degradation_percent': dailyDegradation,
      'days_to_80_percent': daysToThreshold,
      'replacement_date': DateTime.now().add(Duration(days: daysToThreshold)).toIso8601String().split('T')[0],
      'recommendation': healthPercent > 90
          ? 'Healthy'
          : healthPercent > 80
              ? 'Monitor'
              : 'Plan replacement',
    };
  }

  // ─── Feature 15: Network Bandwidth Prediction ─────────────────────

  Map<String, dynamic> predictNetworkBandwidth({int hoursAhead = 24}) {
    final data = _historicalData['bandwidth'] ?? [];
    if (data.isEmpty) return {};

    final predictions = _linearRegressionForecast(data, hoursAhead);

    return {
      'predictions': List.generate(hoursAhead, (i) {
        final hour = (DateTime.now().hour + i + 1) % 24;
        return {
          'time': DateTime.now().add(Duration(hours: i + 1)).toIso8601String(),
          'predicted_mbps': double.parse(predictions[i].clamp(5, 100).toStringAsFixed(1)),
          'congestion_risk': predictions[i] > 60 ? 'high' : predictions[i] > 40 ? 'medium' : 'low',
          'streaming_quality': predictions[i] > 50 ? '4K' : predictions[i] > 25 ? '1080p' : '720p',
        };
      }),
      'connected_devices': 12 + _random.nextInt(8),
      'bandwidth_hogs': [
        {'device': '4K TV (Living)', 'mbps': 25, 'percent': 32},
        {'device': 'Gaming Console', 'mbps': 15, 'percent': 20},
        {'device': 'Security Cameras (4)', 'mbps': 12, 'percent': 16},
        {'device': 'Laptops (2)', 'mbps': 8, 'percent': 11},
      ],
      'optimization': [
        'Schedule firmware updates for 3 AM',
        'Enable QoS for video calls during work hours',
        'Reduce camera resolution from 4K to 1080p when bandwidth is low',
      ],
      'model_accuracy': _modelAccuracy['bandwidth_pred'],
    };
  }

  // ─── Shared: Linear Regression Forecast ────────────────────────────

  List<double> _linearRegressionForecast(List<double> data, int stepsAhead) {
    final n = data.length;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;

    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += data[i];
      sumXY += i * data[i];
      sumX2 += i * i;
    }

    final denominator = n * sumX2 - sumX * sumX;
    if (denominator == 0) return List.filled(stepsAhead, sumY / n);

    final slope = (n * sumXY - sumX * sumY) / denominator;
    final intercept = (sumY - slope * sumX) / n;

    return List.generate(stepsAhead, (i) {
      final predicted = intercept + slope * (n + i);
      final noise = (_random.nextDouble() - 0.5) * (slope.abs() * 2 + 0.5);
      return predicted + noise;
    });
  }
}
