import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/admin/providers/admin_provider.dart';

/// System Logs, Backups, and Device Nodes monitoring screen.
class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends State<AdminLogsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  LogLevel? _levelFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    if (admin.isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Column(
        children: [
          _buildHeader(admin),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildLogsTab(admin),
                _buildDeviceNodesTab(admin),
                _buildBackupsTab(admin),
                _buildSystemMetrics(admin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminProvider admin) {
    final errCount = admin.systemLogs.where((l) => l.level == LogLevel.error || l.level == LogLevel.critical).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
      child: Row(
        children: [
          const Icon(Icons.terminal, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Logs & Monitoring', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Logs, device nodes, backups, and system metrics', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          _pill('${admin.systemLogs.length} Logs', Colors.white54),
          const SizedBox(width: 8),
          _pill('$errCount Errors', AppTheme.errorColor),
          const SizedBox(width: 8),
          _pill('${admin.onlineNodes}/${admin.deviceNodes.length} Nodes', AppTheme.successColor),
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

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 12, 28, 0),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabCtrl,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Logs'),
          Tab(text: 'Device Nodes'),
          Tab(text: 'Backups'),
          Tab(text: 'System Metrics'),
        ],
      ),
    );
  }

  // ═══════════════ LOGS TAB ═══════════════

  Widget _buildLogsTab(AdminProvider admin) {
    final logs = admin.systemLogs.where((l) {
      if (_levelFilter != null && l.level != _levelFilter) return false;
      if (_searchQuery.isNotEmpty && !l.message.toLowerCase().contains(_searchQuery) && !l.source.toLowerCase().contains(_searchQuery)) return false;
      return true;
    }).toList();

    return Column(
      children: [
        _buildLogToolbar(admin),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(28, 0, 28, 20),
            decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
            child: logs.isEmpty
                ? Center(child: Text('No logs matching filters', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))))
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: logs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
                    itemBuilder: (ctx, i) {
                      final l = logs[i];
                      final c = _logColor(l.level);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                              child: Text(l.level.name.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: c, letterSpacing: 0.5)),
                            ),
                            const SizedBox(width: 8),
                            Text(_fmtTime(l.timestamp), style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3), fontFamily: 'monospace')),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(3)),
                              child: Text(l.source, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(l.message, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)))),
                            InkWell(
                              onTap: () => admin.clearLog(l.id),
                              borderRadius: BorderRadius.circular(4),
                              child: Icon(Icons.close, size: 14, color: Colors.white.withValues(alpha: 0.15)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogToolbar(AdminProvider admin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
      child: Row(
        children: [
          SizedBox(
            width: 240,
            height: 36,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search logs...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: Icon(Icons.search, size: 16, color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: AppTheme.darkCard,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _filterChip('All', _levelFilter == null, () => setState(() => _levelFilter = null)),
          _filterChip('Info', _levelFilter == LogLevel.info, () => setState(() => _levelFilter = LogLevel.info)),
          _filterChip('Warning', _levelFilter == LogLevel.warning, () => setState(() => _levelFilter = LogLevel.warning)),
          _filterChip('Error', _levelFilter == LogLevel.error, () => setState(() => _levelFilter = LogLevel.error)),
          _filterChip('Critical', _levelFilter == LogLevel.critical, () => setState(() => _levelFilter = LogLevel.critical)),
          const Spacer(),
          TextButton.icon(
            onPressed: admin.clearAllLogs,
            icon: const Icon(Icons.delete_sweep, size: 16),
            label: const Text('Clear All', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String l, bool sel, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sel ? AppTheme.primaryColor.withValues(alpha: 0.3) : Colors.white10),
          ),
          child: Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sel ? AppTheme.primaryColor : Colors.white38)),
        ),
      ),
    );
  }

  Color _logColor(LogLevel l) {
    switch (l) {
      case LogLevel.info: return AppTheme.secondaryColor;
      case LogLevel.warning: return AppTheme.warningColor;
      case LogLevel.error: return AppTheme.errorColor;
      case LogLevel.critical: return const Color(0xFFFF1744);
    }
  }

  String _fmtTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  // ═══════════════ DEVICE NODES TAB ═══════════════

  Widget _buildDeviceNodesTab(AdminProvider admin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
            child: const Row(
              children: [
                SizedBox(width: 24),
                Expanded(flex: 2, child: Text('NODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                Expanded(child: Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 100, child: Text('IP ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 80, child: Text('FIRMWARE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 60, child: Text('TEMP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 80, child: Text('UPTIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 60, child: Text('DATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 70, child: Text('LAST SEEN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: admin.deviceNodes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10, indent: 20, endIndent: 20),
              itemBuilder: (ctx, i) {
                final n = admin.deviceNodes[i];
                final online = n.status == 'online';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Container(width: 8, height: 8, margin: const EdgeInsets.only(right: 16), decoration: BoxDecoration(color: online ? AppTheme.successColor : AppTheme.errorColor, shape: BoxShape.circle)),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            Text(n.id, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))),
                          ],
                        ),
                      ),
                      Expanded(child: Text(n.type, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
                      SizedBox(width: 100, child: Text(n.ipAddress, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), fontFamily: 'monospace'))),
                      SizedBox(width: 80, child: Text(n.firmware, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
                      SizedBox(
                        width: 60,
                        child: Text('${n.temperature.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: n.temperature > 50 ? AppTheme.errorColor : n.temperature > 40 ? AppTheme.warningColor : AppTheme.successColor)),
                      ),
                      SizedBox(width: 80, child: Text('${n.uptime.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
                      SizedBox(width: 60, child: Text(_fmtNum(n.dataPoints), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
                      SizedBox(width: 70, child: Text(_timeAgo(n.lastSeen), style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.35)))),
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

  // ═══════════════ BACKUPS TAB ═══════════════

  Widget _buildBackupsTab(AdminProvider admin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: const BorderRadius.vertical(top: Radius.circular(18))),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                Expanded(flex: 2, child: Text('TYPE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 80, child: Text('SIZE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 70, child: Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 80, child: Text('DURATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
                SizedBox(width: 100, child: Text('TIMESTAMP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1))),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: admin.backups.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10, indent: 20, endIndent: 20),
              itemBuilder: (ctx, i) {
                final b = admin.backups[i];
                final c = b.status == 'completed'
                    ? AppTheme.successColor
                    : b.status == 'in_progress'
                        ? AppTheme.primaryColor
                        : AppTheme.errorColor;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('${i + 1}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3)))),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(b.type == 'full' ? Icons.backup : Icons.file_copy, size: 16, color: AppTheme.primaryColor.withValues(alpha: 0.5)),
                            const SizedBox(width: 8),
                            Text(b.type.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                          ],
                        ),
                      ),
                      SizedBox(width: 80, child: Text(b.size, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)))),
                      SizedBox(
                        width: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                          child: Text(b.status.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: c, letterSpacing: 0.4)),
                        ),
                      ),
                      SizedBox(width: 80, child: Text(b.duration, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)))),
                      SizedBox(width: 100, child: Text(_timeAgo(b.timestamp), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)))),
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

  // ═══════════════ SYSTEM METRICS TAB ═══════════════

  Widget _buildSystemMetrics(AdminProvider admin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      child: Column(
        children: [
          // Resource gauges
          Row(
            children: [
              Expanded(child: _gaugeCard('CPU Usage', admin.cpuUsage / 100, AppTheme.primaryColor)),
              const SizedBox(width: 14),
              Expanded(child: _gaugeCard('Memory Usage', admin.memoryUsage / 100, AppTheme.secondaryColor)),
              const SizedBox(width: 14),
              Expanded(child: _gaugeCard('Disk Usage', admin.diskUsage / 100, AppTheme.warningColor)),
              const SizedBox(width: 14),
              Expanded(child: _gaugeCard('Network', admin.networkTraffic / 100, const Color(0xFF2196F3))),
            ],
          ),
          const SizedBox(height: 16),
          // Timeline charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _timelineChart('CPU Over Time', admin.cpuHistory.map((v) => v / 100).toList(), AppTheme.primaryColor)),
              const SizedBox(width: 14),
              Expanded(child: _timelineChart('Memory Over Time', admin.memoryHistory.map((v) => v / 100).toList(), AppTheme.secondaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _timelineChart('Network Traffic', admin.networkHistory.map((v) => v / 100).toList(), const Color(0xFF2196F3))),
              const SizedBox(width: 14),
              Expanded(child: _timelineChart('Requests / min', admin.requestsPerMinute.map((e) => e / 100).toList(), AppTheme.warningColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gaugeCard(String label, double value, Color c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: value.clamp(0, 1),
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation(c),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text('${(value * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _timelineChart(String title, List<double> data, Color c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (v, _) => Text('${(v * 100).toInt()}%', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))))),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].clamp(0, 1))),
                    isCurved: true,
                    color: c,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: c.withValues(alpha: 0.06)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
