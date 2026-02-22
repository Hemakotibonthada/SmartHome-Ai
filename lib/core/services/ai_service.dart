import 'dart:math';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/models/user_model.dart';

class AIService {
  final Random _random = Random();

  /// Analyze sensor data and generate AI insights
  List<AIInsight> analyzeData(Map<String, SensorData> sensorData) {
    final insights = <AIInsight>[];

    // Temperature Analysis
    final temp = sensorData['temperature'];
    if (temp != null) {
      if (temp.value > 30) {
        insights.add(AIInsight(
          id: 'insight_temp_high',
          title: 'High Temperature Detected',
          description:
              'Room temperature is ${temp.value.toStringAsFixed(1)}°C, which is above the comfort zone. '
              'Consider turning on the AC or fan to maintain optimal temperature between 22-26°C.',
          type: InsightType.comfort,
          priority: temp.value > 35 ? InsightPriority.high : InsightPriority.medium,
          actionSuggestion: 'Turn on AC and set to 24°C',
        ));
      } else if (temp.value < 18) {
        insights.add(AIInsight(
          id: 'insight_temp_low',
          title: 'Low Temperature Alert',
          description:
              'Room temperature has dropped to ${temp.value.toStringAsFixed(1)}°C. '
              'This might affect comfort and health. Consider using a heater.',
          type: InsightType.comfort,
          priority: InsightPriority.medium,
          actionSuggestion: 'Turn on heater or raise thermostat',
        ));
      }
    }

    // Humidity Analysis
    final hum = sensorData['humidity'];
    if (hum != null) {
      if (hum.value > 70) {
        insights.add(AIInsight(
          id: 'insight_hum_high',
          title: 'High Humidity Warning',
          description:
              'Humidity level is ${hum.value.toStringAsFixed(1)}%, which can cause mold growth and discomfort. '
              'Use a dehumidifier or improve ventilation.',
          type: InsightType.comfort,
          priority: InsightPriority.medium,
          actionSuggestion: 'Enable ventilation fan',
        ));
      } else if (hum.value < 30) {
        insights.add(AIInsight(
          id: 'insight_hum_low',
          title: 'Low Humidity Alert',
          description:
              'Humidity is only ${hum.value.toStringAsFixed(1)}%. Low humidity can cause dry skin, '
              'respiratory issues, and static electricity.',
          type: InsightType.comfort,
          priority: InsightPriority.low,
          actionSuggestion: 'Consider using a humidifier',
        ));
      }
    }

    // Voltage Analysis
    final volt = sensorData['voltage'];
    if (volt != null) {
      if (volt.value > 250) {
        insights.add(AIInsight(
          id: 'insight_volt_high',
          title: 'High Voltage Detected!',
          description:
              'Supply voltage is ${volt.value.toStringAsFixed(1)}V which exceeds safe limits. '
              'This can damage appliances. Consider using a voltage stabilizer.',
          type: InsightType.safety,
          priority: InsightPriority.critical,
          actionSuggestion: 'Install voltage stabilizer immediately',
        ));
      } else if (volt.value < 200) {
        insights.add(AIInsight(
          id: 'insight_volt_low',
          title: 'Low Voltage Warning',
          description:
              'Supply voltage has dropped to ${volt.value.toStringAsFixed(1)}V. '
              'This can cause appliance malfunction and overheating of motors.',
          type: InsightType.safety,
          priority: InsightPriority.high,
          actionSuggestion: 'Check power supply and use stabilizer',
        ));
      }
    }

    // Current / Power Analysis
    final current = sensorData['current'];
    final power = sensorData['power'];
    if (current != null && power != null) {
      if (current.value > 10) {
        insights.add(AIInsight(
          id: 'insight_current_high',
          title: 'High Current Draw',
          description:
              'Current draw is ${current.value.toStringAsFixed(1)}A (${power.value.toStringAsFixed(0)}W). '
              'This is close to the circuit breaker limit. Turn off unused appliances.',
          type: InsightType.safety,
          priority: InsightPriority.high,
          potentialSaving: power.value * 0.3,
          actionSuggestion: 'Turn off non-essential appliances',
        ));
      }

      // Energy saving suggestion
      insights.add(AIInsight(
        id: 'insight_energy_pattern',
        title: 'Energy Usage Pattern',
        description:
            'Current power consumption is ${power.value.toStringAsFixed(0)}W. '
            'Based on usage patterns, you could save up to 20% by scheduling appliances '
            'during off-peak hours (10 PM - 6 AM).',
        type: InsightType.energySaving,
        priority: InsightPriority.low,
        potentialSaving: power.value * 0.2 * 30 * 24 / 1000 * 8, // Monthly estimate ₹
        actionSuggestion: 'Schedule heavy appliances for off-peak hours',
      ));
    }

    // Water Level Analysis
    final water = sensorData['waterLevel'];
    if (water != null) {
      if (water.value < 15) {
        insights.add(AIInsight(
          id: 'insight_water_critical',
          title: 'Water Tank Almost Empty!',
          description:
              'Water level is critically low at ${water.value.toStringAsFixed(0)}%. '
              'Turn on the water pump immediately to refill.',
          type: InsightType.waterManagement,
          priority: InsightPriority.critical,
          actionSuggestion: 'Turn on water pump',
        ));
      } else if (water.value < 30) {
        insights.add(AIInsight(
          id: 'insight_water_low',
          title: 'Low Water Level',
          description:
              'Water tank is at ${water.value.toStringAsFixed(0)}%. '
              'Consider scheduling a pump cycle to maintain adequate water supply.',
          type: InsightType.waterManagement,
          priority: InsightPriority.medium,
          actionSuggestion: 'Schedule water pump for refill',
        ));
      } else if (water.value > 90) {
        insights.add(AIInsight(
          id: 'insight_water_full',
          title: 'Water Tank Nearly Full',
          description:
              'Water tank is at ${water.value.toStringAsFixed(0)}%. '
              'Turn off the water pump to prevent overflow.',
          type: InsightType.waterManagement,
          priority: InsightPriority.high,
          actionSuggestion: 'Turn off water pump',
        ));
      }
    }

    // Always add a maintenance insight
    insights.add(AIInsight(
      id: 'insight_maintenance',
      title: 'Scheduled Maintenance Reminder',
      description:
          'It has been 30 days since the last AC filter cleaning. '
          'Regular maintenance improves efficiency by up to 15% and extends appliance life.',
      type: InsightType.maintenance,
      priority: InsightPriority.low,
      potentialSaving: 150,
      actionSuggestion: 'Schedule AC maintenance',
    ));

    return insights;
  }

  /// Predict future sensor values using simple trend analysis
  List<Map<String, dynamic>> predictTrend(List<SensorData> historicalData, int hoursAhead) {
    if (historicalData.isEmpty) return [];

    final predictions = <Map<String, dynamic>>[];
    final n = historicalData.length;

    // Simple linear regression
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < n; i++) {
      sumX += i;
      sumY += historicalData[i].value;
      sumXY += i * historicalData[i].value;
      sumX2 += i * i;
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    final lastTime = historicalData.last.timestamp;
    final interval = n > 1
        ? historicalData[1].timestamp.difference(historicalData[0].timestamp).inMinutes
        : 5;

    for (int i = 1; i <= (hoursAhead * 60 / interval); i++) {
      final predictedValue = intercept + slope * (n + i);
      final noise = (_random.nextDouble() - 0.5) * 2;
      predictions.add({
        'timestamp': lastTime.add(Duration(minutes: interval * i)).toIso8601String(),
        'value': predictedValue + noise,
        'confidence': (0.95 - i * 0.01).clamp(0.5, 0.95),
      });
    }

    return predictions;
  }

  /// Generate energy report
  Map<String, dynamic> generateEnergyReport() {
    return {
      'dailyConsumption': 12.5 + _random.nextDouble() * 3,
      'weeklyConsumption': 85.0 + _random.nextDouble() * 15,
      'monthlyConsumption': 350.0 + _random.nextDouble() * 50,
      'costPerUnit': 8.0,
      'peakHours': [9, 10, 11, 18, 19, 20, 21],
      'offPeakSaving': 15 + _random.nextInt(10),
      'carbonFootprint': 250 + _random.nextDouble() * 50,
      'efficiency': 72 + _random.nextInt(15),
      'topConsumers': [
        {'name': 'Air Conditioner', 'percentage': 35, 'consumption': 4.5},
        {'name': 'Water Heater', 'percentage': 20, 'consumption': 2.5},
        {'name': 'Refrigerator', 'percentage': 15, 'consumption': 1.9},
        {'name': 'Lights', 'percentage': 12, 'consumption': 1.5},
        {'name': 'Others', 'percentage': 18, 'consumption': 2.1},
      ],
    };
  }

  /// Anomaly detection
  List<Map<String, dynamic>> detectAnomalies(List<SensorData> data) {
    if (data.length < 10) return [];

    final anomalies = <Map<String, dynamic>>[];
    final values = data.map((d) => d.value).toList();

    // Calculate mean and standard deviation
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    final stdDev = sqrt(variance);

    for (int i = 0; i < data.length; i++) {
      if ((data[i].value - mean).abs() > 2 * stdDev) {
        anomalies.add({
          'index': i,
          'value': data[i].value,
          'timestamp': data[i].timestamp.toIso8601String(),
          'deviation': ((data[i].value - mean) / stdDev).toStringAsFixed(2),
          'type': data[i].value > mean ? 'spike' : 'drop',
        });
      }
    }

    return anomalies;
  }
}
