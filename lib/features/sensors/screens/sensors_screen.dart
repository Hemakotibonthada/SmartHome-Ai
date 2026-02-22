import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/shared/widgets/web_content_wrapper.dart';
import 'package:smart_home_ai/shared/widgets/empty_state_widget.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/features/sensors/providers/sensor_provider.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _timeRanges = ['1h', '6h', '24h', '7d', '30d'];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sensorProvider = context.watch<SensorProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: sensorProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : !sensorProvider.hasData && !context.watch<DemoModeService>().isDemoMode
                  ? EmptyStateWidget.noSensorData()
                  : CustomScrollView(
                  physics: WebContentWrapper.scrollPhysics,
                  slivers: [
                    // Header
                    SliverToBoxAdapter(child: _buildHeader()),

                    // Sensor Type Selector
                    SliverToBoxAdapter(child: _buildSensorTypeSelector(sensorProvider)),

                    // Live Value Card
                    SliverToBoxAdapter(
                      child: _buildLiveValueCard(sensorProvider),
                    ),

                    // Time Range Selector
                    SliverToBoxAdapter(
                      child: _buildTimeRangeSelector(sensorProvider),
                    ),

                    // Chart
                    SliverToBoxAdapter(
                      child: _buildChart(sensorProvider),
                    ),

                    // Stats Cards
                    SliverToBoxAdapter(
                      child: _buildStatsRow(sensorProvider),
                    ),

                    // All Sensors Grid
                    SliverToBoxAdapter(
                      child: _buildAllSensorsSection(sensorProvider),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
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
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sensors, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sensor Monitor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Real-time sensor data & trends',
                style: TextStyle(fontSize: 12, color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTypeSelector(SensorProvider provider) {
    final sensorTypes = [
      SensorType.temperature,
      SensorType.humidity,
      SensorType.voltage,
      SensorType.current,
      SensorType.power,
      SensorType.waterLevel,
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sensorTypes.length,
        itemBuilder: (context, index) {
          final type = sensorTypes[index];
          final isSelected = provider.selectedSensor == type;

          return GestureDetector(
            onTap: () => provider.setSelectedSensor(type),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? type.color.withOpacity(0.2)
                    : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? type.color.withOpacity(0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(type.icon, color: isSelected ? type.color : Colors.white38, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? type.color : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveValueCard(SensorProvider provider) {
    final type = provider.selectedSensor;
    final reading = provider.currentReadings[type.name];
    final color = type.color;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // Animated gauge
            SizedBox(
              width: 100,
              height: 100,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: reading?.normalizedValue ?? 0.5),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return CustomPaint(
                    painter: GaugePainter(
                      value: value,
                      color: color,
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                    child: Center(
                      child: Icon(type.icon, color: color, size: 28),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: reading?.value ?? 0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(1)} ${type.unit}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      );
                    },
                  ),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMinMaxChip('Min', reading?.minThreshold ?? 0, color),
                      const SizedBox(width: 8),
                      _buildMinMaxChip('Max', reading?.maxThreshold ?? 100, color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinMaxChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(0)}',
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTimeRangeSelector(SensorProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _timeRanges.map((range) {
          final isSelected = provider.selectedTimeRange == range;
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setTimeRange(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.5)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  range,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppTheme.primaryColor : Colors.white38,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(SensorProvider provider) {
    final data = provider.currentSensorHistory;
    final color = provider.selectedSensor.color;

    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data', style: TextStyle(color: Colors.white38))),
      );
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final minY = data.map((d) => d.value).reduce((a, b) => a < b ? a : b) - 5;
    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b) + 5;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 250,
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.white.withOpacity(0.05),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: (maxY - minY) / 4,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots.length > 200 
                    ? spots.where((s) => s.x % 3 == 0).toList()
                    : spots,
                isCurved: true,
                color: color,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} ${provider.selectedSensor.unit}',
                      TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  Widget _buildStatsRow(SensorProvider provider) {
    final data = provider.currentSensorHistory;
    if (data.isEmpty) return const SizedBox.shrink();

    final values = data.map((d) => d.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final unit = provider.selectedSensor.unit;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Average', '${avg.toStringAsFixed(1)} $unit', Icons.analytics, AppTheme.primaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatCard('Min', '${minVal.toStringAsFixed(1)} $unit', Icons.arrow_downward, AppTheme.secondaryColor)),
          const SizedBox(width: 8),
          Expanded(child: _buildStatCard('Max', '${maxVal.toStringAsFixed(1)} $unit', Icons.arrow_upward, AppTheme.accentColor)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
        ],
      ),
    );
  }

  Widget _buildAllSensorsSection(SensorProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Sensor Readings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ...provider.currentReadings.entries.map((entry) {
            final sensor = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sensor.type.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(sensor.type.icon, color: sensor.type.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sensor.type.displayName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text('Device: ${sensor.deviceId}',
                            style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3))),
                      ],
                    ),
                  ),
                  Text(
                    sensor.formattedValue,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: sensor.type.color,
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
}

class GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;

  GaugePainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 * 0.75,
      3.14 * 1.5,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 * 0.75,
      3.14 * 1.5 * value.clamp(0, 1),
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
