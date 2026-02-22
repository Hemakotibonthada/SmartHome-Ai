import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SmartFeaturesService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, svc),
              Expanded(child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildEmergencyButton(context, svc),
                  const SizedBox(height: 16),
                  _buildDoorWindowSection(svc),
                  const SizedBox(height: 16),
                  _buildSafetyModes(svc),
                  const SizedBox(height: 16),
                  _buildAirQualitySection(svc),
                  const SizedBox(height: 16),
                  _buildGuestModeSection(svc),
                  const SizedBox(height: 16),
                  _buildParentalControls(svc),
                  const SizedBox(height: 16),
                  _buildGeofencingSection(svc),
                  const SizedBox(height: 100),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SmartFeaturesService svc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Safety Center', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
          if (svc.emergencyActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: const Color(0xFFF44336).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Color(0xFFF44336), size: 14),
                  SizedBox(width: 4),
                  Text('ALERT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===== EMERGENCY PROTOCOL (Feature 14) =====
  Widget _buildEmergencyButton(BuildContext context, SmartFeaturesService svc) {
    return GestureDetector(
      onLongPress: () {
        svc.emergencyActive ? svc.cancelEmergency() : svc.triggerEmergency();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(svc.emergencyActive
                ? '🚨 Emergency Protocol Activated! All lights ON, doors LOCKED.'
                : '✅ Emergency Protocol Deactivated.'),
            backgroundColor: svc.emergencyActive ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: svc.emergencyActive ? const Color(0xFFF44336).withValues(alpha: 0.2) : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(24),
          border: svc.emergencyActive ? Border.all(color: const Color(0xFFF44336), width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: svc.emergencyActive
                    ? const Color(0xFFF44336)
                    : const Color(0xFFF44336).withValues(alpha: 0.12),
              ),
              child: Icon(Icons.emergency, size: 32,
                color: svc.emergencyActive ? Colors.white : const Color(0xFFF44336)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(svc.emergencyActive ? 'EMERGENCY ACTIVE' : 'Emergency Protocol',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                      color: svc.emergencyActive ? const Color(0xFFF44336) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(svc.emergencyActive
                      ? 'All lights on • Doors locked • Alarm active'
                      : 'Long press to activate',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            Icon(
              svc.emergencyActive ? Icons.radio_button_on : Icons.radio_button_off,
              color: svc.emergencyActive ? const Color(0xFFF44336) : Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  // ===== DOOR / WINDOW STATUS (Feature 17) =====
  Widget _buildDoorWindowSection(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.door_front_door, color: Color(0xFF2196F3), size: 18),
              const SizedBox(width: 8),
              const Text('Doors & Windows', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${svc.doorWindowStatus.where((d) => !d.isOpen).length}/${svc.doorWindowStatus.length} secured',
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...svc.doorWindowStatus.map((door) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: door.isOpen
                  ? const Color(0xFFFF9800).withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  door.type == 'door' ? Icons.door_front_door : Icons.window,
                  color: door.isOpen ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(door.name, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                      Text(
                        '${door.isOpen ? "Open" : "Closed"} • ${door.isLocked ? "🔒 Locked" : "🔓 Unlocked"}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ),
                if (door.type == 'door')
                  Switch(
                    value: door.isLocked,
                    onChanged: (_) => svc.toggleDoorLock(door.id),
                    activeColor: const Color(0xFF4CAF50),
                    inactiveThumbColor: const Color(0xFFFF9800),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ===== SLEEP / WAKE / VACATION MODE (Features 9, 10, 11) =====
  Widget _buildSafetyModes(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mode Controls', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _modeRow(Icons.bedtime, 'Sleep Mode', 'Dim lights, reduce noise',
            svc.sleepModeActive, const Color(0xFF673AB7), svc.toggleSleepMode),
          _modeRow(Icons.wb_sunny, 'Wake Mode', 'Gradual brightness, coffee machine',
            svc.wakeModeActive, const Color(0xFFFF9800), svc.toggleWakeMode),
          _modeRow(Icons.flight, 'Vacation Mode', 'Simulate presence, random lights',
            svc.vacationMode.isEnabled, const Color(0xFF00BCD4), svc.toggleVacationMode),
        ],
      ),
    );
  }

  Widget _modeRow(IconData icon, String title, String subtitle, bool active, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          Switch(value: active, onChanged: (_) => onTap(), activeColor: color),
        ],
      ),
    );
  }

  // ===== AIR QUALITY (Feature 5) =====
  Widget _buildAirQualitySection(SmartFeaturesService svc) {
    final aq = svc.airQuality;
    if (aq == null) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Color(0xFF00BCD4), size: 18),
              const SizedBox(width: 8),
              const Text('Air Quality', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: aq.levelColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(aq.level, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: aq.levelColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _aqMetric('AQI', aq.aqi.toString(), aq.levelColor)),
              Expanded(child: _aqMetric('CO₂', '${aq.co2.toStringAsFixed(0)} ppm', aq.co2 > 1000 ? const Color(0xFFF44336) : const Color(0xFF4CAF50))),
              Expanded(child: _aqMetric('VOC', '${aq.voc.toStringAsFixed(0)} ppb', aq.voc > 500 ? const Color(0xFFF44336) : const Color(0xFF4CAF50))),
              Expanded(child: _aqMetric('PM2.5', '${aq.pm25.toStringAsFixed(0)}', aq.pm25 > 35 ? const Color(0xFFF44336) : const Color(0xFF4CAF50))),
            ],
          ),
          const SizedBox(height: 12),
          Text(aq.recommendation, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _aqMetric(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }

  // ===== GUEST MODE (Feature 13) =====
  Widget _buildGuestModeSection(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: Color(0xFF9C27B0), size: 18),
              const SizedBox(width: 8),
              const Text('Guest Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: svc.guestModeActive,
                onChanged: (_) => svc.toggleGuestMode(),
                activeColor: const Color(0xFF9C27B0),
              ),
            ],
          ),
          if (svc.guestModeActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Guest Access Active', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('• Basic lights & AC control enabled\n• Security cameras hidden\n• Smart locks restricted\n• Admin settings locked',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), height: 1.6)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== PARENTAL CONTROLS (Feature 15) =====
  Widget _buildParentalControls(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.child_care, color: Color(0xFFE91E63), size: 18),
              const SizedBox(width: 8),
              const Text('Parental Controls', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: svc.parentalControlsEnabled,
                onChanged: (_) => svc.toggleParentalControls(),
                activeColor: const Color(0xFFE91E63),
              ),
            ],
          ),
          if (svc.parentalControlsEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Restrictions Active', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Text('• Kitchen appliances locked after 9 PM\n• Thermostat range limited 20-26°C\n• Smart plug schedule enforced\n• Usage time limits active',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4), height: 1.6)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== GEOFENCING (Feature 12) =====
  Widget _buildGeofencingSection(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location, color: Color(0xFF00BCD4), size: 18),
              const SizedBox(width: 8),
              const Text('Geofence Rules', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          ...svc.geofenceRules.map((rule) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Icon(
                  rule.trigger == GeofenceTrigger.onEnter ? Icons.login : Icons.logout,
                  color: rule.trigger == GeofenceTrigger.onEnter ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      Text('${rule.trigger.name} • ${rule.radiusMeters.toStringAsFixed(0)}m radius',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
                Switch(
                  value: rule.isEnabled,
                  onChanged: (_) => svc.toggleGeofence(rule.id),
                  activeColor: const Color(0xFF00BCD4),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }
}
