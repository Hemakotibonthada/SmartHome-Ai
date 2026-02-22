import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/device_service.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';
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
        Provider(create: (_) => AIService()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => SmartFeaturesService()),
        ChangeNotifierProvider(create: (_) => EnergyAnalyticsService()),
        ChangeNotifierProvider(create: (_) => AdvancedHomeService()),
        ChangeNotifierProvider(create: (_) => SecurityLifestyleService()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ChangeNotifierProvider(create: (_) => SensorProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ];
}
