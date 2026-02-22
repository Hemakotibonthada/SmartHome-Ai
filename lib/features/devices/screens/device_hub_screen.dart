import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/advanced_home_service.dart';

class DeviceHubScreen extends StatelessWidget {
  const DeviceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdvancedHomeService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildRobotVacuumCard(svc)),
              SliverToBoxAdapter(child: _buildSmartBlindsSection(svc)),
              SliverToBoxAdapter(child: _buildKitchenAppliances(svc)),
              SliverToBoxAdapter(child: _buildGarageDoors(svc)),
              SliverToBoxAdapter(child: _buildSprinklerZones(svc)),
              SliverToBoxAdapter(child: _buildPetFeeders(svc)),
              SliverToBoxAdapter(child: _buildBabyMonitor(svc)),
              SliverToBoxAdapter(child: _buildEVCharger(svc)),
              SliverToBoxAdapter(child: _buildAirPurifiers(svc)),
              SliverToBoxAdapter(child: _buildPoolController(svc)),
              SliverToBoxAdapter(child: _buildDoorbellEvents(svc)),
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
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Smart Device Hub', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('All connected devices', style: TextStyle(fontSize: 14, color: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.successColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: AppTheme.successColor, size: 8),
                SizedBox(width: 6),
                Text('All Online', style: TextStyle(color: AppTheme.successColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRobotVacuumCard(AdvancedHomeService svc) {
    final vacuum = svc.robotVacuum;
    if (vacuum == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: vacuum.statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: vacuum.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.cleaning_services, color: vacuum.statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vacuum.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(vacuum.status, style: TextStyle(fontSize: 14, color: vacuum.statusColor)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.battery_std, color: vacuum.batteryLevel > 50 ? Colors.green : Colors.orange, size: 20),
                    Text('${vacuum.batteryLevel}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildVacuumStat('Area', '${vacuum.areaCleaned.toStringAsFixed(1)} m²'),
                _buildVacuumStat('Mode', vacuum.mode),
                _buildVacuumStat('Dustbin', '${vacuum.dustbinLevel.toStringAsFixed(0)}%'),
                _buildVacuumStat('Room', vacuum.currentRoom),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => vacuum.status == 'Docked' ? svc.startRobotVacuum() : svc.stopRobotVacuum(),
                    icon: Icon(vacuum.status == 'Docked' ? Icons.play_arrow : Icons.stop, size: 18),
                    label: Text(vacuum.status == 'Docked' ? 'Start' : 'Stop'),
                    style: ElevatedButton.styleFrom(backgroundColor: vacuum.status == 'Docked' ? AppTheme.primaryColor : Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacuumStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSmartBlindsSection(AdvancedHomeService svc) {
    return _buildSection('Smart Blinds', Icons.blinds, svc.blinds.map((b) {
      return _buildDeviceCard(
        b.name, b.room, Icons.blinds_closed,
        '${b.position}% open', b.isAutoMode ? 'Auto' : 'Manual',
        b.position > 50 ? const Color(0xFFFFB74D) : const Color(0xFF90CAF9),
      );
    }).toList());
  }

  Widget _buildKitchenAppliances(AdvancedHomeService svc) {
    final items = <Widget>[];
    final oven = svc.smartOven;
    if (oven != null) {
      items.add(_buildDeviceCard(oven.name, oven.mode, Icons.microwave, oven.isOn ? '${oven.currentTemp.toStringAsFixed(0)}°C' : 'Off', oven.isOn ? 'Cooking' : 'Standby', oven.statusColor));
    }
    final washer = svc.washingMachine;
    if (washer != null) {
      items.add(_buildDeviceCard(washer.name, washer.cycle, Icons.local_laundry_service, washer.status, washer.status == 'Idle' ? 'Ready' : '${washer.remainingMinutes}min left', washer.statusColor));
    }
    final dish = svc.dishwasher;
    if (dish != null) {
      items.add(_buildDeviceCard(dish.name, dish.cycle, Icons.countertops, dish.status, dish.status == 'Idle' ? 'Ready' : '${dish.remainingMinutes}min left', dish.statusColor));
    }
    return _buildSection('Kitchen & Appliances', Icons.kitchen, items);
  }

  Widget _buildGarageDoors(AdvancedHomeService svc) {
    return _buildSection('Garage Doors', Icons.garage, svc.garageDoors.map((g) {
      return GestureDetector(
        onTap: () => svc.toggleGarageDoor(g.id),
        child: _buildDeviceCard(g.name, g.vehiclePresent, Icons.garage, g.isOpen ? 'Open' : 'Closed', g.autoCloseEnabled ? 'Auto-close ON' : 'Manual', g.isOpen ? const Color(0xFFFF9800) : const Color(0xFF4CAF50)),
      );
    }).toList());
  }

  Widget _buildSprinklerZones(AdvancedHomeService svc) {
    return _buildSection('Sprinkler System', Icons.grass, svc.sprinklerZones.map((s) {
      return GestureDetector(
        onTap: () => svc.toggleSprinklerZone(s.id),
        child: _buildDeviceCard(s.name, s.plantType, Icons.grass, 'Moisture: ${s.moistureLevel.toStringAsFixed(0)}%', s.isActive ? 'Active' : s.schedule, s.isActive ? const Color(0xFF4CAF50) : const Color(0xFF607D8B)),
      );
    }).toList());
  }

  Widget _buildPetFeeders(AdvancedHomeService svc) {
    return _buildSection('Pet Feeders', Icons.pets, svc.petFeeders.map((p) {
      return GestureDetector(
        onTap: () => svc.feedPet(p.id),
        child: _buildDeviceCard(p.petName, p.foodType, Icons.pets, 'Food: ${p.foodLevel.toStringAsFixed(0)}%', 'Water: ${p.waterLevel.toStringAsFixed(0)}%', p.foodLevel > 30 ? const Color(0xFFFFB74D) : const Color(0xFFF44336)),
      );
    }).toList());
  }

  Widget _buildBabyMonitor(AdvancedHomeService svc) {
    final baby = svc.babyMonitor;
    if (baby == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: baby.statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.child_care, color: baby.statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text('Baby Monitor - ${baby.babyName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: baby.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text(baby.sleepStatus, style: TextStyle(color: baby.statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBabyMonitorStat('Temp', '${baby.roomTemp.toStringAsFixed(1)}°C', Icons.thermostat),
                _buildBabyMonitorStat('Humidity', '${baby.humidity.toStringAsFixed(0)}%', Icons.water_drop),
                _buildBabyMonitorStat('Noise', '${baby.noiseLevel.toStringAsFixed(0)} dB', Icons.volume_up),
                _buildBabyMonitorStat('Sleep', '${baby.sleepDuration.inHours}h ${baby.sleepDuration.inMinutes % 60}m', Icons.bedtime),
              ],
            ),
            if (baby.isCrying) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Baby is crying!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBabyMonitorStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white54, size: 18),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEVCharger(AdvancedHomeService svc) {
    final ev = svc.evCharger;
    if (ev == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ev.statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.ev_station, color: ev.statusColor, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text('EV Charger - ${ev.vehicleName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                Text(ev.status, style: TextStyle(color: ev.statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            // Charge progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: ev.chargeLevel / 100, backgroundColor: Colors.white12, color: ev.statusColor, minHeight: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${ev.chargeLevel.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text('${ev.chargingPower.toStringAsFixed(1)} kW', style: const TextStyle(color: Colors.white70)),
                Text('${ev.estimatedMinutes} min left', style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildVacuumStat('Energy', '${ev.energyDelivered.toStringAsFixed(1)} kWh'),
                _buildVacuumStat('Cost', '₹${ev.estimatedCost.toStringAsFixed(0)}'),
                _buildVacuumStat('Schedule', ev.isScheduled ? '${ev.scheduledStart!.hour}:${ev.scheduledStart!.minute.toString().padLeft(2, '0')}' : 'Off'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirPurifiers(AdvancedHomeService svc) {
    return _buildSection('Air Purifiers', Icons.air, svc.airPurifiers.map((a) {
      return GestureDetector(
        onTap: () => svc.toggleAirPurifier(a.id),
        child: _buildDeviceCard(a.name, 'Filter: ${a.filterLife}%', Icons.air, 'AQI: ${a.aqi}', a.isOn ? a.mode : 'Off', a.aqiColor),
      );
    }).toList());
  }

  Widget _buildPoolController(AdvancedHomeService svc) {
    final pool = svc.poolController;
    if (pool == null) return const SizedBox.shrink();

    return _buildSection('Pool Controller', Icons.pool, [
      _buildDeviceCard('Water Temp', '', Icons.thermostat, '${pool.waterTemp.toStringAsFixed(1)}°C', 'Target', const Color(0xFF29B6F6)),
      _buildDeviceCard('pH Level', '', Icons.science, pool.pH.toStringAsFixed(1), pool.pH >= 7.0 && pool.pH <= 7.6 ? 'Optimal' : 'Adjust', pool.phColor),
      _buildDeviceCard('Pump', '', Icons.loop, pool.pumpRunning ? 'Running' : 'Off', '${pool.pumpTimer}h left', pool.pumpRunning ? const Color(0xFF4CAF50) : const Color(0xFF607D8B)),
      _buildDeviceCard('Filter', '', Icons.filter_alt, pool.filterStatus, 'Level: ${pool.waterLevel.toStringAsFixed(0)}%', const Color(0xFF26A69A)),
    ]);
  }

  Widget _buildDoorbellEvents(AdvancedHomeService svc) {
    if (svc.doorbellEvents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.doorbell, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Doorbell Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          ...svc.doorbellEvents.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: e.eventColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Icon(_getDoorbellIcon(e.eventType), color: e.eventColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.eventType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(e.visitorName ?? 'No visitor identified', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                Text(_formatTime(e.timestamp), style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  IconData _getDoorbellIcon(String type) {
    switch (type) {
      case 'Ring': return Icons.doorbell;
      case 'Package': return Icons.inventory_2;
      case 'Motion': return Icons.directions_run;
      case 'Person': return Icons.person;
      default: return Icons.notifications;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(String name, String subtitle, IconData icon, String value, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
