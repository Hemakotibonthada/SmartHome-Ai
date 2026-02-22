import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/features/auth/providers/auth_provider.dart';
import 'package:smart_home_ai/features/dashboard/screens/dashboard_screen.dart';
import 'package:smart_home_ai/features/devices/screens/devices_screen.dart';
import 'package:smart_home_ai/features/sensors/screens/sensors_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/analytics_screen.dart';
import 'package:smart_home_ai/features/settings/screens/settings_screen.dart';
import 'package:smart_home_ai/features/devices/screens/device_hub_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/ai_hub_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/lifestyle_hub_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/security_dashboard_screen.dart';
import 'package:smart_home_ai/features/analytics/screens/system_management_screen.dart';

/// Top-level shell for the web / desktop layout.
/// Uses a persistent sidebar + top bar instead of bottom navigation.
class WebShell extends StatefulWidget {
  const WebShell({super.key});

  @override
  State<WebShell> createState() => _WebShellState();
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

class _WebShellState extends State<WebShell> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      screen: const DashboardScreen(),
    ),
    _NavItem(
      icon: Icons.devices_other_outlined,
      activeIcon: Icons.devices_other_rounded,
      label: 'Devices',
      screen: const DevicesScreen(),
    ),
    _NavItem(
      icon: Icons.hub_outlined,
      activeIcon: Icons.hub_rounded,
      label: 'Device Hub',
      screen: const DeviceHubScreen(),
    ),
    _NavItem(
      icon: Icons.sensors_outlined,
      activeIcon: Icons.sensors_rounded,
      label: 'Sensors',
      screen: const SensorsScreen(),
    ),
    _NavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics_rounded,
      label: 'Analytics',
      screen: const AnalyticsScreen(),
    ),
    _NavItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology_rounded,
      label: 'AI Hub',
      screen: const AIHubScreen(),
    ),
    _NavItem(
      icon: Icons.spa_outlined,
      activeIcon: Icons.spa_rounded,
      label: 'Lifestyle',
      screen: const LifestyleHubScreen(),
    ),
    _NavItem(
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield_rounded,
      label: 'Security',
      screen: const SecurityDashboardScreen(),
    ),
    _NavItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build_rounded,
      label: 'System',
      screen: const SystemManagementScreen(),
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      screen: const SettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWideDesktop(context);
    // Auto-expand on wide screens
    if (isWide && !_sidebarExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _sidebarExpanded = true);
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: Row(
          children: [
            // ---- SIDEBAR ----
            RepaintBoundary(child: _buildSidebar()),
            // ---- MAIN CONTENT ----
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.darkBg.withValues(alpha: 0.5),
                        ),
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _navItems.map((item) => RepaintBoundary(child: item.screen)).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================ SIDEBAR ================
  Widget _buildSidebar() {
    final width = _sidebarExpanded ? 240.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1330),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          _buildSidebarHeader(),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 12),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _navItems.length,
              itemBuilder: (context, index) => _buildSidebarItem(index),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          // Collapse toggle
          _buildCollapseButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _sidebarExpanded ? 16 : 8),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
          ),
          if (_sidebarExpanded) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SmartHome',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('AI Platform',
                      style: TextStyle(color: AppTheme.secondaryColor, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _selectedIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarExpanded ? 14 : 0,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.25)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisAlignment: _sidebarExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? AppTheme.primaryColor : Colors.white38,
                  size: 22,
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _sidebarExpanded
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: Colors.white38,
                size: 22,
              ),
              if (_sidebarExpanded) ...[
                const SizedBox(width: 8),
                const Text('Collapse',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================ TOP BAR ================
  Widget _buildTopBar() {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1330).withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          // Page title
          Flexible(
            flex: 0,
            child: Text(
              _navItems[_selectedIndex].label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          // Search
          Flexible(
            flex: 0,
            child: Container(
              width: 280,
              height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(Icons.search, color: Colors.white30, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search devices, rooms...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('⌘K',
                      style: TextStyle(color: Colors.white30, fontSize: 11)),
                ),
              ],
            ),
          ),
          ),
          const SizedBox(width: 16),
          // Notifications
          _topBarIcon(Icons.notifications_none_rounded, badge: true),
          const SizedBox(width: 8),
          _topBarIcon(Icons.dark_mode_rounded),
          const SizedBox(width: 16),
          // User avatar
          Flexible(
            flex: 0,
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                  child: Text(
                    (user?.name ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'User',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(user?.email ?? '',
                        style: const TextStyle(color: Colors.white30, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(Icons.expand_more, color: Colors.white30, size: 16),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _topBarIcon(IconData icon, {bool badge = false}) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white54, size: 18),
            ),
          ),
        ),
        if (badge)
          Positioned(
            right: 6, top: 6,
            child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.errorColor,
              ),
            ),
          ),
      ],
    );
  }
}
