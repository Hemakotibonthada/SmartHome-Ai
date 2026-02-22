import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/admin/providers/admin_provider.dart';

/// Admin Security Events & Threat Monitoring screen.
class AdminSecurityScreen extends StatefulWidget {
  const AdminSecurityScreen({super.key});

  @override
  State<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends State<AdminSecurityScreen> {
  String _severityFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    if (admin.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Column(
        children: [
          _buildHeader(admin),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  _buildStatsRow(admin),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildEventsTable(admin)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildSeverityBreakdown(admin)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildThreatTimeline(admin),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminProvider admin) {
    final crit = admin.securityEvents.where((e) => e.severity == 'critical').length;
    final high = admin.securityEvents.where((e) => e.severity == 'high').length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
      child: Row(
        children: [
          const Icon(Icons.shield, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Security Center', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Monitor threats, intrusion attempts, and security events', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          _pill('${admin.securityEvents.length} Events', Colors.white54),
          const SizedBox(width: 8),
          _pill('$crit Critical', const Color(0xFFFF1744)),
          const SizedBox(width: 8),
          _pill('$high High', AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _pill(String l, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withValues(alpha: 0.25))),
      child: Text(l, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }

  Widget _buildStatsRow(AdminProvider admin) {
    final events = admin.securityEvents;
    final byType = <String, int>{};
    for (final e in events) {
      byType[e.type] = (byType[e.type] ?? 0) + 1;
    }
    final stats = [
      _Stat('Total Events', '${events.length}', Icons.event_note, Colors.white54),
      _Stat('Intrusion Attempts', '${byType['intrusion_attempt'] ?? 0}', Icons.warning, AppTheme.errorColor),
      _Stat('Auth Failures', '${byType['auth_failure'] ?? 0}', Icons.lock_outline, AppTheme.warningColor),
      _Stat('Port Scans', '${byType['port_scan'] ?? 0}', Icons.radar, AppTheme.primaryColor),
      _Stat('Policy Violations', '${byType['policy_violation'] ?? 0}', Icons.gavel, AppTheme.secondaryColor),
      _Stat('Anomalies', '${byType['anomaly'] ?? 0}', Icons.bug_report, const Color(0xFF9C27B0)),
    ];

    return Row(
      children: stats.map((s) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: s == stats.last ? 0 : 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: s.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(s.icon, size: 18, color: s.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: s.color)),
                    Text(s.label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildEventsTable(AdminProvider admin) {
    final events = _severityFilter == 'all' ? admin.securityEvents : admin.securityEvents.where((e) => e.severity == _severityFilter).toList();

    return Container(
      height: 420,
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text('Security Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                ...['all', 'critical', 'high', 'medium', 'low'].map((s) {
                  final sel = s == _severityFilter;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _severityFilter = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel ? _sevColor(s).withValues(alpha: 0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: sel ? _sevColor(s).withValues(alpha: 0.3) : Colors.white10),
                        ),
                        child: Text(s == 'all' ? 'All' : s.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: sel ? _sevColor(s) : Colors.white38)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (ctx, i) {
                final e = events[i];
                final c = _sevColor(e.severity);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                        child: Text(e.severity.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: c, letterSpacing: 0.3)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(3)),
                        child: Text(e.type.replaceAll('_', ' '), style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.description, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Text(e.source, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))),
                      const SizedBox(width: 8),
                      Text(_timeAgo(e.timestamp), style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBreakdown(AdminProvider admin) {
    final events = admin.securityEvents;
    final counts = <String, int>{'critical': 0, 'high': 0, 'medium': 0, 'low': 0};
    for (final e in events) {
      counts[e.severity] = (counts[e.severity] ?? 0) + 1;
    }
    final total = events.length.clamp(1, 99999);

    return Container(
      height: 420,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Severity Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: counts.entries.map((e) {
                  final pct = (e.value / total * 100);
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    color: _sevColor(e.key),
                    radius: 36,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...counts.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: _sevColor(e.key), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Text(e.key.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 0.5)),
                const Spacer(),
                Text('${e.value}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _sevColor(e.key))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildThreatTimeline(AdminProvider admin) {
    // Group security events by hour for timeline
    final now = DateTime.now();
    final hourCounts = List.filled(24, 0);
    for (final e in admin.securityEvents) {
      final hoursAgo = now.difference(e.timestamp).inHours.clamp(0, 23);
      hourCounts[23 - hoursAgo]++;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Threat Timeline (24h)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (hourCounts.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gI, rod, rI) => BarTooltipItem('${rod.toY.toInt()} events', const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, getTitlesWidget: (v, _) {
                    final h = (now.hour - (23 - v.toInt())) % 24;
                    return v.toInt() % 4 == 0 ? Text('${h}h', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))) : const SizedBox.shrink();
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(24, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: hourCounts[i].toDouble(),
                      color: hourCounts[i] > 3 ? AppTheme.errorColor : hourCounts[i] > 1 ? AppTheme.warningColor : AppTheme.primaryColor,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _sevColor(String s) {
    switch (s) {
      case 'critical': return const Color(0xFFFF1744);
      case 'high': return AppTheme.errorColor;
      case 'medium': return AppTheme.warningColor;
      case 'low': return AppTheme.secondaryColor;
      default: return Colors.white54;
    }
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}
