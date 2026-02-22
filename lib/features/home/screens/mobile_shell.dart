import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_home_ai/features/devices/screens/devices_screen.dart';
import 'package:smart_home_ai/features/sensors/screens/sensors_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/analytics_screen.dart';
import 'package:smart_home_ai/features/settings/screens/settings_screen.dart';

/// Mobile-optimised navigation shell with animated bottom nav and drawer.
class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnim;

  final _screens = const <Widget>[
    DashboardScreen(),
    DevicesScreen(),
    SensorsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnim = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  void _onTab(int i) {
    setState(() => _currentIndex = i);
    _pageController.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    _fabAnim.reset();
    _fabAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
              _navItem(1, Icons.devices_other_outlined, Icons.devices_other_rounded, 'Devices'),
              _navItem(2, Icons.sensors_outlined, Icons.sensors_rounded, 'Sensors'),
              _navItem(3, Icons.analytics_outlined, Icons.analytics_rounded, 'Analytics'),
              _navItem(4, Icons.settings_outlined, Icons.settings_rounded, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, IconData activeIcon, String label) {
    final sel = _currentIndex == idx;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTab(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: sel ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: sel
              ? AppTheme.primaryColor.withValues(alpha: 0.13)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sel ? activeIcon : icon,
              color: sel ? AppTheme.primaryColor : Colors.white38,
              size: sel ? 26 : 22,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: sel ? 11 : 10,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? AppTheme.primaryColor : Colors.white38,
              ),
              child: Text(label),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: sel ? 20 : 0,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
