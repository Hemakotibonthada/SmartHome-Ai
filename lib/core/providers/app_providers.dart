import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/device_service.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';
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
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => DeviceService()),
        ChangeNotifierProvider(create: (_) => AIService()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => SmartFeaturesService()),
        ChangeNotifierProvider(create: (_) => EnergyAnalyticsService()),
        ChangeNotifierProvider(create: (_) => AdvancedHomeService()),
        ChangeNotifierProvider(create: (_) => SecurityLifestyleService()),
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
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ];
}
