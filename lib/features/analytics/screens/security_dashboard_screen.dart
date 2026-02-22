import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/shared/widgets/web_content_wrapper.dart';
import 'package:smart_home_ai/shared/widgets/hover_card.dart';
import 'package:smart_home_ai/shared/widgets/empty_state_widget.dart';
import 'package:smart_home_ai/core/services/security_lifestyle_service.dart';

class SecurityDashboardScreen extends StatelessWidget {
  const SecurityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sec = context.watch<SecurityLifestyleService>();
    final isDemo = context.watch<DemoModeService>().isDemoMode;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: !isDemo && sec.faceRecognitions.isEmpty
              ? Column(
                  children: [
                    _buildHeader(context, sec),
                    Expanded(child: EmptyStateWidget.noSecurityData()),
                  ],
                )
              : CustomScrollView(
            physics: WebContentWrapper.scrollPhysics,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, sec)),
              SliverToBoxAdapter(child: _buildPanicButton(sec)),
              SliverToBoxAdapter(
                child: Responsive.isDesktop(context)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(children: [
                                _buildFaceRecognition(sec),
                                _buildPerimeterZones(sec),
                                _buildVisitorLog(sec),
                                _buildCameraAnalytics(sec),
                                _buildEvacuationRoutes(sec),
                              ]),
                            ),
                            Expanded(
                              child: Column(children: [
                                _buildIntruderAlerts(sec),
                                _buildPackageTracking(sec),
                                _buildFloodSensors(sec),
                                _buildAccessEvents(sec),
                                _buildNeighborhoodAlerts(sec),
                              ]),
                            ),
                          ],
                        ),
                      )
                    : Column(children: [
                        _buildFaceRecognition(sec),
                        _buildIntruderAlerts(sec),
                        _buildPerimeterZones(sec),
                        _buildPackageTracking(sec),
                        _buildVisitorLog(sec),
                        _buildFloodSensors(sec),
                        _buildCameraAnalytics(sec),
                        _buildAccessEvents(sec),
                        _buildEvacuationRoutes(sec),
                        _buildNeighborhoodAlerts(sec),
                      ]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SecurityLifestyleService sec) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.pop(context),
              child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Security Center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${sec.intruderAlerts.where((a) => !a.isResolved).length} active alerts • ${sec.perimeterZones.where((z) => z.isArmed).length} zones armed', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF5722), Color(0xFFF44336)]), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.security, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPanicButton(SecurityLifestyleService sec) {
    final panic = sec.panicButton;
    if (panic == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onLongPress: () {
          if (!panic.isTriggered) sec.triggerPanicButton();
        },
        onTap: () {
          if (panic.isTriggered) sec.cancelPanicButton();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: panic.isTriggered ? const LinearGradient(colors: [Color(0xFFF44336), Color(0xFFD32F2F)]) : null,
            color: panic.isTriggered ? null : AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: panic.isTriggered ? Colors.red : Colors.red.withValues(alpha: 0.3), width: panic.isTriggered ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: panic.isTriggered ? Colors.white.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emergency, color: panic.isTriggered ? Colors.white : Colors.red, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(panic.isTriggered ? 'PANIC ACTIVATED' : 'Emergency Panic Button', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: panic.isTriggered ? Colors.white : Colors.red)),
                    Text(panic.isTriggered ? 'Tap to cancel • Authorities notified' : 'Long press to activate', style: TextStyle(fontSize: 12, color: panic.isTriggered ? Colors.white70 : Colors.white54)),
                    if (panic.isTriggered) Text('Contacts: ${panic.emergencyContacts.join(", ")}', style: const TextStyle(fontSize: 10, color: Colors.white60)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaceRecognition(SecurityLifestyleService sec) {
    return _buildSectionCard('Face Recognition', Icons.face, const Color(0xFF2196F3),
      Column(
        children: sec.faceRecognitions.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: f.isKnown ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: f.isKnown ? Colors.green : Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.personName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${f.camera} • ${f.accessLevel}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(_formatDateTime(f.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: f.isKnown ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('${(f.confidence * 100).toStringAsFixed(0)}%', style: TextStyle(color: f.isKnown ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildIntruderAlerts(SecurityLifestyleService sec) {
    final alerts = sec.intruderAlerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard('Intruder Detection', Icons.warning, const Color(0xFFF44336),
      Column(
        children: alerts.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: a.isResolved ? AppTheme.darkSurface : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: a.isResolved ? null : Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(a.isResolved ? Icons.check_circle : Icons.error, color: a.isResolved ? Colors.green : Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.alertType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${a.location} • ${a.camera}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Threat: ${a.threatLevel} | ${_formatDateTime(a.timestamp)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              if (a.actionTaken.isNotEmpty) Text(a.actionTaken, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPerimeterZones(SecurityLifestyleService sec) {
    return _buildSectionCard('Perimeter Security', Icons.fence, const Color(0xFFFF9800),
      Column(
        children: sec.perimeterZones.map((z) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 4, height: 40,
                decoration: BoxDecoration(color: z.isBreached ? Colors.red : z.isArmed ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(z.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${z.sensorType} • Sensitivity: ${z.sensitivity}%', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(z.isBreached ? 'BREACH DETECTED!' : z.isArmed ? 'Armed & Monitoring' : 'Disarmed', style: TextStyle(color: z.isBreached ? Colors.red : z.isArmed ? Colors.green : Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => sec.togglePerimeterZone(z.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: z.isArmed ? Colors.green.withValues(alpha: 0.2) : Colors.white12, borderRadius: BorderRadius.circular(8)),
                  child: Text(z.isArmed ? 'ARM' : 'DISARM', style: TextStyle(color: z.isArmed ? Colors.green : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPackageTracking(SecurityLifestyleService sec) {
    return _buildSectionCard('Package Delivery', Icons.local_shipping, const Color(0xFF795548),
      Column(
        children: sec.packages.map((p) => GestureDetector(
          onTap: () => p.isCollected ? null : sec.collectPackage(p.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(p.isCollected ? Icons.check_circle : Icons.inventory_2, color: p.isCollected ? Colors.green : const Color(0xFF795548), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.carrier, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Tracking: ${p.trackingNumber}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      Text('${p.status} • ${p.deliveryLocation}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
                if (!p.isCollected) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Collect', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildVisitorLog(SecurityLifestyleService sec) {
    return _buildSectionCard('Visitor History', Icons.people, const Color(0xFF607D8B),
      Column(
        children: sec.visitors.map((v) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: v.isAllowed ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                child: Icon(Icons.person, color: v.isAllowed ? Colors.green : Colors.red, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('${v.purpose} • ${v.entryPoint}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              Text(_formatTime(v.arrivalTime), style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFloodSensors(SecurityLifestyleService sec) {
    return _buildSectionCard('Flood Detection', Icons.water_damage, const Color(0xFF00BCD4),
      Column(
        children: sec.floodSensors.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: f.isAlarm ? Colors.red.withValues(alpha: 0.1) : AppTheme.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: f.isAlarm ? Border.all(color: Colors.red.withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(f.isAlarm ? Icons.warning : Icons.water_drop, color: f.isAlarm ? Colors.red : const Color(0xFF00BCD4), size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.location, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Level: ${f.waterLevel.toStringAsFixed(1)}cm • Humidity: ${f.humidity.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: f.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(f.status, style: TextStyle(color: f.statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCameraAnalytics(SecurityLifestyleService sec) {
    if (sec.cameraAnalytics.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard('Camera Analytics', Icons.analytics, const Color(0xFF9C27B0),
      Column(
        children: sec.cameraAnalytics.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam, color: Color(0xFF9C27B0), size: 18),
                  const SizedBox(width: 8),
                  Text(c.cameraName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: c.isRecording ? Colors.red.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(c.isRecording ? 'REC' : 'IDLE', style: TextStyle(color: c.isRecording ? Colors.red : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnalyticsStat('People', '${c.peopleCount}'),
                  _buildAnalyticsStat('Vehicles', '${c.vehicleCount}'),
                  _buildAnalyticsStat('Animals', '${c.animalCount}'),
                  _buildAnalyticsStat('Motion', c.motionEvents > 0 ? '${c.motionEvents}' : '0'),
                ],
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAnalyticsStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildAccessEvents(SecurityLifestyleService sec) {
    return _buildSectionCard('Access Timeline', Icons.timeline, const Color(0xFF3F51B5),
      Column(
        children: sec.accessEvents.take(6).map((e) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: e.wasGranted ? Colors.green : Colors.red),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Text(e.userName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(e.method, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    const SizedBox(width: 8),
                    Text(e.location, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Text(_formatTime(e.timestamp), style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildEvacuationRoutes(SecurityLifestyleService sec) {
    return _buildSectionCard('Evacuation Routes', Icons.directions_run, const Color(0xFFFF5722),
      Column(
        children: sec.evacuationRoutes.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(Icons.route, color: r.isClear ? Colors.green : Colors.red, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(r.path.join(' → '), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Est. time: ${r.estimatedTime} sec', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: r.isClear ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(r.isClear ? 'CLEAR' : 'BLOCKED', style: TextStyle(color: r.isClear ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildNeighborhoodAlerts(SecurityLifestyleService sec) {
    return _buildSectionCard('Neighborhood Alerts', Icons.location_city, const Color(0xFFFF9800),
      Column(
        children: sec.neighborhoodAlerts.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(a.icon, color: a.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.alertType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    Text(a.description, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    Text('${a.distance.toStringAsFixed(1)} km away • ${a.reportedBy}', style: const TextStyle(color: Colors.white38, fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Color color, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: HoverCard(
        borderColor: color.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
