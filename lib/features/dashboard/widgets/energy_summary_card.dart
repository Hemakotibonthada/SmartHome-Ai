import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

class EnergySummaryCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final double power;

  const EnergySummaryCard({
    super.key,
    required this.report,
    required this.power,
  });

  @override
  Widget build(BuildContext context) {
    final daily = (report['dailyConsumption'] ?? 12.5).toDouble();
    final monthly = (report['monthlyConsumption'] ?? 350.0).toDouble();
    final cost = monthly * (report['costPerUnit'] ?? 8.0).toDouble();
    final efficiency = (report['efficiency'] ?? 75).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard,
            AppTheme.darkCardLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.warningColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Power
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Power',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: power),
                    duration: const Duration(milliseconds: 1200),
                    builder: (context, value, child) {
                      return Text(
                        '${value.toStringAsFixed(0)} W',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              // Efficiency gauge
              _buildEfficiencyGauge(efficiency),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Today',
                  '${daily.toStringAsFixed(1)} kWh',
                  Icons.today,
                  AppTheme.secondaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Monthly Est.',
                  '${monthly.toStringAsFixed(0)} kWh',
                  Icons.calendar_month,
                  AppTheme.primaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Cost Est.',
                  '₹${cost.toStringAsFixed(0)}',
                  Icons.currency_rupee,
                  AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Top Consumers
          Text(
            'Top Consumers',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          ...((report['topConsumers'] as List?)?.take(3).map((consumer) {
                return _buildConsumerBar(
                  consumer['name'] as String,
                  (consumer['percentage'] as num).toDouble(),
                  (consumer['consumption'] as num).toDouble(),
                );
              }).toList() ??
              []),
        ],
      ),
    );
  }

  Widget _buildEfficiencyGauge(int efficiency) {
    Color color;
    if (efficiency >= 80) {
      color = AppTheme.successColor;
    } else if (efficiency >= 60) {
      color = AppTheme.warningColor;
    } else {
      color = AppTheme.errorColor;
    }

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: efficiency / 100),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
          ),
          Center(
            child: Text(
              '$efficiency%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildConsumerBar(String name, double percentage, double consumption) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percentage / 100),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor.withOpacity(0.7),
                    ),
                    minHeight: 6,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${consumption}kWh',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
