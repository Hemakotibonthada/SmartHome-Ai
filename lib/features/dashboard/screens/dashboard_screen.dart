import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/shared/widgets/web_content_wrapper.dart';
import 'package:smart_home_ai/shared/widgets/hover_card.dart';
import 'package:smart_home_ai/shared/widgets/empty_state_widget.dart';
import 'package:smart_home_ai/core/models/sensor_data.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';
import 'package:smart_home_ai/core/services/energy_analytics_service.dart';
import 'package:smart_home_ai/features/dashboard/providers/dashboard_provider.dart';
import 'package:smart_home_ai/features/auth/providers/auth_provider.dart';
import 'package:smart_home_ai/features/dashboard/widgets/sensor_card.dart';
import 'package:smart_home_ai/features/dashboard/widgets/quick_action_card.dart';
import 'package:smart_home_ai/features/dashboard/widgets/energy_summary_card.dart';
import 'package:smart_home_ai/features/dashboard/widgets/water_tank_widget.dart';
import 'package:smart_home_ai/features/dashboard/widgets/insight_card.dart';
import 'package:smart_home_ai/features/admin/screens/admin_web_shell.dart';
import 'package:smart_home_ai/features/notifications/screens/notifications_screen.dart';
import 'package:smart_home_ai/features/scenes/screens/scenes_screen.dart';
import 'package:smart_home_ai/features/energy/screens/energy_details_screen.dart';
import 'package:smart_home_ai/features/safety/screens/safety_center_screen.dart';
import 'package:smart_home_ai/features/rooms/screens/room_map_screen.dart';
import 'package:smart_home_ai/features/activity/screens/activity_log_screen.dart';
import 'package:smart_home_ai/features/maintenance/screens/maintenance_screen.dart';
import 'package:smart_home_ai/features/suggestions/screens/smart_suggestions_screen.dart';
import 'package:smart_home_ai/features/export/screens/data_export_screen.dart';
import 'package:smart_home_ai/features/devices/screens/device_hub_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/ai_hub_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/lifestyle_hub_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/security_dashboard_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/system_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dashboard = context.watch<DashboardProvider>();
    final auth = context.read<AuthProvider>();
    final demoMode = context.watch<DemoModeService>();
    final smartSvc = context.watch<SmartFeaturesService>();
    final energySvc = context.read<EnergyAnalyticsService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.darkGradient,
        ),
        child: SafeArea(
          child: dashboard.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
              : !dashboard.hasData && !demoMode.isDemoMode
                  ? _buildLiveEmptyState(context, demoMode)
                  : RefreshIndicator(
                  onRefresh: () => dashboard.loadData(),
                  color: AppTheme.primaryColor,
                  child: CustomScrollView(
                    physics: WebContentWrapper.scrollPhysics,
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: _buildAppBar(auth, dashboard),
                      ),

                      // Status Cards Row
                      SliverToBoxAdapter(
                        child: _buildStatusRow(dashboard),
                      ),

                      // Comfort & Air Quality Row
                      SliverToBoxAdapter(
                        child: _buildComfortAirQualityRow(smartSvc),
                      ),

                      // Active Scene Banner
                      SliverToBoxAdapter(
                        child: _buildActiveSceneBanner(smartSvc),
                      ),

                      // Quick Routines
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Quick Routines', Icons.play_circle),
                      ),
                      SliverToBoxAdapter(
                        child: _buildQuickRoutines(smartSvc),
                      ),

                      // Feature Hub Grid
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Feature Hub', Icons.apps),
                      ),
                      SliverToBoxAdapter(
                        child: _buildFeatureHub(),
                      ),

                      // Sensor Readings Section
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Live Sensor Readings', Icons.sensors),
                      ),
                      SliverToBoxAdapter(
                        child: _buildSensorGrid(dashboard),
                      ),

                      // Door & Window Quick Status
                      SliverToBoxAdapter(
                        child: _buildDoorWindowQuickStatus(smartSvc),
                      ),

                      // Water Tank
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Water Tank Level', Icons.water),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: WaterTankWidget(
                            level: dashboard.sensorData['waterLevel']?.value ?? 65,
                          ),
                        ),
                      ),

                      // Energy Summary
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Energy Overview', Icons.bolt),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: EnergySummaryCard(
                            report: dashboard.energyReport,
                            power: dashboard.sensorData['power']?.value ?? 0,
                          ),
                        ),
                      ),

                      // Savings Tracker
                      if (energySvc.savingsData != null)
                        SliverToBoxAdapter(
                          child: _buildSavingsTracker(energySvc),
                        ),

                      // Quick Actions
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('Quick Actions', Icons.flash_on),
                      ),
                      SliverToBoxAdapter(
                        child: _buildQuickActions(),
                      ),

                      // Favorites
                      if (smartSvc.favorites.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildSectionTitle('Favorites', Icons.favorite),
                        ),
                      if (smartSvc.favorites.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildFavorites(smartSvc),
                        ),

                      // AI Insights
                      SliverToBoxAdapter(
                        child: _buildSectionTitle('AI Insights & Suggestions', Icons.auto_awesome),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= dashboard.insights.length) return null;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: InsightCard(
                                insight: dashboard.insights[index],
                                index: index,
                              ),
                            );
                          },
                          childCount: dashboard.insights.length.clamp(0, 5),
                        ),
                      ),

                      // Maintenance Alerts
                      SliverToBoxAdapter(
                        child: _buildMaintenanceAlerts(smartSvc),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAppBar(AuthProvider auth, DashboardProvider dashboard) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome home,',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    if (context.watch<DemoModeService>().isDemoMode) ...[
                      const SizedBox(width: 8),
                      const DemoBadge(),
                    ],
                  ],
                ),
                Text(
                  auth.user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Admin Button
          if (auth.user?.isAdmin ?? false)
            _buildIconButton(
              Icons.admin_panel_settings,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminWebShell(),
                  ),
                );
              },
              color: AppTheme.warningColor,
            ),
          const SizedBox(width: 8),
          // Notifications
          Stack(
            children: [
              _buildIconButton(
                Icons.notifications_outlined,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.darkSurface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        hoverColor: (color ?? AppTheme.primaryColor).withValues(alpha: 0.08),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Icon(icon, color: color ?? Colors.white70, size: 22),
        ),
      ),
    );
  }

  Widget _buildStatusRow(DashboardProvider dashboard) {
    final isDesktop = Responsive.isDesktop(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'Devices',
              '${dashboard.activeDevices}/${dashboard.totalDevices}',
              Icons.devices_other,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'Energy',
              '${dashboard.energyToday.toStringAsFixed(1)} kWh',
              Icons.bolt,
              AppTheme.warningColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'Alerts',
              '${dashboard.alertCount}',
              Icons.warning_amber,
              dashboard.alertCount > 0 ? AppTheme.errorColor : AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid(DashboardProvider dashboard) {
    final sensors = [
      dashboard.sensorData['temperature'],
      dashboard.sensorData['humidity'],
      dashboard.sensorData['voltage'],
      dashboard.sensorData['current'],
    ].whereType<SensorData>().toList();

    final cols = Responsive.isDesktop(context) ? 4 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RepaintBoundary(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: sensors.length,
          itemBuilder: (context, index) {
            return SensorCard(
              sensor: sensors[index],
              index: index,
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.lightbulb, 'label': 'All Lights', 'color': const Color(0xFFFFE66D), 'isOn': true},
      {'icon': Icons.ac_unit, 'label': 'AC', 'color': const Color(0xFF00D9FF), 'isOn': false},
      {'icon': Icons.lock, 'label': 'Lock', 'color': const Color(0xFF00C48C), 'isOn': true},
      {'icon': Icons.notifications_active, 'label': 'Buzzer', 'color': const Color(0xFFFF6584), 'isOn': false},
      {'icon': Icons.water, 'label': 'Pump', 'color': const Color(0xFF667EEA), 'isOn': false},
      {'icon': Icons.videocam, 'label': 'Cameras', 'color': const Color(0xFFFF4757), 'isOn': true},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return QuickActionCard(
            icon: action['icon'] as IconData,
            label: action['label'] as String,
            color: action['color'] as Color,
            isOn: action['isOn'] as bool,
            onTap: () {},
          );
        },
      ),
    );
  }

  // ===== NEW FEATURE WIDGETS =====

  Widget _buildComfortAirQualityRow(SmartFeaturesService svc) {
    final comfort = svc.comfortIndex;
    final aq = svc.airQuality;
    if (comfort == null || aq == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomMapScreen())),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: comfort.scoreColor.withValues(alpha: 0.2))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.thermostat_auto, color: comfort.scoreColor, size: 16),
                        const SizedBox(width: 6),
                        Text('Comfort', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${comfort.score}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: comfort.scoreColor)),
                    Text(comfort.level, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyCenterScreen())),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: aq.levelColor.withValues(alpha: 0.2))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.air, color: aq.levelColor, size: 16),
                        const SizedBox(width: 6),
                        Text('Air Quality', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${aq.aqi}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: aq.levelColor)),
                    Text(aq.level, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSceneBanner(SmartFeaturesService svc) {
    final active = svc.scenes.where((s) => s.isActive).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScenesScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.15), const Color(0xFF00D9FF).withValues(alpha: 0.08)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(active.first.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active: ${active.first.name}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('${active.first.actions.length} devices controlled', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoutines(SmartFeaturesService svc) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: svc.routines.length,
        itemBuilder: (ctx, i) {
          final r = svc.routines[i];
          return GestureDetector(
            onTap: () => svc.executeRoutine(r.id),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(r.icon, color: r.color, size: 22),
                  const SizedBox(height: 6),
                  Text(r.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureHub() {
    final features = [
      _FeatureItem('Scenes', Icons.theater_comedy, const Color(0xFF9C27B0), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScenesScreen()))),
      _FeatureItem('Energy', Icons.bolt, const Color(0xFF4CAF50), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyDetailsScreen()))),
      _FeatureItem('Safety', Icons.shield, const Color(0xFFF44336), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyCenterScreen()))),
      _FeatureItem('Rooms', Icons.map, const Color(0xFF2196F3), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomMapScreen()))),
      _FeatureItem('Activity', Icons.history, const Color(0xFFFF9800), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityLogScreen()))),
      _FeatureItem('Maintain', Icons.build, const Color(0xFF795548), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen()))),
      _FeatureItem('AI Tips', Icons.auto_awesome, AppTheme.primaryColor, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SmartSuggestionsScreen()))),
      _FeatureItem('Export', Icons.download, const Color(0xFF607D8B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataExportScreen()))),
      _FeatureItem('Devices', Icons.devices_other, const Color(0xFF00BCD4), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceHubScreen()))),
      _FeatureItem('AI Hub', Icons.psychology, const Color(0xFF9C27B0), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIHubScreen()))),
      _FeatureItem('Lifestyle', Icons.spa, const Color(0xFF4CAF50), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LifestyleHubScreen()))),
      _FeatureItem('Security', Icons.security, const Color(0xFFF44336), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityDashboardScreen()))),
      _FeatureItem('System', Icons.settings_suggest, const Color(0xFF607D8B), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemManagementScreen()))),
    ];

    final cols = Responsive.isWideDesktop(context) ? 6 : Responsive.isDesktop(context) ? 5 : 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RepaintBoundary(
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (ctx, i) {
            final f = features[i];
            return HoverCard(
              onTap: f.onTap,
              borderColor: f.color.withValues(alpha: 0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: f.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(f.icon, color: f.color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(f.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white70), textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDoorWindowQuickStatus(SmartFeaturesService svc) {
    final openCount = svc.doorWindowStatus.where((d) => d.isOpen).length;
    final unlockedCount = svc.doorWindowStatus.where((d) => !d.isLocked).length;
    if (openCount == 0 && unlockedCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyCenterScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9800).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.door_front_door, color: Color(0xFFFF9800), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${openCount > 0 ? "$openCount open" : ""}${openCount > 0 && unlockedCount > 0 ? " • " : ""}${unlockedCount > 0 ? "$unlockedCount unlocked" : ""}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFFFF9800), fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFFF9800), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingsTracker(EnergyAnalyticsService energySvc) {
    final savings = energySvc.savingsData!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyDetailsScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF4CAF50).withValues(alpha: 0.1), const Color(0xFF4CAF50).withValues(alpha: 0.02)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.savings, color: Color(0xFF4CAF50), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹${savings.totalSaved.toStringAsFixed(0)} saved', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                    Text('${savings.streakDays} day streak 🔥', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavorites(SmartFeaturesService svc) {
    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: svc.favorites.length,
        itemBuilder: (ctx, i) {
          final fav = svc.favorites[i];
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFF44336), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(fav.name, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaintenanceAlerts(SmartFeaturesService svc) {
    final overdue = svc.maintenanceTasks.where((t) => t.isOverdue).toList();
    if (overdue.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF44336).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF44336).withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.build_circle, color: Color(0xFFF44336), size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('${overdue.length} maintenance task${overdue.length > 1 ? "s" : ""} overdue',
                style: const TextStyle(fontSize: 13, color: Color(0xFFF44336), fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right, color: Color(0xFFF44336), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveEmptyState(BuildContext context, DemoModeService demoMode) {
    return CustomScrollView(
      physics: WebContentWrapper.scrollPhysics,
      slivers: [
        SliverToBoxAdapter(
          child: _buildAppBar(context.read<AuthProvider>(), context.read<DashboardProvider>()),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateWidget.connectHome(
            onSetup: () {
              // Switch to demo mode to explore features
              demoMode.enableDemoMode();
            },
          ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _FeatureItem(this.label, this.icon, this.color, this.onTap);
}
