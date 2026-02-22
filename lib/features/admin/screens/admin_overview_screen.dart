import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/admin/providers/admin_provider.dart';

/// Admin overview dashboard — the first tab inside the admin web shell.
class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    if (admin.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(admin)),
          SliverToBoxAdapter(child: _buildKPIRow(admin)),
          SliverToBoxAdapter(child: _buildChartsRow(admin)),
          SliverToBoxAdapter(child: _buildMiddleRow(admin, context)),
          SliverToBoxAdapter(child: _buildBottomRow(admin)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminProvider admin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('System overview & real-time monitoring', style: TextStyle(fontSize: 13, color: Colors.white38)),
              ],
            ),
          ),
          _headerPill('SYSTEM HEALTHY', AppTheme.successColor),
          const SizedBox(width: 12),
          _headerPill('${0} CRITICAL', AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _headerPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
    );
  }

  // ═══════════════ KPI ROW ═══════════════
  Widget _buildKPIRow(AdminProvider a) {
    final kpis = [
      _KPI('Total Users', '${a.totalUsers}', Icons.people, AppTheme.primaryColor, '+3 this week'),
      _KPI('Active Devices', '${a.activeDevices}/${a.totalDevices}', Icons.devices, AppTheme.secondaryColor, '${a.onlineNodes} nodes online'),
      _KPI('AI Models', '${a.deployedModels} deployed', Icons.psychology, const Color(0xFF9C27B0), '${a.trainingModelsCount} training'),
      _KPI('Uptime', '${a.uptime.toStringAsFixed(1)}%', Icons.timer, AppTheme.successColor, 'Last 30 days'),
      _KPI('API Calls (24h)', _formatNum(a.apiCalls24h), Icons.api, const Color(0xFF2196F3), '${a.avgResponseTime.toStringAsFixed(0)}ms avg'),
      _KPI('MQTT Msgs (24h)', _formatNum(a.mqttMessages24h), Icons.message, AppTheme.warningColor, '${a.totalInferences} inferences'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: kpis.map((k) => SizedBox(
          width: 210,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: k.color.withValues(alpha: 0.15))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: k.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(k.icon, color: k.color, size: 18)),
                    const Spacer(),
                    Text(k.value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: k.color)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(k.label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
                Text(k.sub, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  // ═══════════════ CHARTS ROW ═══════════════
  Widget _buildChartsRow(AdminProvider a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildSystemMetricsChart(a)),
          const SizedBox(width: 16),
          Expanded(child: _buildSystemHealthGauges(a)),
        ],
      ),
    );
  }

  Widget _buildSystemMetricsChart(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 8),
              const Text('System Metrics (last 30 min)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              _chartLegend('CPU', AppTheme.primaryColor),
              const SizedBox(width: 12),
              _chartLegend('Memory', AppTheme.secondaryColor),
              const SizedBox(width: 12),
              _chartLegend('Network', AppTheme.warningColor),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.05), strokeWidth: 1)),
                titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text('${v.toInt()}%', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))))), bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                borderData: FlBorderData(show: false),
                minY: 0, maxY: 100,
                lineBarsData: [
                  _line(a.cpuHistory, AppTheme.primaryColor),
                  _line(a.memoryHistory, AppTheme.secondaryColor),
                  _line(a.networkHistory, AppTheme.warningColor),
                ],
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> data, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
    ]);
  }

  Widget _buildSystemHealthGauges(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.monitor_heart, color: AppTheme.successColor, size: 18),
              SizedBox(width: 8),
              Text('Health', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          _gauge('CPU', a.cpuUsage, AppTheme.primaryColor),
          _gauge('Memory', a.memoryUsage, AppTheme.secondaryColor),
          _gauge('Disk', a.diskUsage, AppTheme.warningColor),
          _gauge('Network', a.networkTraffic.clamp(0, 100), const Color(0xFF2196F3)),
          const SizedBox(height: 12),
          _infoRow('MQTT Connections', '5'),
          _infoRow('WebSocket Clients', '3'),
          _infoRow('Database Size', '245 MB'),
          _infoRow('Last Backup', '2h ago'),
        ],
      ),
    );
  }

  Widget _gauge(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 65, child: Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: (value / 100).clamp(0, 1), backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation(value > 80 ? AppTheme.errorColor : color), minHeight: 8),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('${value.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: value > 80 ? AppTheme.errorColor : color))),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white54)),
        ],
      ),
    );
  }

  // ═══════════════ MIDDLE ROW ═══════════════
  Widget _buildMiddleRow(AdminProvider a, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDeviceNetworkCard(a)),
          const SizedBox(width: 16),
          Expanded(child: _buildAPIHealthCard(a)),
          const SizedBox(width: 16),
          Expanded(child: _buildSecurityEventsCard(a)),
        ],
      ),
    );
  }

  Widget _buildDeviceNetworkCard(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Network', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: PieChart(PieChartData(
              sectionsSpace: 3, centerSpaceRadius: 30,
              sections: [
                PieChartSectionData(value: a.onlineNodes.toDouble(), color: AppTheme.successColor, radius: 22, title: '${a.onlineNodes}', titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                PieChartSectionData(value: a.offlineNodes.toDouble(), color: AppTheme.errorColor.withValues(alpha: 0.6), radius: 22, title: '${a.offlineNodes}', titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            )),
          ),
          const SizedBox(height: 12),
          ...a.deviceNodes.take(4).map((d) => _deviceRow(d)),
        ],
      ),
    );
  }

  Widget _deviceRow(DeviceNode d) {
    final online = d.status == 'online';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: online ? AppTheme.successColor : AppTheme.errorColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(d.name, style: const TextStyle(fontSize: 11, color: Colors.white70), overflow: TextOverflow.ellipsis)),
          Text(d.ipAddress, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  Widget _buildAPIHealthCard(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('API Health', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          ...a.apiEndpoints.take(6).map((ep) {
            final warn = ep.status == 'warning';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: ep.method == 'GET' ? const Color(0xFF2196F3).withValues(alpha: 0.15) : const Color(0xFF4CAF50).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(ep.method, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: ep.method == 'GET' ? const Color(0xFF2196F3) : const Color(0xFF4CAF50))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ep.path, style: const TextStyle(fontSize: 11, color: Colors.white60, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  Text('${ep.avgLatency.toStringAsFixed(0)}ms', style: TextStyle(fontSize: 10, color: warn ? AppTheme.warningColor : Colors.white38)),
                  const SizedBox(width: 6),
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: warn ? AppTheme.warningColor : AppTheme.successColor, shape: BoxShape.circle)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSecurityEventsCard(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: AppTheme.errorColor, size: 16),
              const SizedBox(width: 6),
              const Text('Security Events', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)), child: Text('${a.securityEvents.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.errorColor))),
            ],
          ),
          const SizedBox(height: 12),
          ...a.securityEvents.map((e) {
            final sevColor = e.severity == 'critical' ? AppTheme.errorColor : e.severity == 'high' ? AppTheme.warningColor : e.severity == 'medium' ? const Color(0xFF2196F3) : Colors.white38;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: sevColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text(e.severity.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: sevColor)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.description, style: const TextStyle(fontSize: 11, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${e.source} • ${_timeAgo(e.timestamp)}', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════ BOTTOM ROW ═══════════════
  Widget _buildBottomRow(AdminProvider a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildRecentLogsCard(a)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildRecentActivityCard(a)),
        ],
      ),
    );
  }

  Widget _buildRecentLogsCard(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.article, color: AppTheme.primaryColor, size: 16),
              SizedBox(width: 6),
              Text('Recent System Logs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          ...a.systemLogs.take(8).map((log) {
            final (logColor, logIcon) = _logStyle(log.level);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(logIcon, color: logColor, size: 14),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(color: logColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(log.source, style: TextStyle(fontSize: 9, color: logColor)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(log.message, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(_timeAgo(log.timestamp), style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(AdminProvider a) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: AppTheme.warningColor, size: 16),
              SizedBox(width: 6),
              Text('User Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          ...a.userActivities.take(7).map((act) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(act.user[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(act.action, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65)), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${act.user} • ${_timeAgo(act.timestamp)}', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ═══════════════ HELPERS ═══════════════
  (Color, IconData) _logStyle(LogLevel level) {
    switch (level) {
      case LogLevel.info: return (AppTheme.secondaryColor, Icons.info_outline);
      case LogLevel.warning: return (AppTheme.warningColor, Icons.warning_amber);
      case LogLevel.error: return (AppTheme.errorColor, Icons.error_outline);
      case LogLevel.critical: return (Colors.red, Icons.dangerous);
    }
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  String _formatNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _KPI {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _KPI(this.label, this.value, this.icon, this.color, this.sub);
}
