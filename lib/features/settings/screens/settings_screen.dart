import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/shared/widgets/web_content_wrapper.dart';
import 'package:smart_home_ai/shared/widgets/empty_state_widget.dart';
import 'package:smart_home_ai/features/auth/providers/auth_provider.dart';
import 'package:smart_home_ai/features/auth/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _notificationsEnabled = true;
  bool _autoMode = true;
  bool _voiceControl = false;
  bool _locationBased = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final demoMode = context.watch<DemoModeService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: WebContentWrapper.scrollPhysics,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildProfileCard(auth)),
              // Demo Mode Toggle
              SliverToBoxAdapter(child: _buildSection('Data Mode', [
                _buildDemoModeToggle(demoMode),
              ])),
              SliverToBoxAdapter(child: _buildSection('Home Settings', [
                _buildToggle('Auto Mode', 'Automate based on patterns', Icons.auto_mode, _autoMode, (v) => setState(() => _autoMode = v)),
                _buildToggle('Voice Control', 'Control with voice commands', Icons.mic, _voiceControl, (v) => setState(() => _voiceControl = v)),
                _buildToggle('Location Based', 'Trigger by location', Icons.location_on, _locationBased, (v) => setState(() => _locationBased = v)),
              ])),
              SliverToBoxAdapter(child: _buildSection('Notifications', [
                _buildToggle('Push Notifications', 'Alerts & updates', Icons.notifications, _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
                _buildToggle('Email Alerts', 'Critical alerts via email', Icons.email, true, (v) {}),
              ])),
              SliverToBoxAdapter(child: _buildSection('Appearance', [
                _buildToggle('Dark Mode', 'Switch theme', Icons.dark_mode, theme.isDark, (v) => theme.toggleTheme()),
              ])),
              SliverToBoxAdapter(child: _buildSection('Device Management', [
                _buildNavigationItem('Connected Devices', 'Manage ESP32 nodes', Icons.devices),
                _buildNavigationItem('MQTT Settings', 'Broker configuration', Icons.cloud),
                _buildNavigationItem('WiFi Networks', 'Network settings', Icons.wifi),
                _buildNavigationItem('Firmware Updates', 'Update device firmware', Icons.system_update),
              ])),
              SliverToBoxAdapter(child: _buildSection('Data & Privacy', [
                _buildNavigationItem('Export Data', 'Download sensor data', Icons.download),
                _buildNavigationItem('Data Retention', 'Manage stored data', Icons.storage),
                _buildNavigationItem('Privacy Settings', 'Control data sharing', Icons.privacy_tip),
              ])),
              SliverToBoxAdapter(child: _buildSection('About', [
                _buildNavigationItem('App Version', 'v1.0.0', Icons.info_outline),
                _buildNavigationItem('Help & Support', 'FAQs and docs', Icons.help_outline),
                _buildNavigationItem('Terms of Service', 'Legal information', Icons.description),
              ])),
              SliverToBoxAdapter(child: _buildLogoutButton(context, auth)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          if (context.watch<DemoModeService>().isDemoMode)
            const DemoBadge(),
        ],
      ),
    );
  }

  Widget _buildDemoModeToggle(DemoModeService demoMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: demoMode.isDemoMode
                  ? AppTheme.warningColor.withValues(alpha: 0.15)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              demoMode.isDemoMode ? Icons.science : Icons.cloud_sync,
              color: demoMode.isDemoMode ? AppTheme.warningColor : AppTheme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  demoMode.isDemoMode ? 'Demo Mode' : 'Live Mode',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                Text(
                  demoMode.isDemoMode
                      ? 'Showing simulated data for exploration'
                      : 'Connected to real devices & services',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3)),
                ),
              ],
            ),
          ),
          Switch(
            value: demoMode.isDemoMode,
            onChanged: (v) => demoMode.setDemoMode(v),
            activeColor: AppTheme.warningColor,
            activeTrackColor: AppTheme.warningColor.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor.withValues(alpha: 0.15), AppTheme.secondaryColor.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  (auth.user?.name ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.user?.name ?? 'User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    auth.user?.email ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: auth.user?.isAdmin == true
                          ? AppTheme.warningColor.withOpacity(0.2)
                          : AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      auth.user?.role.name.toUpperCase() ?? 'USER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: auth.user?.isAdmin == true ? AppTheme.warningColor : AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: Colors.white38, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            inactiveThumbColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(String title, String subtitle, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        hoverColor: AppTheme.primaryColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.2), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            auth.logout();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          icon: const Icon(Icons.logout, size: 20),
          label: const Text('Sign Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor.withOpacity(0.15),
            foregroundColor: AppTheme.errorColor,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
