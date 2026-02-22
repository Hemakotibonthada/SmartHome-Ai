import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/features/admin/screens/admin_overview_screen.dart';
import 'package:smart_home_ai/features/admin/screens/ai_models_screen.dart';
import 'package:smart_home_ai/features/admin/screens/admin_users_screen.dart';
import 'package:smart_home_ai/features/admin/screens/admin_logs_screen.dart';
import 'package:smart_home_ai/features/admin/screens/admin_security_screen.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.screen});
}

/// The top-level Admin Portal shell — sidebar + content pane.
class AdminWebShell extends StatefulWidget {
  const AdminWebShell({super.key});

  @override
  State<AdminWebShell> createState() => _AdminWebShellState();
}

class _AdminWebShellState extends State<AdminWebShell> {
  int _index = 0;
  bool _expanded = true;

  final List<_NavItem> _items = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Overview', screen: const AdminOverviewScreen()),
    _NavItem(icon: Icons.psychology_outlined, activeIcon: Icons.psychology_rounded, label: 'AI Models', screen: const AIModelsScreen()),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people_rounded, label: 'Users', screen: const AdminUsersScreen()),
    _NavItem(icon: Icons.terminal_outlined, activeIcon: Icons.terminal_rounded, label: 'Logs & System', screen: const AdminLogsScreen()),
    _NavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield_rounded, label: 'Security', screen: const AdminSecurityScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1440;
    if (wide && !_expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _expanded = true);
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: Row(
          children: [
            // Sidebar
            RepaintBoundary(child: _buildSidebar()),
            // Content
            Expanded(
              child: IndexedStack(
                index: _index,
                children: _items.map((e) => RepaintBoundary(child: e.screen)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final w = _expanded ? 220.0 : 68.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: w,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
      ),
      child: Column(
        children: [
          // Top section: back button + logo
          Container(
            height: 64,
            padding: EdgeInsets.symmetric(horizontal: _expanded ? 16 : 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 18),
                  color: Colors.white54,
                  tooltip: 'Back to Home',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                if (_expanded) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.menu_open, size: 18),
                    color: Colors.white38,
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _items.length,
              itemBuilder: (ctx, i) {
                final item = _items[i];
                final sel = i == _index;
                return Tooltip(
                  message: _expanded ? '' : item.label,
                  waitDuration: const Duration(milliseconds: 300),
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: _expanded ? 10 : 8, vertical: 3),
                      padding: EdgeInsets.symmetric(horizontal: _expanded ? 14 : 0, vertical: 11),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: sel ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: _expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(sel ? item.activeIcon : item.icon, size: 20, color: sel ? AppTheme.primaryColor : Colors.white38),
                          if (_expanded) ...[
                            const SizedBox(width: 12),
                            Text(item.label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.normal, color: sel ? Colors.white : Colors.white54)),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom info
          if (_expanded)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 18, color: AppTheme.primaryColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Portal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                        Text('Full system control', style: TextStyle(fontSize: 9, color: Colors.white30)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!_expanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: IconButton(
                icon: const Icon(Icons.menu, size: 18),
                color: Colors.white38,
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ),
        ],
      ),
    );
  }
}
