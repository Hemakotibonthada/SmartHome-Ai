import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/admin/providers/admin_provider.dart';

/// AI Models Hub — shows all models, their training progress, accuracy/loss curves,
/// confusion-matrix-style metrics, and training job queue.
class AIModelsScreen extends StatefulWidget {
  const AIModelsScreen({super.key});

  @override
  State<AIModelsScreen> createState() => _AIModelsScreenState();
}

class _AIModelsScreenState extends State<AIModelsScreen> {
  String? _selectedModelId;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    if (admin.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final selectedModel = _selectedModelId != null
        ? admin.aiModels.where((m) => m.id == _selectedModelId).firstOrNull
        : null;

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Column(
        children: [
          _buildHeader(admin),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Model list + training queue
                SizedBox(
                  width: 340,
                  child: _buildLeftPanel(admin),
                ),
                // Right: Model detail / training curves
                Expanded(
                  child: selectedModel != null
                      ? _buildModelDetail(selectedModel, admin)
                      : _buildNoSelection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AdminProvider admin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Models & Training', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Monitor model performance, training progress, and efficiency metrics', style: TextStyle(fontSize: 12, color: Colors.white38)),
              ],
            ),
          ),
          _statPill('${admin.deployedModels} Deployed', AppTheme.successColor),
          const SizedBox(width: 8),
          _statPill('${admin.trainingModelsCount} Training', AppTheme.primaryColor),
          const SizedBox(width: 8),
          _statPill('Avg ${(admin.avgModelAccuracy * 100).toStringAsFixed(1)}%', AppTheme.secondaryColor),
        ],
      ),
    );
  }

  Widget _statPill(String label, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withValues(alpha: 0.25))),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }

  // ═══════════════ LEFT PANEL ═══════════════
  Widget _buildLeftPanel(AdminProvider admin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 0, 20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model List
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Models (${admin.aiModels.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: admin.aiModels.length,
              itemBuilder: (ctx, i) {
                final m = admin.aiModels[i];
                final sel = m.id == _selectedModelId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedModelId = m.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: sel ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: m.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Icon(m.typeIcon, color: m.statusColor, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Row(
                                children: [
                                  Text(m.type, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                                  const SizedBox(width: 6),
                                  Text('${(m.accuracy * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: m.statusColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: m.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(m.status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: m.statusColor, letterSpacing: 0.5)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          // Training Queue
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Training Queue (${admin.trainingJobs.length})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: admin.trainingJobs.length,
              itemBuilder: (ctx, i) {
                final j = admin.trainingJobs[i];
                final c = j.status == 'running' ? AppTheme.primaryColor : j.status == 'completed' ? AppTheme.successColor : j.status == 'failed' ? AppTheme.errorColor : AppTheme.warningColor;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: c.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(j.modelName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(j.status.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: c)),
                          ),
                        ],
                      ),
                      if (j.status == 'running') ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(value: j.progress, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation(c), minHeight: 4),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Epoch ${j.currentEpoch}/${j.totalEpochs}', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
                            Text('GPU: ${j.gpuUtilization.toStringAsFixed(0)}%', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
                            Text(j.duration, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.4))),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNoSelection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.psychology_outlined, size: 64, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 12),
          Text('Select a model to view details', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.3))),
        ],
      ),
    );
  }

  // ═══════════════ MODEL DETAIL ═══════════════
  Widget _buildModelDetail(AIModelInfo m, AdminProvider admin) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 28, 20),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildModelHeader(m, admin)),
          SliverToBoxAdapter(child: _buildMetricsRow(m)),
          SliverToBoxAdapter(child: _buildTrainingCurves(m)),
          SliverToBoxAdapter(child: _buildModelInfo(m)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildModelHeader(AIModelInfo m, AdminProvider admin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: m.statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(m.typeIcon, color: m.statusColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(m.description, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (m.status != 'training')
                ElevatedButton.icon(
                  onPressed: () => admin.startModelTraining(m.id),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Retrain', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              if (m.status == 'training')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(value: m.trainingProgress, strokeWidth: 2, color: AppTheme.primaryColor)),
                      const SizedBox(width: 8),
                      Text('${(m.trainingProgress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
            ],
          ),
          if (m.status == 'training') ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: m.trainingProgress, minHeight: 6, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor)),
            ),
            const SizedBox(height: 6),
            Text('Epoch ${m.epochsCurrent} / ${m.epochsTotal}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsRow(AIModelInfo m) {
    final metrics = [
      _Metric('Accuracy', '${(m.accuracy * 100).toStringAsFixed(1)}%', AppTheme.successColor),
      _Metric('Loss', m.loss.toStringAsFixed(4), AppTheme.errorColor),
      _Metric('F1 Score', m.f1Score.toStringAsFixed(3), AppTheme.primaryColor),
      _Metric('Precision', '${(m.precision * 100).toStringAsFixed(1)}%', AppTheme.secondaryColor),
      _Metric('Recall', '${(m.recall * 100).toStringAsFixed(1)}%', AppTheme.warningColor),
      _Metric('Latency', m.latency, const Color(0xFF2196F3)),
      _Metric('Inferences', _fmtNum(m.inferenceCount), const Color(0xFF9C27B0)),
      _Metric('Model Size', m.modelSize, Colors.white54),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: metrics.map((mt) => Container(
          width: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mt.label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
              const SizedBox(height: 4),
              Text(mt.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mt.color)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ═══════════════ TRAINING CURVES ═══════════════
  Widget _buildTrainingCurves(AIModelInfo m) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildCurveCard('Accuracy Curve', m.accuracyHistory, m.valAccuracyHistory, 'Train Acc', 'Val Acc', AppTheme.primaryColor, AppTheme.secondaryColor, 0, 1)),
          const SizedBox(width: 14),
          Expanded(child: _buildCurveCard('Loss Curve', m.lossHistory, m.valLossHistory, 'Train Loss', 'Val Loss', AppTheme.errorColor, AppTheme.warningColor, null, null)),
        ],
      ),
    );
  }

  Widget _buildCurveCard(String title, List<double> data1, List<double> data2, String label1, String label2, Color c1, Color c2, double? minY, double? maxY) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              _curveLegend(label1, c1),
              const SizedBox(width: 10),
              _curveLegend(label2, c2),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY != null ? 0.2 : null, getDrawingHorizontalLine: (_) => FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, _) => Text(v.toStringAsFixed(2), style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3))))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, interval: (data1.length / 5).ceilToDouble().clamp(1, 100), getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.25))))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  _curveLine(data1, c1),
                  _curveLine(data2, c2),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                      'Epoch ${s.x.toInt()}: ${s.y.toStringAsFixed(4)}',
                      TextStyle(fontSize: 10, color: s.bar.color ?? Colors.white),
                    )).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _curveLine(List<double> data, Color c) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      curveSmoothness: 0.2,
      color: c,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: c.withValues(alpha: 0.05)),
    );
  }

  Widget _curveLegend(String l, Color c) {
    return Row(children: [
      Container(width: 8, height: 3, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(1))),
      const SizedBox(width: 4),
      Text(l, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
    ]);
  }

  // ═══════════════ MODEL INFO ═══════════════
  Widget _buildModelInfo(AIModelInfo m) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Model Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 14),
            _detailRow('Framework', m.framework),
            _detailRow('Model Size', m.modelSize),
            _detailRow('Dataset', m.datasetSize),
            _detailRow('Epochs', '${m.epochsCurrent} / ${m.epochsTotal}'),
            _detailRow('Last Trained', _timeAgo(m.lastTrained)),
            _detailRow('Total Inferences', _fmtNum(m.inferenceCount)),
            _detailRow('Inference Latency', m.latency),
            _detailRow('Type', m.type),
            _detailRow('Status', m.status.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(l, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70))),
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

class _Metric {
  final String label, value;
  final Color color;
  const _Metric(this.label, this.value, this.color);
}
