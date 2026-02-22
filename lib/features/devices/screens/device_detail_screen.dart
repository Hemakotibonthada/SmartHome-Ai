import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final IconData deviceIcon;
  final Color deviceColor;

  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceIcon,
    required this.deviceColor,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double _usageHoursToday;
  late double _avgDailyUsage;
  late int _peakUsageHour;
  late double _wattage;
  late List<double> _dailyWattHistory;
  late String _firmwareVersion;
  late bool _firmwareCurrent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final rng = Random(widget.deviceId.hashCode);
    _usageHoursToday = 3.0 + rng.nextDouble() * 8;
    _avgDailyUsage = 4.0 + rng.nextDouble() * 6;
    _peakUsageHour = 17 + rng.nextInt(5);
    _wattage = 20.0 + rng.nextDouble() * 60;
    _dailyWattHistory = List.generate(24, (h) {
      if (h >= 6 && h <= 22) return 20 + rng.nextDouble() * 50;
      return 5 + rng.nextDouble() * 10;
    });
    _firmwareVersion = '2.${rng.nextInt(5)}.${rng.nextInt(10)}';
    _firmwareCurrent = rng.nextBool();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SmartFeaturesService>();
    final health = svc.healthReports.cast<DeviceHealthReport?>().firstWhere(
      (h) => h?.deviceId == widget.deviceId,
      orElse: () => null,
    );
    final fingerprint = svc.fingerprints.isNotEmpty ? svc.fingerprints.first : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, health),
              _buildTabs(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(health),
                    _buildUsageTab(health),
                    _buildDiagnosticsTab(health, fingerprint),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DeviceHealthReport? health) {
    final score = health?.healthScore ?? 85;
    final scoreColor = score >= 80 ? const Color(0xFF4CAF50) : score >= 50 ? const Color(0xFFFF9800) : const Color(0xFFF44336);
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
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: widget.deviceColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(widget.deviceIcon, color: widget.deviceColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.deviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Health: $score%', style: TextStyle(fontSize: 12, color: scoreColor)),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(shape: BoxShape.circle, color: scoreColor.withValues(alpha: 0.12)),
            child: Center(child: Text('$score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: scoreColor))),
          ),
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
        indicator: BoxDecoration(color: widget.deviceColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        labelColor: widget.deviceColor,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'Overview'), Tab(text: 'Usage'), Tab(text: 'Diagnostics')],
      ),
    );
  }

  Widget _buildOverviewTab(DeviceHealthReport? health) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(child: _statCard('Uptime', '${(health?.uptime ?? 99.5).toStringAsFixed(1)}%', Icons.timer, const Color(0xFF4CAF50))),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Wattage', '${_wattage.toStringAsFixed(0)}W', Icons.bolt, const Color(0xFFFF9800))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard('Errors', '${health?.errorCount ?? 0}', Icons.error_outline, const Color(0xFFF44336))),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Status', health?.status ?? 'Good', Icons.check_circle, health?.statusColor ?? const Color(0xFF4CAF50))),
          ],
        ),
        const SizedBox(height: 16),
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Device Info', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _infoRow('Firmware', 'v$_firmwareVersion', _firmwareCurrent ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)),
            _infoRow('Today Usage', '${_usageHoursToday.toStringAsFixed(1)} hrs', const Color(0xFF2196F3)),
            _infoRow('Avg Daily', '${_avgDailyUsage.toStringAsFixed(1)} hrs', Colors.white54),
            _infoRow('Peak Hour', '$_peakUsageHour:00', const Color(0xFFFF9800)),
            if (health?.lastMaintenance != null)
              _infoRow('Last Maintenance', _formatDate(health!.lastMaintenance!), Colors.white54),
            if (health?.nextMaintenance != null)
              _infoRow('Next Maintenance', _formatDate(health!.nextMaintenance!), const Color(0xFF2196F3)),
          ],
        )),
        if (health != null && health.issues.isNotEmpty) ...[
          const SizedBox(height: 16),
          _card(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Issues & Warnings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...health.issues.map((issue) {
                final isError = issue.toLowerCase().contains('error') || issue.toLowerCase().contains('critical');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(isError ? Icons.error : Icons.warning_amber,
                        color: isError ? const Color(0xFFF44336) : const Color(0xFFFF9800), size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(issue, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)))),
                    ],
                  ),
                );
              }),
            ],
          )),
        ],
        if (health != null && health.recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          _card(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.tips_and_updates, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Text('Recommendations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 12),
              ...health.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(margin: const EdgeInsets.only(top: 6), width: 5, height: 5,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFD700))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)))),
                  ],
                ),
              )),
            ],
          )),
        ],
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildUsageTab(DeviceHealthReport? health) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('24-Hour Power Consumption', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _dailyWattHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true, color: widget.deviceColor, barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true,
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [widget.deviceColor.withValues(alpha: 0.25), widget.deviceColor.withValues(alpha: 0.0)])),
                  ),
                ],
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35,
                    getTitlesWidget: (v, _) => Text('${v.toInt()}W', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                    getTitlesWidget: (v, _) {
                      if (v.toInt() % 6 == 0) return Text('${v.toInt()}h', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3)));
                      return const SizedBox.shrink();
                    })),
                ),
              )),
            ),
          ],
        )),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statCard('Total Today', '${(_wattage * _usageHoursToday / 1000).toStringAsFixed(2)} kWh', Icons.electric_meter, const Color(0xFF2196F3))),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Est. Cost', '₹${(_wattage * _usageHoursToday * 0.008).toStringAsFixed(1)}', Icons.currency_rupee, const Color(0xFF4CAF50))),
          ],
        ),
        const SizedBox(height: 12),
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Usage Pattern', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _patternRow('Most Active', '$_peakUsageHour:00 - ${(_peakUsageHour + 2) % 24}:00', const Color(0xFFF44336)),
            _patternRow('Least Active', '2:00 - 6:00', const Color(0xFF4CAF50)),
            _patternRow('Avg On-Time', '${_avgDailyUsage.toStringAsFixed(1)} hrs/day', const Color(0xFF2196F3)),
            _patternRow('Efficiency', (health?.healthScore ?? 85) >= 80 ? 'Optimal' : 'Needs Attention',
              (health?.healthScore ?? 85) >= 80 ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDiagnosticsTab(DeviceHealthReport? health, ApplianceFingerprint? fingerprint) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        _card(child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_firmwareCurrent ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.system_update, size: 22, color: _firmwareCurrent ? const Color(0xFF4CAF50) : const Color(0xFFFF9800)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Firmware', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('v$_firmwareVersion ${_firmwareCurrent ? "✓ Up to date" : "⬆ Update available"}',
                  style: TextStyle(fontSize: 11, color: _firmwareCurrent ? const Color(0xFF4CAF50) : const Color(0xFFFF9800))),
              ],
            )),
            if (!_firmwareCurrent)
              ElevatedButton(
                onPressed: () {
                  setState(() => _firmwareCurrent = true);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Firmware updated!'), backgroundColor: Color(0xFF4CAF50)));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Update', style: TextStyle(fontSize: 12)),
              ),
          ],
        )),
        const SizedBox(height: 16),
        _card(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.wifi, color: Color(0xFF2196F3), size: 18), SizedBox(width: 8),
              Text('Network Health', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
            const SizedBox(height: 16),
            _diagRow('WiFi Signal', '-42 dBm (Excellent)', const Color(0xFF4CAF50)),
            _diagRow('Latency', '12ms', const Color(0xFF4CAF50)),
            _diagRow('Reconnects (/24h)', '0', const Color(0xFF4CAF50)),
            _diagRow('MQTT Status', 'Connected', const Color(0xFF4CAF50)),
            _diagRow('Channel', '6 (2.4GHz)', Colors.white54),
          ],
        )),
        const SizedBox(height: 16),
        if (fingerprint != null)
          _card(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.fingerprint, color: Color(0xFF9C27B0), size: 18), SizedBox(width: 8),
                Text('Power Fingerprint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: LineChart(LineChartData(
                  lineBarsData: [LineChartBarData(
                    spots: List.generate(20, (i) {
                      final rng = Random(widget.deviceId.hashCode + i);
                      return FlSpot(i.toDouble(), fingerprint.typicalPower * 0.8 + rng.nextDouble() * fingerprint.typicalPower * 0.4);
                    }),
                    isCurved: true, color: const Color(0xFF9C27B0), barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true,
                      gradient: LinearGradient(colors: [const Color(0xFF9C27B0).withValues(alpha: 0.2), Colors.transparent],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  )],
                  gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                )),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Match: ${(fingerprint.confidence * 100).toStringAsFixed(0)}% ${fingerprint.name}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                Text('${fingerprint.currentPower.toStringAsFixed(0)}W / ${fingerprint.typicalPower.toStringAsFixed(0)}W',
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
              ]),
            ],
          )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20)),
    child: child);

  Widget _statCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
    child: Column(children: [
      Icon(icon, color: color, size: 22), const SizedBox(height: 10),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
    ]));

  Widget _infoRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
      Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c)),
    ]));

  Widget _patternRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
      const SizedBox(width: 8),
      Expanded(child: Text(l, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)))),
      Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
    ]));

  Widget _diagRow(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
      Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
    ]));

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}
