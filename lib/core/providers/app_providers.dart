import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/device_service.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/core/services/ai_prediction_engine.dart';
import 'package:smart_home_ai/core/services/ai_anomaly_engine.dart';
import 'package:smart_home_ai/core/services/ai_nlp_engine.dart';
import 'package:smart_home_ai/core/services/ai_vision_engine.dart';
import 'package:smart_home_ai/core/services/ai_learning_engine.dart';
import 'package:smart_home_ai/core/services/ai_automation_engine.dart';
import 'package:smart_home_ai/core/services/ai_health_engine.dart';
import 'package:smart_home_ai/core/services/ai_security_engine.dart';
import 'package:smart_home_ai/core/services/ai_advanced_analytics.dart';
import 'package:smart_home_ai/core/services/notification_service.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';
import 'package:smart_home_ai/core/services/energy_analytics_service.dart';
import 'package:smart_home_ai/core/services/advanced_home_service.dart';
import 'package:smart_home_ai/core/services/security_lifestyle_service.dart';
import 'package:smart_home_ai/features/dashboard/providers/dashboard_provider.dart';
import 'package:smart_home_ai/features/devices/providers/device_provider.dart';
import 'package:smart_home_ai/features/sensors/providers/sensor_provider.dart';
import 'package:smart_home_ai/features/analytics/providers/analytics_provider.dart';
import 'package:smart_home_ai/features/admin/providers/admin_provider.dart';
import 'package:smart_home_ai/features/auth/providers/auth_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    // Create the central demo-mode service
    final demoModeService = DemoModeService();

    // Create the auth provider and link it to demo-mode service
    final authProvider = AuthProvider()..setDemoModeService(demoModeService);

    // Create all data services
    final smartFeaturesService = SmartFeaturesService();
    final energyAnalyticsService = EnergyAnalyticsService();
    final advancedHomeService = AdvancedHomeService();
    final securityLifestyleService = SecurityLifestyleService();

    // Create all data providers
    final dashboardProvider = DashboardProvider();
    final deviceProvider = DeviceProvider();
    final sensorProvider = SensorProvider();
    final analyticsProvider = AnalyticsProvider();
    final adminProvider = AdminProvider();

    // Listen to demo-mode changes and propagate to all services/providers
    demoModeService.addListener(() {
      final isDemo = demoModeService.isDemoMode;

      // Propagate to services
      smartFeaturesService.setDemoMode(isDemo);
      energyAnalyticsService.setDemoMode(isDemo);
      advancedHomeService.setDemoMode(isDemo);
      securityLifestyleService.setDemoMode(isDemo);

      // Propagate to providers
      dashboardProvider.setDemoMode(isDemo);
      deviceProvider.setDemoMode(isDemo);
      sensorProvider.setDemoMode(isDemo);
      analyticsProvider.setDemoMode(isDemo);
      adminProvider.setDemoMode(isDemo);
    });

    return [
      ChangeNotifierProvider.value(value: demoModeService),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider.value(value: authProvider),
      Provider(create: (_) => DeviceService()),
      ChangeNotifierProvider(create: (_) => AIService()),
      Provider(create: (_) => NotificationService()),
      ChangeNotifierProvider.value(value: smartFeaturesService),
      ChangeNotifierProvider.value(value: energyAnalyticsService),
      ChangeNotifierProvider.value(value: advancedHomeService),
      ChangeNotifierProvider.value(value: securityLifestyleService),
      // AI Engines — 100 AI Features
      ChangeNotifierProvider(create: (_) => AIPredictionEngine()),
      ChangeNotifierProvider(create: (_) => AIAnomalyEngine()),
      ChangeNotifierProvider(create: (_) => AINLPEngine()),
      ChangeNotifierProvider(create: (_) => AIVisionEngine()),
      ChangeNotifierProvider(create: (_) => AILearningEngine()),
      ChangeNotifierProvider(create: (_) => AIAutomationEngine()),
      ChangeNotifierProvider(create: (_) => AIHealthEngine()),
      ChangeNotifierProvider(create: (_) => AISecurityEngine()),
      ChangeNotifierProvider(create: (_) => AIAdvancedAnalytics()),
      ChangeNotifierProvider.value(value: dashboardProvider),
      ChangeNotifierProvider.value(value: deviceProvider),
      ChangeNotifierProvider.value(value: sensorProvider),
      ChangeNotifierProvider.value(value: analyticsProvider),
      ChangeNotifierProvider.value(value: adminProvider),
    ];
  }
}
