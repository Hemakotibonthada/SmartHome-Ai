import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/features/auth/screens/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _navSolid = false;

  // Section keys for smooth-scroll navigation
  final _featuresKey = GlobalKey();
  final _devicesKey = GlobalKey();
  final _pricingKey = GlobalKey();
  final _aboutKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final solid = _scrollController.offset > 60;
    if (solid != _navSolid) setState(() => _navSolid = solid);
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: RepaintBoundary(child: _buildHeroSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: _buildStatsBar(isDesktop)),
              SliverToBoxAdapter(child: RepaintBoundary(key: _featuresKey, child: _buildFeaturesSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: RepaintBoundary(key: _devicesKey, child: _buildDevicesSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: RepaintBoundary(child: _buildHowItWorksSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: RepaintBoundary(child: _buildTestimonialsSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: RepaintBoundary(key: _pricingKey, child: _buildPricingSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: RepaintBoundary(key: _aboutKey, child: _buildAboutSection(isDesktop, isMobile))),
              SliverToBoxAdapter(child: _buildFooter(isDesktop, isMobile)),
            ],
          ),
          // Floating nav bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: RepaintBoundary(child: _buildNavBar(isDesktop, isMobile)),
          ),
        ],
      ),
    );
  }

  // ===================== NAV BAR =====================
  Widget _buildNavBar(bool isDesktop, bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _navSolid
            ? const Color(0xFF0A0E21).withValues(alpha: 0.95)
            : Colors.transparent,
        boxShadow: _navSolid
            ? [BoxShadow(color: Colors.black26, blurRadius: 12)]
            : [],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'SmartHome AI',
                  style: TextStyle(
                    color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w700, letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isDesktop) ...[
              _navLink('Features', () => _scrollTo(_featuresKey)),
              _navLink('Devices', () => _scrollTo(_devicesKey)),
              _navLink('Pricing', () => _scrollTo(_pricingKey)),
              _navLink('About', () => _scrollTo(_aboutKey)),
              const SizedBox(width: 16),
            ],
            // CTA buttons
            if (!isMobile) ...[
              TextButton(
                onPressed: _goToLogin,
                child: const Text('Sign In',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 8),
            ],
            ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 8 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isMobile ? 'Start' : 'Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextButton(
        onPressed: onTap,
        child: Text(label,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }

  // ===================== HERO =====================
  Widget _buildHeroSection(bool isDesktop, bool isMobile) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 700 : 800),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E21), Color(0xFF15193A), Color(0xFF1A1F3A)],
        ),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: isDesktop ? 80 : -50,
            top: isDesktop ? 120 : 400,
            child: _buildHeroVisual(isDesktop, isMobile),
          ),
          // Glow effects
          Positioned(
            left: -100, top: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -80, bottom: 80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryColor.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 80 : 24,
            ),
            child: Column(
              crossAxisAlignment: isDesktop
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                SizedBox(height: isDesktop ? 180 : 140),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI-Powered Smart Home • 2026',
                        style: TextStyle(color: AppTheme.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Headline
                SizedBox(
                  width: isDesktop ? 620 : double.infinity,
                  child: Text(
                    'Your Home,\nIntelligently\nConnected.',
                    textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 36 : isDesktop ? 62 : 48,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: isDesktop ? 480 : double.infinity,
                  child: Text(
                    'Control 50+ device types with AI automation, real-time monitoring, '
                    'voice commands, and predictive intelligence — all from one beautiful dashboard.',
                    textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: isMobile ? 15 : 17,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // CTA
                Wrap(
                  alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: _goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 28 : 36,
                          vertical: isMobile ? 14 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Get Started Free',
                            style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                          vertical: isMobile ? 14 : 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_circle_outline, size: 20, color: AppTheme.secondaryColor),
                          const SizedBox(width: 8),
                          Text('Watch Demo',
                              style: TextStyle(fontSize: isMobile ? 15 : 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // Trust bar
                Wrap(
                  alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _trustItem(Icons.shield_rounded, '256-bit Encryption'),
                    _trustItem(Icons.devices_rounded, '50+ Device Types'),
                    _trustItem(Icons.speed_rounded, '<50ms Response'),
                  ],
                ),
                SizedBox(height: isMobile ? 40 : 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.successColor),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  Widget _buildHeroVisual(bool isDesktop, bool isMobile) {
    if (isMobile) return const SizedBox.shrink();
    final size = isDesktop ? 420.0 : 300.0;
    return RepaintBoundary(
      child: SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1), width: 2),
            ),
          ),
          // Inner ring
          Container(
            width: size * 0.7, height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.15), width: 2),
            ),
          ),
          // Center hub
          Container(
            width: size * 0.35, height: size * 0.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.25),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(Icons.home_rounded, size: size * 0.12, color: AppTheme.primaryColor),
          ),
          // Orbiting icons
          ..._orbitIcons(size),
        ],
      ),
      ),
    );
  }

  List<Widget> _orbitIcons(double size) {
    final icons = [
      (Icons.lightbulb_outline, AppTheme.warningColor, 0.0),
      (Icons.thermostat, AppTheme.errorColor, 0.8),
      (Icons.lock_outline, AppTheme.successColor, 1.6),
      (Icons.videocam_outlined, AppTheme.secondaryColor, 2.4),
      (Icons.music_note, AppTheme.accentColor, 3.2),
      (Icons.bolt, AppTheme.warningColor, 4.0),
      (Icons.water_drop_outlined, const Color(0xFF4FACFE), 4.8),
      (Icons.sensors, AppTheme.primaryColor, 5.6),
    ];
    return icons.map((e) {
      final (icon, color, angle) = e;
      final radius = size * 0.42;
      final dx = radius * _cos(angle);
      final dy = radius * _sin(angle);
      return Positioned(
        left: size / 2 + dx - 20,
        top: size / 2 + dy - 20,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      );
    }).toList();
  }

  double _cos(double a) => _trigCos(a);
  double _sin(double a) => _trigSin(a);
  static double _trigCos(double a) {
    // Simple cosine approximation (avoiding dart:math import here)
    // We'll use pre-computed positions
    const values = [1.0, 0.697, -0.03, -0.74, -1.0, -0.65, 0.09, 0.78];
    return values[(a ~/ 0.8).clamp(0, 7)];
  }
  static double _trigSin(double a) {
    const values = [0.0, 0.72, 1.0, 0.67, -0.08, -0.76, -1.0, -0.63];
    return values[(a ~/ 0.8).clamp(0, 7)];
  }

  // ===================== STATS BAR =====================
  Widget _buildStatsBar(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF111638),
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: isDesktop ? 80 : 24,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 40,
        runSpacing: 20,
        children: [
          _statItem('10K+', 'Active Homes'),
          _statItem('150+', 'Features'),
          _statItem('50+', 'Device Types'),
          _statItem('99.9%', 'Uptime'),
          _statItem('4.9★', 'Rating'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  // ===================== FEATURES =====================
  Widget _buildFeaturesSection(bool isDesktop, bool isMobile) {
    final features = [
      _FeatureData(Icons.psychology_rounded, 'AI Automation', AppTheme.primaryColor,
          'Machine learning adapts to your habits and automates your home intelligently.'),
      _FeatureData(Icons.bolt_rounded, 'Energy Analytics', AppTheme.warningColor,
          'Real-time energy monitoring, solar tracking, and smart cost optimization.'),
      _FeatureData(Icons.security_rounded, 'Smart Security', AppTheme.errorColor,
          'Face recognition, intruder detection, panic button & perimeter monitoring.'),
      _FeatureData(Icons.thermostat_rounded, 'Climate Control', AppTheme.secondaryColor,
          'Multi-zone HVAC, circadian lighting, and weather-adaptive automation.'),
      _FeatureData(Icons.health_and_safety_rounded, 'Wellness Hub', AppTheme.successColor,
          'Sleep tracking, air quality, stress monitoring & workout environments.'),
      _FeatureData(Icons.recycling_rounded, 'Sustainability', const Color(0xFF4CAF50),
          'Carbon tracking, rainwater harvesting, green energy scoring & audits.'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0E21), Color(0xFF0D1229)],
        ),
      ),
      child: Column(
        children: [
          _sectionTag('FEATURES'),
          const SizedBox(height: 16),
          Text(
            'Everything You Need',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 500,
            child: Text(
              'From intelligent automation to advanced security, all your smart home needs in one platform.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: isMobile ? 14 : 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 56),
          _responsiveGrid(
            isDesktop: isDesktop,
            isMobile: isMobile,
            children: features.map((f) => _featureCard(f)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(_FeatureData data) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 26),
          ),
          const SizedBox(height: 20),
          Text(data.title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(data.description,
              style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  // ===================== DEVICES =====================
  Widget _buildDevicesSection(bool isDesktop, bool isMobile) {
    final devices = [
      (Icons.lightbulb_outline, 'Smart Lights', AppTheme.warningColor),
      (Icons.thermostat, 'Thermostats', AppTheme.errorColor),
      (Icons.lock_outline, 'Door Locks', AppTheme.successColor),
      (Icons.videocam_outlined, 'Cameras', AppTheme.secondaryColor),
      (Icons.speaker, 'Speakers', AppTheme.accentColor),
      (Icons.blinds, 'Smart Blinds', AppTheme.primaryColor),
      (Icons.cleaning_services, 'Robot Vacuums', const Color(0xFFFF6B6B)),
      (Icons.kitchen, 'Smart Oven', AppTheme.warningColor),
      (Icons.local_laundry_service, 'Washer/Dryer', const Color(0xFF4FACFE)),
      (Icons.garage, 'Garage Door', const Color(0xFFFF9800)),
      (Icons.grass, 'Sprinklers', AppTheme.successColor),
      (Icons.pets, 'Pet Feeder', AppTheme.accentColor),
      (Icons.child_care, 'Baby Monitor', const Color(0xFFE91E63)),
      (Icons.ev_station, 'EV Charger', const Color(0xFF00C48C)),
      (Icons.air, 'Air Purifier', const Color(0xFF4FACFE)),
      (Icons.pool, 'Pool Controller', AppTheme.secondaryColor),
      (Icons.doorbell, 'Doorbell', AppTheme.warningColor),
      (Icons.solar_power, 'Solar Inverter', const Color(0xFFFFD600)),
      (Icons.battery_charging_full, 'Battery Storage', AppTheme.successColor),
      (Icons.water_drop, 'Water Heater', const Color(0xFF4FACFE)),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 24,
      ),
      color: const Color(0xFF0D1229),
      child: Column(
        children: [
          _sectionTag('COMPATIBLE DEVICES'),
          const SizedBox(height: 16),
          Text(
            '50+ Device Types Supported',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 500,
            child: Text(
              'Connect virtually every smart device in your home to one unified platform.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: isMobile ? 14 : 16, height: 1.5),
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: devices.map((d) {
              final (icon, label, color) = d;
              return Container(
                width: isMobile ? 90 : 110,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.12)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('...and 30+ more device types',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ===================== HOW IT WORKS =====================
  Widget _buildHowItWorksSection(bool isDesktop, bool isMobile) {
    final steps = [
      ('01', 'Connect', 'Plug in your smart devices and pair them via WiFi, Bluetooth, or Zigbee.', Icons.wifi_rounded),
      ('02', 'Configure', 'Set up rooms, routines, and preferences. Our AI learns your patterns.', Icons.tune_rounded),
      ('03', 'Control', 'Manage everything from the dashboard — voice, touch, or full automation.', Icons.touch_app_rounded),
      ('04', 'Optimize', 'AI continuously improves efficiency, security, and comfort over time.', Icons.auto_awesome_rounded),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1229), Color(0xFF0A0E21)],
        ),
      ),
      child: Column(
        children: [
          _sectionTag('HOW IT WORKS'),
          const SizedBox(height: 16),
          Text(
            'Setup in Minutes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 48),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.map((s) {
                    final (num, title, desc, icon) = s;
                    return Expanded(child: _stepCard(num, title, desc, icon));
                  }).toList(),
                )
              : Column(
                  children: steps.map((s) {
                    final (num, title, desc, icon) = s;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _stepCard(num, title, desc, icon),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _stepCard(String num, String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 28),
              ),
              Positioned(
                right: 0, top: 0,
                child: Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Center(
                    child: Text(num,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // ===================== TESTIMONIALS =====================
  Widget _buildTestimonialsSection(bool isDesktop, bool isMobile) {
    final testimonials = [
      ('Sarah K.', 'Homeowner', 'SmartHome AI reduced my energy bill by 35%. The AI learns exactly when to heat, cool, and turn off devices.', 5),
      ('James M.', 'Tech Enthusiast', 'The security features are incredible. Face recognition knows my family and alerts me for unknown visitors.', 5),
      ('Lisa R.', 'Parent of 3', 'Managing all our devices from one app is a game-changer. The kids\' room automation is perfect.', 5),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 24,
      ),
      color: const Color(0xFF0D1229),
      child: Column(
        children: [
          _sectionTag('TESTIMONIALS'),
          const SizedBox(height: 16),
          Text(
            'Loved by Homeowners',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 48),
          _responsiveGrid(
            isDesktop: isDesktop,
            isMobile: isMobile,
            children: testimonials.map((t) {
              final (name, role, quote, stars) = t;
              return Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        stars,
                        (_) => const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('"$quote"',
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          child: Text(name[0],
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(role,
                                style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ===================== PRICING =====================
  Widget _buildPricingSection(bool isDesktop, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1229), Color(0xFF0A0E21)],
        ),
      ),
      child: Column(
        children: [
          _sectionTag('PRICING'),
          const SizedBox(height: 16),
          Text(
            'Simple, Transparent Pricing',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 28 : 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 48),
          _responsiveGrid(
            isDesktop: isDesktop,
            isMobile: isMobile,
            children: [
              _pricingCard('Starter', '\$0', '/month', [
                '10 Devices', 'Basic Automation', 'Energy Monitoring',
                'Mobile App', 'Community Support',
              ], false),
              _pricingCard('Pro', '\$9.99', '/month', [
                'Unlimited Devices', 'AI Automation', 'Advanced Security',
                'Voice Control', 'Priority Support', 'Energy Analytics',
              ], true),
              _pricingCard('Enterprise', '\$29.99', '/month', [
                'Multi-Home', 'Custom Integrations', 'Dedicated Manager',
                'SLA Guarantee', '24/7 Phone Support', 'White-Label Option',
              ], false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricingCard(
      String title, String price, String period, List<String> features, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: highlight
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A2668), Color(0xFF1A1F3A)],
              )
            : null,
        color: highlight ? null : AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlight ? AppTheme.primaryColor : Colors.white10,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (highlight)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('MOST POPULAR',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(period,
                    style: const TextStyle(color: Colors.white38, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppTheme.successColor, size: 18),
                    const SizedBox(width: 10),
                    Text(f, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: highlight ? AppTheme.primaryColor : Colors.white10,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== ABOUT =====================
  Widget _buildAboutSection(bool isDesktop, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isDesktop ? 80 : 24,
      ),
      color: const Color(0xFF0D1229),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _aboutContent(isMobile)),
                const SizedBox(width: 48),
                Expanded(flex: 4, child: _aboutStats()),
              ],
            )
          : Column(
              children: [
                _aboutContent(isMobile),
                const SizedBox(height: 40),
                _aboutStats(),
              ],
            ),
    );
  }

  Widget _aboutContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTagLeft('ABOUT US'),
        const SizedBox(height: 16),
        Text(
          'Building the Future\nof Smart Living',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'SmartHome AI was founded in 2024 with a mission to make intelligent home '
          'automation accessible to everyone. Our team combines expertise in AI, IoT, '
          'and beautiful design to create the most intuitive smart home platform.',
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 16),
        const Text(
          'We believe your home should anticipate your needs — adjusting climate before '
          'you arrive, securing doors when you sleep, and optimizing energy consumption '
          '24/7. With over 150 features and 50+ device types, we\'re making that vision a reality.',
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.7),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _teamInfo(Icons.engineering, 'Built by Engineers'),
            _teamInfo(Icons.favorite, 'User-First Design'),
            _teamInfo(Icons.eco, 'Eco-Conscious'),
          ],
        ),
      ],
    );
  }

  Widget _teamInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _aboutStats() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _aboutStatRow('Founded', '2024', Icons.calendar_today),
          _aboutStatRow('Team Size', '48 Engineers', Icons.people),
          _aboutStatRow('Offices', 'SF, London, Bengaluru', Icons.location_on),
          _aboutStatRow('Devices Managed', '2M+', Icons.devices_other),
          _aboutStatRow('Energy Saved', '450 GWh', Icons.bolt),
          _aboutStatRow('CO₂ Reduced', '120K Tons', Icons.eco),
        ],
      ),
    );
  }

  Widget _aboutStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          ),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ===================== FOOTER =====================
  Widget _buildFooter(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 48,
        horizontal: isDesktop ? 80 : 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF080B19),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _footerBrand()),
                    Expanded(flex: 2, child: _footerLinks('Product', ['Features', 'Pricing', 'Devices', 'API Docs'])),
                    Expanded(flex: 2, child: _footerLinks('Company', ['About', 'Careers', 'Blog', 'Contact'])),
                    Expanded(flex: 2, child: _footerLinks('Legal', ['Privacy', 'Terms', 'Security', 'GDPR'])),
                  ],
                )
              : Column(
                  children: [
                    _footerBrand(),
                    const SizedBox(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _footerLinks('Product', ['Features', 'Pricing', 'Devices'])),
                        Expanded(child: _footerLinks('Company', ['About', 'Careers', 'Blog'])),
                        Expanded(child: _footerLinks('Legal', ['Privacy', 'Terms', 'Security'])),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('© 2026 SmartHome AI. All rights reserved.',
                  style: TextStyle(color: Colors.white30, fontSize: 12)),
              Row(
                children: [
                  _socialIcon(Icons.language),
                  _socialIcon(Icons.alternate_email),
                  _socialIcon(Icons.code),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text('SmartHome AI',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          child: const Text(
            'Making homes smarter, safer, and more sustainable with AI and IoT.',
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _footerLinks(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...links.map((l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(l,
                  style: const TextStyle(color: Colors.white38, fontSize: 13)),
            )),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Icon(icon, color: Colors.white30, size: 18),
    );
  }

  // ===================== HELPERS =====================
  Widget _sectionTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
    );
  }

  Widget _sectionTagLeft(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _sectionTag(label),
    );
  }

  Widget _responsiveGrid({
    required bool isDesktop,
    required bool isMobile,
    required List<Widget> children,
  }) {
    if (isDesktop) {
      // Rows of 3
      final rows = <Widget>[];
      for (var i = 0; i < children.length; i += 3) {
        final end = (i + 3).clamp(0, children.length);
        rows.add(Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = i; j < end; j++) ...[
                if (j > i) const SizedBox(width: 16),
                Expanded(child: children[j]),
              ],
              // Fill remaining space
              for (var k = end - i; k < 3; k++) ...[
                const SizedBox(width: 16),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ));
      }
      return Column(children: rows);
    }

    // Mobile / tablet: stack
    return Column(
      children: children
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: c,
              ))
          .toList(),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final Color color;
  final String description;
  const _FeatureData(this.icon, this.title, this.color, this.description);
}
