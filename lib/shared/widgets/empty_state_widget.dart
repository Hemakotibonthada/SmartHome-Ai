import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

/// A reusable empty-state widget shown in live mode when no real data is
/// available (e.g. no devices paired, no sensor data received).
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────
  //  Factory constructors for common empty states
  // ──────────────────────────────────────────────────────────────────

  /// No devices paired / discovered
  factory EmptyStateWidget.noDevices({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.devices_other,
      title: 'No Devices Connected',
      message: 'Pair your ESP32 or smart devices to start monitoring and controlling your home.',
      actionLabel: 'Add Device',
      onAction: onAdd,
    );
  }

  /// No sensor data available
  factory EmptyStateWidget.noSensorData() {
    return const EmptyStateWidget(
      icon: Icons.sensors_off,
      title: 'No Sensor Data',
      message: 'Connect your sensors to start receiving live readings for temperature, humidity, voltage, and more.',
    );
  }

  /// No analytics data
  factory EmptyStateWidget.noAnalytics() {
    return const EmptyStateWidget(
      icon: Icons.analytics_outlined,
      title: 'No Analytics Available',
      message: 'Analytics will appear once your devices have been running and collecting data for a while.',
    );
  }

  /// No AI insights
  factory EmptyStateWidget.noInsights() {
    return const EmptyStateWidget(
      icon: Icons.psychology_outlined,
      title: 'No AI Insights Yet',
      message: 'AI insights will be generated once sufficient sensor data has been collected from your devices.',
    );
  }

  /// No automation rules
  factory EmptyStateWidget.noAutomation({VoidCallback? onCreate}) {
    return EmptyStateWidget(
      icon: Icons.auto_fix_high,
      title: 'No Automations Set Up',
      message: 'Create automation rules to let your smart home respond intelligently to events and schedules.',
      actionLabel: 'Create Rule',
      onAction: onCreate,
    );
  }

  /// No security data
  factory EmptyStateWidget.noSecurityData() {
    return const EmptyStateWidget(
      icon: Icons.shield_outlined,
      title: 'Security Not Configured',
      message: 'Set up security devices like cameras, door locks, and motion sensors to enable the security dashboard.',
    );
  }

  /// No energy data
  factory EmptyStateWidget.noEnergyData() {
    return const EmptyStateWidget(
      icon: Icons.bolt_outlined,
      title: 'No Energy Data',
      message: 'Connect energy monitoring devices to track power consumption, costs, and efficiency.',
    );
  }

  /// Generic "connect your home" for dashboard
  factory EmptyStateWidget.connectHome({VoidCallback? onSetup}) {
    return EmptyStateWidget(
      icon: Icons.home_outlined,
      title: 'Welcome to SmartHome AI',
      message: 'Connect your smart devices to get started. You can also try Demo Mode to explore all features with simulated data.',
      actionLabel: 'Set Up Home',
      onAction: onSetup,
    );
  }

  /// No notifications
  factory EmptyStateWidget.noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      message: 'You\'re all caught up! Notifications will appear here when events are detected.',
    );
  }
}

/// A small banner widget that shows "DEMO MODE" in the UI.
class DemoBadge extends StatelessWidget {
  const DemoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_outlined,
            color: AppTheme.warningColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'DEMO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.warningColor,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
