import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/energy_analytics_service.dart';

class EnergyDetailsScreen extends StatefulWidget {
  const EnergyDetailsScreen({super.key});

  @override
  State<EnergyDetailsScreen> createState() => _EnergyDetailsScreenState();
}

class _EnergyDetailsScreenState extends State<EnergyDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final energy = context.watch<EnergyAnalyticsService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCostTab(energy),
                    _buildBillTab(energy),
                    _buildSolarTab(energy),
                    _buildWaterTab(energy),
                    _buildLeaderboardTab(energy),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Energy Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 42,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'Cost'), Tab(text: 'Bill'), Tab(text: 'Solar'), Tab(text: 'Water'), Tab(text: 'Rank')],
      ),
    );
  }

  // ===== COST TAB (Features 20, 22, 29) =====
  Widget _buildCostTab(EnergyAnalyticsService energy) {
    final cost = energy.costData;
    if (cost == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Budget progress
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Monthly Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('₹${cost.monthCost.toStringAsFixed(0)} / ₹${cost.budgetLimit.toStringAsFixed(0)}',
                  style: TextStyle(color: cost.budgetUsed > 0.8 ? const Color(0xFFF44336) : AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: cost.budgetUsed, minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation(cost.budgetUsed > 0.8 ? const Color(0xFFF44336) : AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text('${(cost.budgetUsed * 100).toStringAsFixed(0)}% used • Projected: ₹${cost.projectedMonthly.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          ],
        )),
        const SizedBox(height: 12),
        // Cost summary
        Row(
          children: [
            Expanded(child: _metricCard('Today', '₹${cost.todayCost.toStringAsFixed(0)}', Icons.today, const Color(0xFF2196F3))),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('This Week', '₹${cost.weekCost.toStringAsFixed(0)}', Icons.date_range, const Color(0xFF4CAF50))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard('Rate Now', '₹${cost.currentRate}/kWh', Icons.bolt,
              cost.currentRate > 7 ? const Color(0xFFF44336) : const Color(0xFF4CAF50))),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('Tariff', cost.tariffPlan.split(' ').first, Icons.receipt, const Color(0xFF9C27B0))),
          ],
        ),
        const SizedBox(height: 16),
        // Hourly cost chart
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hourly Cost Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                barGroups: cost.hourlyCosts.map((h) => BarChartGroupData(
                  x: h.hour,
                  barRods: [BarChartRodData(
                    toY: h.cost, width: 8,
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: h.isPeak
                          ? [const Color(0xFFF44336).withValues(alpha: 0.5), const Color(0xFFF44336)]
                          : [const Color(0xFF4CAF50).withValues(alpha: 0.5), const Color(0xFF4CAF50)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  )],
                )).toList(),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                    getTitlesWidget: (value, _) {
                      if (value.toInt() % 4 == 0) return Text('${value.toInt()}h', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3)));
                      return const SizedBox.shrink();
                    },
                  )),
                ),
              )),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(const Color(0xFFF44336), 'Peak (₹${cost.peakRate}/kWh)'),
                const SizedBox(width: 20),
                _legendDot(const Color(0xFF4CAF50), 'Off-Peak (₹${cost.offPeakRate}/kWh)'),
              ],
            ),
          ],
        )),
        const SizedBox(height: 16),
        // Usage comparison (Feature 22)
        if (energy.comparison != null) ...[
          _card(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Usage Comparison', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Column(
                    children: [
                      Text('${energy.comparison!.currentUsage.toStringAsFixed(0)} kWh',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('This Month', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: energy.comparison!.improved
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                          : const Color(0xFFF44336).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(energy.comparison!.improved ? Icons.trending_down : Icons.trending_up,
                          color: energy.comparison!.improved ? const Color(0xFF4CAF50) : const Color(0xFFF44336), size: 16),
                        const SizedBox(width: 4),
                        Text('${energy.comparison!.changePercent.abs().toStringAsFixed(1)}%',
                          style: TextStyle(fontWeight: FontWeight.bold,
                            color: energy.comparison!.improved ? const Color(0xFF4CAF50) : const Color(0xFFF44336))),
                      ],
                    ),
                  ),
                  Expanded(child: Column(
                    children: [
                      Text('${energy.comparison!.previousUsage.toStringAsFixed(0)} kWh',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.5))),
                      Text('Last Month', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Neighborhood avg: ${energy.comparison!.avgNeighborhood.toStringAsFixed(0)} kWh',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                  Text('Top ${energy.comparison!.ranking.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                ],
              ),
            ],
          )),
        ],
        const SizedBox(height: 16),
        // Power Factor Tips (Feature 29)
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tips_and_updates, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                const Text('Power Factor Tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ...energy.powerFactorTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6, height: 6,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), height: 1.4))),
                ],
              ),
            )),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  // ===== BILL TAB (Feature 23) =====
  Widget _buildBillTab(EnergyAnalyticsService energy) {
    final bill = energy.billEstimate;
    if (bill == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(child: Column(
          children: [
            const Text('Estimated Bill', style: TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 8),
            Text('₹${bill.estimatedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Range: ₹${bill.minEstimate.toStringAsFixed(0)} - ₹${bill.maxEstimate.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('Days Left', '${bill.daysRemaining}', const Color(0xFF2196F3)),
                _miniStat('Daily Avg', '₹${bill.dailyAverage.toStringAsFixed(0)}', const Color(0xFF4CAF50)),
                _miniStat('vs Last', '${bill.comparedToLastMonth > 0 ? "+" : ""}${bill.comparedToLastMonth.toStringAsFixed(1)}%',
                  bill.comparedToLastMonth > 0 ? const Color(0xFFF44336) : const Color(0xFF4CAF50)),
              ],
            ),
          ],
        )),
        const SizedBox(height: 16),
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bill Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(PieChartData(
                sections: bill.breakdown.map((b) => PieChartSectionData(
                  value: b.percentage, color: b.color, radius: 50,
                  title: '${b.percentage.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                )).toList(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              )),
            ),
            const SizedBox(height: 16),
            ...bill.breakdown.map((b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: b.color)),
                  const SizedBox(width: 10),
                  Icon(b.icon, size: 16, color: b.color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(b.category, style: const TextStyle(fontSize: 13, color: Colors.white))),
                  Text('₹${b.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: b.color)),
                ],
              ),
            )),
          ],
        )),
        const SizedBox(height: 16),
        // Carbon Footprint (Feature 30)
        _card(child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF4CAF50).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Carbon Footprint', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${energy.carbonFootprint.toStringAsFixed(1)} kg CO₂ this month',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Column(
              children: [
                Text('${(energy.carbonFootprint * 12).toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                Text('kg/year', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  // ===== SOLAR TAB (Feature 24, 25) =====
  Widget _buildSolarTab(EnergyAnalyticsService energy) {
    final solar = energy.solarData;
    final battery = energy.batteryData;
    if (solar == null || battery == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Solar overview
        _card(child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFFF9800).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.solar_power, color: Color(0xFFFF9800), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${solar.currentGeneration.toStringAsFixed(0)}W', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Currently generating • ${solar.panelStatus}', style: TextStyle(fontSize: 11, color: solar.statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _miniStat('Today', '${solar.todayGeneration.toStringAsFixed(1)} kWh', const Color(0xFFFF9800))),
                Expanded(child: _miniStat('Month', '${solar.monthGeneration.toStringAsFixed(0)} kWh', const Color(0xFF4CAF50))),
                Expanded(child: _miniStat('Efficiency', '${solar.efficiency.toStringAsFixed(0)}%', const Color(0xFF2196F3))),
              ],
            ),
            const SizedBox(height: 16),
            // Generation chart
            SizedBox(
              height: 150,
              child: BarChart(BarChartData(
                barGroups: List.generate(24, (h) => BarChartGroupData(
                  x: h,
                  barRods: [BarChartRodData(
                    toY: solar.hourlyGeneration[h], width: 8,
                    gradient: LinearGradient(colors: [const Color(0xFFFF9800).withValues(alpha: 0.3), const Color(0xFFFF9800)],
                      begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                  )],
                )),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20,
                    getTitlesWidget: (v, _) => v.toInt() % 6 == 0 ? Text('${v.toInt()}h', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))) : const SizedBox.shrink(),
                  )),
                ),
              )),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Grid Export: ${solar.gridExport.toStringAsFixed(1)} kWh', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                Text('Self Use: ${solar.selfConsumption.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                Text('ROI: ${solar.roiProgress.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: Color(0xFF4CAF50))),
              ],
            ),
          ],
        )),
        const SizedBox(height: 16),
        // Battery / UPS (Feature 25)
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.battery_charging_full, color: Color(0xFF2196F3), size: 20),
                const SizedBox(width: 8),
                const Text('Battery / UPS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: battery.statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(battery.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: battery.statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Battery gauge
            Center(
              child: SizedBox(
                width: 120, height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120, height: 120,
                      child: CircularProgressIndicator(
                        value: battery.chargeLevel / 100, strokeWidth: 10,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation(battery.statusColor),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${battery.chargeLevel.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('${battery.backupTimeMinutes.toStringAsFixed(0)} min', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _miniStat('Voltage', '${battery.voltage.toStringAsFixed(1)}V', const Color(0xFFFF9800))),
                Expanded(child: _miniStat('Health', '${battery.health.toStringAsFixed(0)}%', const Color(0xFF4CAF50))),
                Expanded(child: _miniStat('Load', '${battery.loadPercent.toStringAsFixed(0)}%', const Color(0xFF2196F3))),
              ],
            ),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  // ===== WATER TAB (Feature 27) =====
  Widget _buildWaterTab(EnergyAnalyticsService energy) {
    final water = energy.waterAnalytics;
    if (water == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(child: _metricCard('Today', '${water.todayUsage.toStringAsFixed(0)}L', Icons.water_drop, const Color(0xFF00BCD4))),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('This Week', '${water.weekUsage.toStringAsFixed(0)}L', Icons.date_range, const Color(0xFF2196F3))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _metricCard('Fill Cycles', '${water.fillCycles}', Icons.replay, const Color(0xFF4CAF50))),
            const SizedBox(width: 12),
            Expanded(child: _metricCard('Avg Fill', '${water.avgFillTime.toStringAsFixed(0)} min', Icons.timer, const Color(0xFF9C27B0))),
          ],
        ),
        const SizedBox(height: 16),
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fill History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...water.fillHistory.map((fill) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(fill.wasAutomatic ? Icons.auto_mode : Icons.touch_app,
                    color: fill.wasAutomatic ? const Color(0xFF00BCD4) : const Color(0xFFFF9800), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${fill.startLevel.toStringAsFixed(0)}% → ${fill.endLevel.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text('${fill.volumeFilled.toStringAsFixed(0)}L filled • ${fill.wasAutomatic ? "Auto" : "Manual"}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                  Text('${fill.endTime.difference(fill.startTime).inMinutes} min',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            )),
          ],
        )),
        const SizedBox(height: 12),
        _card(child: Row(
          children: [
            Icon(Icons.water_damage, color: const Color(0xFFF44336).withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Wastage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                Text('${water.wastageEstimate.toStringAsFixed(0)} liters this month (₹${water.costEstimate.toStringAsFixed(0)})',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              ],
            )),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  // ===== LEADERBOARD TAB (Feature 28) =====
  Widget _buildLeaderboardTab(EnergyAnalyticsService energy) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Savings tracker (Feature 21)
        if (energy.savingsData != null) ...[
          _card(child: Column(
            children: [
              const Icon(Icons.savings, color: Color(0xFF4CAF50), size: 40),
              const SizedBox(height: 8),
              Text('₹${energy.savingsData!.totalSaved.toStringAsFixed(0)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Total Saved', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _miniStat('This Month', '₹${energy.savingsData!.thisMonthSaved.toStringAsFixed(0)}', const Color(0xFF4CAF50)),
                  _miniStat('CO₂ Saved', '${energy.savingsData!.carbonReduced.toStringAsFixed(0)} kg', const Color(0xFF2196F3)),
                  _miniStat('Streak', '${energy.savingsData!.streakDays} days 🔥', const Color(0xFFFF9800)),
                ],
              ),
            ],
          )),
          const SizedBox(height: 16),
        ],
        // Leaderboard
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.leaderboard, color: Color(0xFFFFD700), size: 20),
                SizedBox(width: 8),
                Text('Energy Leaderboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            ...energy.leaderboard.map((entry) {
              final isYou = entry.userName == 'You';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isYou ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(14),
                  border: isYou ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)) : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(entry.rank <= 3 ? ['🥇', '🥈', '🥉'][entry.rank - 1] : '#${entry.rank}',
                        style: TextStyle(fontSize: entry.rank <= 3 ? 18 : 13, fontWeight: FontWeight.bold,
                          color: entry.rank <= 3 ? Colors.white : Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isYou ? AppTheme.primaryColor : Colors.white.withValues(alpha: 0.1),
                      child: Text(entry.avatar, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isYou ? Colors.white : Colors.white54)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.userName, style: TextStyle(fontSize: 13, fontWeight: isYou ? FontWeight.bold : FontWeight.w500, color: Colors.white)),
                        Text('${entry.points} pts • ${entry.badges.join(" ")}',
                          style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    )),
                    Text('${entry.savingsPercent.toStringAsFixed(1)}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                      color: entry.rank <= 3 ? const Color(0xFF4CAF50) : Colors.white54)),
                  ],
                ),
              );
            }),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  // ===== COMMON WIDGETS =====
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
      ],
    );
  }
}
