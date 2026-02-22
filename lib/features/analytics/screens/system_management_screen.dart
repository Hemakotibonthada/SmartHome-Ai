import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/advanced_home_service.dart';
import 'package:smart_home_ai/core/services/security_lifestyle_service.dart';

class SystemManagementScreen extends StatelessWidget {
  const SystemManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adv = context.watch<AdvancedHomeService>();
    final sec = context.watch<SecurityLifestyleService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildSmartHomeScore(sec)),
              SliverToBoxAdapter(child: _buildNetworkHealth(sec)),
              SliverToBoxAdapter(child: _buildFirmwareManager(sec)),
              SliverToBoxAdapter(child: _buildFamilyMembers(sec)),
              SliverToBoxAdapter(child: _buildEnergyAudit(sec)),
              SliverToBoxAdapter(child: _buildHomeInventory(adv)),
              SliverToBoxAdapter(child: _buildSmartNotifications(adv)),
              SliverToBoxAdapter(child: _buildApplianceLifecycle(adv)),
              SliverToBoxAdapter(child: _buildServiceProviders(sec)),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('System Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Network • Firmware • Health • Audit', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF607D8B), Color(0xFF455A64)]), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.settings_suggest, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartHomeScore(SecurityLifestyleService sec) {
    final score = sec.homeScore;
    if (score == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [score.scoreColor.withValues(alpha: 0.2), AppTheme.darkCard]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: score.scoreColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: score.scoreColor, width: 4)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${score.overallScore.toStringAsFixed(0)}', style: TextStyle(color: score.scoreColor, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text(score.grade, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Smart Home Score', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('Rank: Top ${score.rank}% globally', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildScorePill('Security', score.securityScore.toDouble(), Colors.red),
                          _buildScorePill('Energy', score.energyScore.toDouble(), Colors.green),
                          _buildScorePill('Auto', score.automationScore.toDouble(), Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...score.improvements.map((i) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.arrow_upward, color: i.impactColor, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text(i.suggestion, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                  Text('+${i.pointsGain}', style: TextStyle(color: i.impactColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildScorePill(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text('$label ${value.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildNetworkHealth(SecurityLifestyleService sec) {
    final net = sec.networkHealth;
    if (net == null) return const SizedBox.shrink();

    return _buildSectionCard('Network Health', Icons.wifi, const Color(0xFF2196F3),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNetStat('Download', '${net.downloadSpeed.toStringAsFixed(0)} Mbps', Colors.green),
              _buildNetStat('Upload', '${net.uploadSpeed.toStringAsFixed(0)} Mbps', Colors.blue),
              _buildNetStat('Latency', '${net.latency.toStringAsFixed(0)} ms', net.latencyColor),
              _buildNetStat('Devices', '${net.connectedDevices}', Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Uptime: ${net.uptime}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text('Router: ${net.routerModel}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text('Band: ${net.wifiBand}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          ...net.devices.take(5).map((d) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: d.isOnline ? Colors.green : Colors.red)),
                const SizedBox(width: 8),
                Expanded(child: Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 11))),
                Text(d.ipAddress, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(width: 8),
                Text('${d.bandwidth.toStringAsFixed(0)} Mbps', style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildNetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildFirmwareManager(SecurityLifestyleService sec) {
    return _buildSectionCard('Firmware Manager', Icons.system_update, const Color(0xFF4CAF50),
      Column(
        children: sec.firmwareDevices.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: f.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(f.statusIcon, color: f.statusColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Current: ${f.currentVersion} → Latest: ${f.latestVersion}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    if (f.isUpdating) ...[
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: f.updateProgress, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)), minHeight: 4),
                      ),
                    ],
                  ],
                ),
              ),
              if (f.hasUpdate && !f.isUpdating) GestureDetector(
                onTap: () => sec.startFirmwareUpdate(f.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Update', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              if (f.isUpdating) Text('${(f.updateProgress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFamilyMembers(SecurityLifestyleService sec) {
    return _buildSectionCard('Family Members', Icons.family_restroom, const Color(0xFFEC407A),
      Column(
        children: sec.familyMembers.map((m) => GestureDetector(
          onTap: () => sec.toggleFamilyMemberHome(m.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: m.isHome ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                  child: Text(m.name[0], style: TextStyle(color: m.isHome ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(m.role, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      Text(m.isHome ? 'Home • ${m.currentRoom}' : 'Away • ${m.lastSeen}', style: TextStyle(color: m.isHome ? Colors.green : Colors.white38, fontSize: 10)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (m.hasGeofence) const Icon(Icons.location_on, size: 14, color: Colors.blue),
                        if (m.hasFaceRecognition) const Icon(Icons.face, size: 14, color: Colors.purple),
                        if (m.hasAppAccess) const Icon(Icons.phone_android, size: 14, color: Colors.green),
                      ],
                    ),
                    Text('${m.devicesAllowed} devices', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildEnergyAudit(SecurityLifestyleService sec) {
    final audit = sec.energyAudit;
    if (audit == null) return const SizedBox.shrink();

    return _buildSectionCard('Energy Audit Report', Icons.assessment, const Color(0xFFFF9800),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAuditStat('Grade', audit.grade, audit.gradeColor),
              _buildAuditStat('Monthly', '\$${audit.monthlyCost.toStringAsFixed(0)}', Colors.white70),
              _buildAuditStat('Potential Save', '\$${audit.potentialSavings.toStringAsFixed(0)}', Colors.green),
              _buildAuditStat('Efficiency', '${audit.efficiencyScore.toStringAsFixed(0)}%', audit.efficiencyColor),
            ],
          ),
          const SizedBox(height: 12),
          ...audit.findings.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(f.isPositive ? Icons.check_circle : Icons.error_outline, color: f.isPositive ? Colors.green : Colors.orange, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f.finding, style: const TextStyle(color: Colors.white, fontSize: 11))),
              ],
            ),
          )),
          const SizedBox(height: 8),
          ...audit.recommendations.map((r) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withValues(alpha: 0.2))),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.recommendation, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      Text('Save \$${r.estimatedSavings.toStringAsFixed(0)}/yr | ROI: ${r.roiMonths} mo', style: const TextStyle(color: Colors.green, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAuditStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildHomeInventory(AdvancedHomeService adv) {
    return _buildSectionCard('Home Inventory', Icons.inventory, const Color(0xFF795548),
      Column(
        children: adv.inventory.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Icon(item.icon, color: item.categoryColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('${item.room} • ${item.category}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
              Text('\$${item.value.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSmartNotifications(AdvancedHomeService adv) {
    return _buildSectionCard('Smart Notifications', Icons.notifications_active, const Color(0xFF2196F3),
      Column(
        children: adv.smartNotifications.take(5).map((n) => GestureDetector(
          onTap: () => adv.markNotificationRead(n.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: n.isRead ? AppTheme.darkSurface : n.priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: n.isRead ? null : Border.all(color: n.priorityColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(n.icon, color: n.priorityColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600)),
                      Text(n.message, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
                if (!n.isRead) Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: n.priorityColor),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildApplianceLifecycle(AdvancedHomeService adv) {
    return _buildSectionCard('Appliance Lifecycle', Icons.timer, const Color(0xFF607D8B),
      Column(
        children: adv.lifecycles.map((lc) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40, height: 40,
                    child: CircularProgressIndicator(
                      value: lc.lifespanPercentage / 100,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation(lc.lifespanColor),
                      strokeWidth: 3,
                    ),
                  ),
                  Text('${lc.lifespanPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lc.applianceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Age: ${lc.ageInYears.toStringAsFixed(1)} yrs | Expected: ${lc.expectedLifespan} yrs', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Warranty: ${lc.warrantyStatus} | Efficiency: ${lc.currentEfficiency.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              Text('\$${lc.replacementCost.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildServiceProviders(SecurityLifestyleService sec) {
    return _buildSectionCard('Service Providers', Icons.handyman, const Color(0xFFFF9800),
      Column(
        children: sec.serviceProviders.map((sp) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: sp.categoryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(sp.icon, color: sp.categoryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sp.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(sp.specialty, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        Text(' ${sp.rating.toStringAsFixed(1)} • ${sp.phone}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: sp.isAvailable ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(sp.isAvailable ? 'Available' : 'Busy', style: TextStyle(color: sp.isAvailable ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }
}
