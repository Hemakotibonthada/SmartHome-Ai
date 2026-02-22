import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/shared/widgets/web_content_wrapper.dart';
import 'package:smart_home_ai/shared/widgets/empty_state_widget.dart';
import 'package:smart_home_ai/core/models/user_model.dart';
import 'package:smart_home_ai/features/analytics/providers/analytics_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: analytics.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : !analytics.hasData && !context.watch<DemoModeService>().isDemoMode
                  ? EmptyStateWidget.noAnalytics()
                  : RefreshIndicator(
                  onRefresh: () => analytics.loadAnalytics(),
                  color: AppTheme.primaryColor,
                  child: CustomScrollView(
                    physics: WebContentWrapper.scrollPhysics,
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildPeriodSelector(analytics)),
                      // On desktop, show energy overview and chart side by side
                      if (Responsive.isDesktop(context))
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildEnergyOverview(analytics)),
                                Expanded(child: _buildConsumptionChart(analytics)),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(child: _buildEnergyOverview(analytics)),
                        SliverToBoxAdapter(child: _buildConsumptionChart(analytics)),
                      ],
                      SliverToBoxAdapter(child: _buildTopConsumers(analytics)),
                      // On desktop: AI insights and predictions side by side
                      if (Responsive.isDesktop(context))
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildAIInsightsSection(analytics)),
                                Expanded(child: Column(children: [
                                  _buildPredictionSection(analytics),
                                  _buildAnomalySection(analytics),
                                ])),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        SliverToBoxAdapter(child: _buildAIInsightsSection(analytics)),
                        SliverToBoxAdapter(child: _buildPredictionSection(analytics)),
                        SliverToBoxAdapter(child: _buildAnomalySection(analytics)),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.analytics, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Analytics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'Insights powered by AI',
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(AnalyticsProvider analytics) {
    final periods = ['Day', 'Week', 'Month', 'Year'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: periods.map((period) {
          final isSelected = analytics.selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => analytics.setSelectedPeriod(period),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : Colors.white38,
                  ),
                ),
              ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnergyOverview(AnalyticsProvider analytics) {
    final report = analytics.energyReport;
    final daily = (report['dailyConsumption'] ?? 12.5).toDouble();
    final weekly = (report['weeklyConsumption'] ?? 85.0).toDouble();
    final monthly = (report['monthlyConsumption'] ?? 350.0).toDouble();
    final efficiency = (report['efficiency'] ?? 72).toInt();
    final carbon = (report['carbonFootprint'] ?? 250.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard('Daily', '${daily.toStringAsFixed(1)} kWh', Icons.today, AppTheme.secondaryColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricCard('Weekly', '${weekly.toStringAsFixed(0)} kWh', Icons.date_range, AppTheme.primaryColor)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Monthly', '${monthly.toStringAsFixed(0)} kWh', Icons.calendar_month, AppTheme.warningColor)),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricCard('Efficiency', '$efficiency%', Icons.speed, AppTheme.successColor)),
            ],
          ),
          const SizedBox(height: 8),
          _buildMetricCard('Carbon Footprint', '${carbon.toStringAsFixed(0)} kg CO₂', Icons.eco, AppTheme.successColor, wide: true),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, {bool wide = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionChart(AnalyticsProvider analytics) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Energy Consumption Trend',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(7, (index) {
                    final values = [8.5, 12.3, 9.8, 14.2, 11.0, 7.5, 10.8];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: values[index],
                          gradient: AppTheme.primaryGradient,
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.05),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopConsumers(AnalyticsProvider analytics) {
    final consumers = (analytics.energyReport['topConsumers'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Energy Consumers',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: consumers.asMap().entries.map((entry) {
                    final colors = [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                      AppTheme.accentColor,
                      AppTheme.warningColor,
                      AppTheme.successColor,
                    ];
                    return PieChartSectionData(
                      value: (entry.value['percentage'] as num).toDouble(),
                      color: colors[entry.key % colors.length],
                      radius: 30,
                      title: '${entry.value['percentage']}%',
                      titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...consumers.asMap().entries.map((entry) {
              final colors = [
                AppTheme.primaryColor, AppTheme.secondaryColor,
                AppTheme.accentColor, AppTheme.warningColor, AppTheme.successColor,
              ];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: colors[entry.key % colors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value['name'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    Text(
                      '${entry.value['consumption']} kWh',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightsSection(AnalyticsProvider analytics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.secondaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Suggestions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...analytics.insights.take(3).map((insight) {
            Color priorityColor;
            switch (insight.priority) {
              case InsightPriority.critical:
                priorityColor = AppTheme.errorColor;
                break;
              case InsightPriority.high:
                priorityColor = AppTheme.warningColor;
                break;
              case InsightPriority.medium:
                priorityColor = AppTheme.secondaryColor;
                break;
              case InsightPriority.low:
                priorityColor = AppTheme.successColor;
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: priorityColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.description,
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (insight.potentialSaving != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Save ₹${insight.potentialSaving!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.successColor),
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

  Widget _buildPredictionSection(AnalyticsProvider analytics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'AI Predictions (Next 6 Hours)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Based on historical patterns, temperature is expected to rise by 2-3°C in the next 6 hours. '
              'Consider pre-cooling your rooms by turning on the AC 30 minutes earlier.',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), height: 1.5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPredChip('12 PM', '28°C', Colors.green),
                _buildPredChip('2 PM', '31°C', Colors.orange),
                _buildPredChip('4 PM', '33°C', Colors.red),
                _buildPredChip('6 PM', '30°C', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredChip(String time, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(time, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
      ],
    );
  }

  Widget _buildAnomalySection(AnalyticsProvider analytics) {
    if (analytics.anomalies.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: AppTheme.errorColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Anomalies Detected (${analytics.anomalies.length})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'AI has detected ${analytics.anomalies.length} anomalies in sensor readings. '
              'These could indicate sensor malfunction or unusual environmental conditions.',
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
