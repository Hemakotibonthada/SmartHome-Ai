import 'dart:math';
import 'package:flutter/material.dart';

// ========== FEATURE 20: Energy Cost Calculator ==========
class EnergyCostData {
  final double currentRate; // per kWh
  final double currentUsage; // kWh
  final double todayCost;
  final double weekCost;
  final double monthCost;
  final double projectedMonthly;
  final double budgetLimit;
  final double budgetUsed;
  final List<HourlyCost> hourlyCosts;
  final List<DailyCost> dailyCosts;
  final String tariffPlan;
  final double peakRate;
  final double offPeakRate;

  EnergyCostData({
    required this.currentRate,
    required this.currentUsage,
    required this.todayCost,
    required this.weekCost,
    required this.monthCost,
    required this.projectedMonthly,
    required this.budgetLimit,
    required this.budgetUsed,
    required this.hourlyCosts,
    required this.dailyCosts,
    required this.tariffPlan,
    required this.peakRate,
    required this.offPeakRate,
  });
}

class HourlyCost {
  final int hour;
  final double cost;
  final double usage;
  final bool isPeak;

  HourlyCost({required this.hour, required this.cost, required this.usage, required this.isPeak});
}

class DailyCost {
  final String day;
  final double cost;
  final double usage;

  DailyCost({required this.day, required this.cost, required this.usage});
}

// ========== FEATURE 21: Savings Tracker ==========
class SavingsData {
  final double totalSaved;
  final double thisMonthSaved;
  final double carbonReduced; // kg CO2
  final List<SavingsEntry> history;
  final int streakDays;
  final String rank; // Eco Warrior, etc
  final double targetSavings;

  SavingsData({
    required this.totalSaved,
    required this.thisMonthSaved,
    required this.carbonReduced,
    required this.history,
    required this.streakDays,
    required this.rank,
    required this.targetSavings,
  });
}

class SavingsEntry {
  final DateTime date;
  final double amount;
  final String source;

  SavingsEntry({required this.date, required this.amount, required this.source});
}

// ========== FEATURE 22: Usage Comparison ==========
class UsageComparison {
  final String period;
  final double currentUsage;
  final double previousUsage;
  final double changePercent;
  final bool improved;
  final double avgNeighborhood;
  final double ranking; // percentile

  UsageComparison({
    required this.period,
    required this.currentUsage,
    required this.previousUsage,
    required this.changePercent,
    required this.improved,
    required this.avgNeighborhood,
    required this.ranking,
  });
}

// ========== FEATURE 23: Bill Estimator ==========
class BillEstimate {
  final double estimatedAmount;
  final double minEstimate;
  final double maxEstimate;
  final DateTime billingDate;
  final int daysRemaining;
  final double dailyAverage;
  final List<BillBreakdown> breakdown;
  final double comparedToLastMonth;

  BillEstimate({
    required this.estimatedAmount,
    required this.minEstimate,
    required this.maxEstimate,
    required this.billingDate,
    required this.daysRemaining,
    required this.dailyAverage,
    required this.breakdown,
    required this.comparedToLastMonth,
  });
}

class BillBreakdown {
  final String category;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;

  BillBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

// ========== FEATURE 24: Solar Dashboard ==========
class SolarData {
  final double currentGeneration; // W
  final double todayGeneration; // kWh
  final double monthGeneration;
  final double efficiency;
  final double gridExport;
  final double selfConsumption;
  final double roiProgress;
  final List<double> hourlyGeneration;
  final String panelStatus;
  final Color statusColor;

  SolarData({
    required this.currentGeneration,
    required this.todayGeneration,
    required this.monthGeneration,
    required this.efficiency,
    required this.gridExport,
    required this.selfConsumption,
    required this.roiProgress,
    required this.hourlyGeneration,
    required this.panelStatus,
    required this.statusColor,
  });
}

// ========== FEATURE 25: Battery/UPS Monitor ==========
class BatteryData {
  final double chargeLevel;
  final String status; // Charging, Discharging, Full, Standby
  final double voltage;
  final double health;
  final double backupTimeMinutes;
  final double inputVoltage;
  final double loadPercent;
  final Color statusColor;

  BatteryData({
    required this.chargeLevel,
    required this.status,
    required this.voltage,
    required this.health,
    required this.backupTimeMinutes,
    required this.inputVoltage,
    required this.loadPercent,
    required this.statusColor,
  });
}

// ========== FEATURE 26: Power Waveform ==========
class PowerWaveform {
  final List<double> voltageWave;
  final List<double> currentWave;
  final double frequency;
  final double thd; // Total Harmonic Distortion %
  final double crestFactor;

  PowerWaveform({
    required this.voltageWave,
    required this.currentWave,
    required this.frequency,
    required this.thd,
    required this.crestFactor,
  });
}

// ========== FEATURE 27: Water Analytics ==========
class WaterAnalytics {
  final double todayUsage; // liters
  final double weekUsage;
  final double monthUsage;
  final int fillCycles;
  final double avgFillTime; // minutes
  final double wastageEstimate;
  final List<WaterFillEvent> fillHistory;
  final double costEstimate;

  WaterAnalytics({
    required this.todayUsage,
    required this.weekUsage,
    required this.monthUsage,
    required this.fillCycles,
    required this.avgFillTime,
    required this.wastageEstimate,
    required this.fillHistory,
    required this.costEstimate,
  });
}

class WaterFillEvent {
  final DateTime startTime;
  final DateTime endTime;
  final double startLevel;
  final double endLevel;
  final double volumeFilled;
  final bool wasAutomatic;

  WaterFillEvent({
    required this.startTime,
    required this.endTime,
    required this.startLevel,
    required this.endLevel,
    required this.volumeFilled,
    required this.wasAutomatic,
  });
}

// ========== FEATURE 28: Energy Leaderboard ==========
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String avatar;
  final double savingsPercent;
  final int rank;
  final int points;
  final List<String> badges;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.savingsPercent,
    required this.rank,
    required this.points,
    required this.badges,
  });
}

// ========== ENERGY ANALYTICS SERVICE ==========
class EnergyAnalyticsService extends ChangeNotifier {
  final Random _random = Random();

  EnergyCostData? _costData;
  EnergyCostData? get costData => _costData;

  SavingsData? _savingsData;
  SavingsData? get savingsData => _savingsData;

  UsageComparison? _comparison;
  UsageComparison? get comparison => _comparison;

  BillEstimate? _billEstimate;
  BillEstimate? get billEstimate => _billEstimate;

  SolarData? _solarData;
  SolarData? get solarData => _solarData;

  BatteryData? _batteryData;
  BatteryData? get batteryData => _batteryData;

  PowerWaveform? _waveform;
  PowerWaveform? get waveform => _waveform;

  WaterAnalytics? _waterAnalytics;
  WaterAnalytics? get waterAnalytics => _waterAnalytics;

  List<LeaderboardEntry> _leaderboard = [];
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  // Feature 29: Power Factor Tips
  List<String> _powerFactorTips = [];
  List<String> get powerFactorTips => _powerFactorTips;

  // Feature 30: Carbon Footprint
  double _carbonFootprint = 0;
  double get carbonFootprint => _carbonFootprint;

  EnergyAnalyticsService() {
    _initializeAll();
  }

  void _initializeAll() {
    _generateCostData();
    _generateSavingsData();
    _generateComparison();
    _generateBillEstimate();
    _generateSolarData();
    _generateBatteryData();
    _generateWaveform();
    _generateWaterAnalytics();
    _generateLeaderboard();
    _generatePowerFactorTips();
    _carbonFootprint = 45.6 + _random.nextDouble() * 20;
  }

  void refresh() {
    _initializeAll();
    notifyListeners();
  }

  void _generateCostData() {
    final hour = DateTime.now().hour;
    final isPeak = hour >= 6 && hour <= 22;
    final rate = isPeak ? 8.5 : 5.0;

    _costData = EnergyCostData(
      currentRate: rate,
      currentUsage: 2.5 + _random.nextDouble() * 3,
      todayCost: 45 + _random.nextDouble() * 30,
      weekCost: 320 + _random.nextDouble() * 100,
      monthCost: 1200 + _random.nextDouble() * 400,
      projectedMonthly: 1500 + _random.nextDouble() * 500,
      budgetLimit: 2000,
      budgetUsed: 0.6 + _random.nextDouble() * 0.3,
      tariffPlan: 'Time-of-Use (ToU)',
      peakRate: 8.5,
      offPeakRate: 5.0,
      hourlyCosts: List.generate(24, (h) {
        final peak = h >= 6 && h <= 22;
        final usage = peak ? 1.5 + _random.nextDouble() * 2 : 0.5 + _random.nextDouble() * 0.5;
        return HourlyCost(hour: h, cost: usage * (peak ? 8.5 : 5.0), usage: usage, isPeak: peak);
      }),
      dailyCosts: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
        final usage = 15 + _random.nextDouble() * 10;
        return DailyCost(day: day, cost: usage * 7.0, usage: usage);
      }).toList(),
    );
  }

  void _generateSavingsData() {
    _savingsData = SavingsData(
      totalSaved: 4560 + _random.nextDouble() * 1000,
      thisMonthSaved: 380 + _random.nextDouble() * 200,
      carbonReduced: 125 + _random.nextDouble() * 50,
      streakDays: 12 + _random.nextInt(20),
      rank: 'Eco Warrior',
      targetSavings: 1000,
      history: List.generate(30, (i) => SavingsEntry(
        date: DateTime.now().subtract(Duration(days: 30 - i)),
        amount: 10 + _random.nextDouble() * 25,
        source: ['AC Optimization', 'Light Schedule', 'Power Factor', 'Standby Reduction'][_random.nextInt(4)],
      )),
    );
  }

  void _generateComparison() {
    final current = 450 + _random.nextDouble() * 100;
    final previous = 500 + _random.nextDouble() * 100;
    _comparison = UsageComparison(
      period: 'This Month',
      currentUsage: current,
      previousUsage: previous,
      changePercent: ((current - previous) / previous * 100),
      improved: current < previous,
      avgNeighborhood: 480 + _random.nextDouble() * 80,
      ranking: 15 + _random.nextDouble() * 30,
    );
  }

  void _generateBillEstimate() {
    final estimated = 1500 + _random.nextDouble() * 800;
    _billEstimate = BillEstimate(
      estimatedAmount: estimated,
      minEstimate: estimated * 0.85,
      maxEstimate: estimated * 1.15,
      billingDate: DateTime.now().add(Duration(days: 10 + _random.nextInt(20))),
      daysRemaining: 10 + _random.nextInt(20),
      dailyAverage: estimated / 30,
      comparedToLastMonth: -5 + _random.nextDouble() * 15,
      breakdown: [
        BillBreakdown(category: 'AC/Cooling', amount: estimated * 0.40, percentage: 40, color: const Color(0xFF2196F3), icon: Icons.ac_unit),
        BillBreakdown(category: 'Lighting', amount: estimated * 0.15, percentage: 15, color: const Color(0xFFFF9800), icon: Icons.lightbulb),
        BillBreakdown(category: 'Water Heating', amount: estimated * 0.20, percentage: 20, color: const Color(0xFFF44336), icon: Icons.hot_tub),
        BillBreakdown(category: 'Kitchen', amount: estimated * 0.12, percentage: 12, color: const Color(0xFF4CAF50), icon: Icons.kitchen),
        BillBreakdown(category: 'Electronics', amount: estimated * 0.08, percentage: 8, color: const Color(0xFF9C27B0), icon: Icons.tv),
        BillBreakdown(category: 'Other', amount: estimated * 0.05, percentage: 5, color: const Color(0xFF607D8B), icon: Icons.electrical_services),
      ],
    );
  }

  void _generateSolarData() {
    final hour = DateTime.now().hour;
    final sunHours = hour >= 6 && hour <= 18;
    _solarData = SolarData(
      currentGeneration: sunHours ? 800 + _random.nextDouble() * 1200 : 0,
      todayGeneration: 8 + _random.nextDouble() * 6,
      monthGeneration: 280 + _random.nextDouble() * 120,
      efficiency: 75 + _random.nextDouble() * 20,
      gridExport: 3 + _random.nextDouble() * 4,
      selfConsumption: 65 + _random.nextDouble() * 20,
      roiProgress: 35 + _random.nextDouble() * 25,
      hourlyGeneration: List.generate(24, (h) {
        if (h < 6 || h > 18) return 0.0;
        final peak = -(h - 12.0) * (h - 12.0) + 36;
        return (peak / 36) * (2000 + _random.nextDouble() * 500);
      }),
      panelStatus: sunHours ? 'Generating' : 'Standby',
      statusColor: sunHours ? const Color(0xFF4CAF50) : const Color(0xFF607D8B),
    );
  }

  void _generateBatteryData() {
    final charge = 50 + _random.nextDouble() * 50;
    String status;
    Color color;
    if (charge > 90) { status = 'Full'; color = const Color(0xFF4CAF50); }
    else if (charge > 50) { status = 'Charging'; color = const Color(0xFF2196F3); }
    else if (charge > 20) { status = 'Standby'; color = const Color(0xFFFF9800); }
    else { status = 'Low'; color = const Color(0xFFF44336); }

    _batteryData = BatteryData(
      chargeLevel: charge, status: status, voltage: 48 + _random.nextDouble() * 6,
      health: 85 + _random.nextDouble() * 15, backupTimeMinutes: charge * 3.5,
      inputVoltage: 220 + _random.nextDouble() * 20, loadPercent: 30 + _random.nextDouble() * 40,
      statusColor: color,
    );
  }

  void _generateWaveform() {
    _waveform = PowerWaveform(
      voltageWave: List.generate(200, (i) => 325 * sin(2 * pi * i / 200) + _random.nextDouble() * 5),
      currentWave: List.generate(200, (i) => 15 * sin(2 * pi * i / 200 - 0.3) + _random.nextDouble() * 0.5),
      frequency: 49.9 + _random.nextDouble() * 0.2,
      thd: 2 + _random.nextDouble() * 3,
      crestFactor: 1.38 + _random.nextDouble() * 0.1,
    );
  }

  void _generateWaterAnalytics() {
    _waterAnalytics = WaterAnalytics(
      todayUsage: 200 + _random.nextDouble() * 150,
      weekUsage: 1500 + _random.nextDouble() * 800,
      monthUsage: 6000 + _random.nextDouble() * 3000,
      fillCycles: 2 + _random.nextInt(4),
      avgFillTime: 25 + _random.nextDouble() * 15,
      wastageEstimate: 15 + _random.nextDouble() * 30,
      costEstimate: 150 + _random.nextDouble() * 100,
      fillHistory: List.generate(5, (i) {
        final start = DateTime.now().subtract(Duration(hours: 6 * (5 - i)));
        return WaterFillEvent(
          startTime: start, endTime: start.add(Duration(minutes: 20 + _random.nextInt(20))),
          startLevel: 10 + _random.nextDouble() * 20, endLevel: 80 + _random.nextDouble() * 15,
          volumeFilled: 150 + _random.nextDouble() * 100, wasAutomatic: _random.nextBool(),
        );
      }),
    );
  }

  void _generateLeaderboard() {
    final names = ['You', 'Ravi K.', 'Priya S.', 'Amit P.', 'Sneha R.', 'Kiran M.', 'Deepa L.', 'Rahul T.', 'Meera V.', 'Suresh N.'];
    _leaderboard = List.generate(names.length, (i) => LeaderboardEntry(
      userId: 'u$i', userName: names[i], avatar: names[i][0],
      savingsPercent: 25 - i * 2.0 + _random.nextDouble() * 3,
      rank: i + 1, points: 1000 - i * 80 + _random.nextInt(40),
      badges: i < 3 ? ['🏆', '⚡', '🌱'] : i < 6 ? ['⚡', '🌱'] : ['🌱'],
    ));
  }

  void _generatePowerFactorTips() {
    _powerFactorTips = [
      'Your power factor is 0.85. Adding capacitor banks could save ₹200/month.',
      'High inductive loads detected (AC, motors). Consider power factor correction.',
      'Off-peak power factor drops to 0.72. Schedule heavy loads during peak efficiency.',
      'LED lighting upgrade would improve your power factor by ~0.05.',
      'Motor-driven appliances contribute 60% of reactive power consumption.',
    ];
  }
}
