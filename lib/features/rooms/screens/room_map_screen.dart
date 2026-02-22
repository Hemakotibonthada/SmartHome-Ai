import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';

class RoomMapScreen extends StatelessWidget {
  const RoomMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SmartFeaturesService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildRoomGrid(svc),
                    const SizedBox(height: 20),
                    _buildOccupancySection(svc),
                    const SizedBox(height: 20),
                    _buildComfortSection(svc),
                    const SizedBox(height: 20),
                    _buildAdaptiveThresholds(svc),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Expanded(child: Text('Room Map', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.map, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }

  // ===== ROOM TEMPERATURE HEATMAP (Feature 7) =====
  Widget _buildRoomGrid(SmartFeaturesService svc) {
    final rooms = [
      _RoomData('Living Room', 24.5, 55, Icons.living, true, 3),
      _RoomData('Bedroom', 22.0, 50, Icons.bed, false, 1),
      _RoomData('Kitchen', 26.8, 62, Icons.kitchen, true, 2),
      _RoomData('Bathroom', 25.2, 78, Icons.bathtub, false, 0),
      _RoomData('Study', 23.5, 48, Icons.computer, true, 1),
      _RoomData('Balcony', 30.1, 40, Icons.balcony, false, 0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Temperature Heatmap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Live room temperatures and conditions', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.1,
          ),
          itemCount: rooms.length,
          itemBuilder: (ctx, i) => _buildRoomCard(rooms[i]),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(const Color(0xFF2196F3), '< 22°C'),
            const SizedBox(width: 16),
            _legendItem(const Color(0xFF4CAF50), '22-26°C'),
            const SizedBox(width: 16),
            _legendItem(const Color(0xFFFF9800), '26-28°C'),
            const SizedBox(width: 16),
            _legendItem(const Color(0xFFF44336), '> 28°C'),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomCard(_RoomData room) {
    final tempColor = room.temp < 22
        ? const Color(0xFF2196F3)
        : room.temp < 26
            ? const Color(0xFF4CAF50)
            : room.temp < 28
                ? const Color(0xFFFF9800)
                : const Color(0xFFF44336);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tempColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(room.icon, color: tempColor, size: 20),
              const Spacer(),
              if (room.occupied)
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF4CAF50),
                    boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withValues(alpha: 0.4), blurRadius: 6)]),
                ),
            ],
          ),
          const Spacer(),
          Text(room.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${room.temp.toStringAsFixed(1)}°C', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: tempColor)),
          Text('${room.humidity}% RH • ${room.devices} devices',
            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
      ],
    );
  }

  // ===== ROOM OCCUPANCY (Feature 18) =====
  Widget _buildOccupancySection(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: Color(0xFF2196F3), size: 18),
              const SizedBox(width: 8),
              const Text('Room Occupancy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${svc.roomOccupancy.where((r) => r.isOccupied).length} rooms active',
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
            ],
          ),
          const SizedBox(height: 16),
          ...svc.roomOccupancy.map((room) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: room.isOccupied ? const Color(0xFF2196F3).withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: room.isOccupied ? const Color(0xFF4CAF50) : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.roomName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      Text(
                        room.isOccupied
                            ? '${room.occupantCount} ${room.occupantCount == 1 ? "person" : "people"} • ${_formatDuration(room.lastMotion)}'
                            : 'Empty',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                ),
                if (room.isOccupied)
                  Text('${room.occupantCount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ===== COMFORT INDEX (Feature 4) =====
  Widget _buildComfortSection(SmartFeaturesService svc) {
    final comfort = svc.comfortIndex;
    if (comfort == null) return const SizedBox.shrink();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat_auto, color: Color(0xFF4CAF50), size: 18),
              const SizedBox(width: 8),
              const Text('Comfort Index', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100, height: 100,
                  child: CircularProgressIndicator(
                    value: comfort.score / 100, strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation(comfort.scoreColor),
                  ),
                ),
                Column(
                  children: [
                    Text('${comfort.score}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: comfort.scoreColor)),
                    Text(comfort.level, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _comfortMetric('Temp', '${comfort.temperature.toStringAsFixed(1)}°C', Icons.thermostat)),
              Expanded(child: _comfortMetric('Humidity', '${comfort.humidity.toStringAsFixed(0)}%', Icons.water_drop)),
              Expanded(child: _comfortMetric('Light', '${comfort.lightLevel.toStringAsFixed(0)} lx', Icons.light_mode)),
              Expanded(child: _comfortMetric('Noise', '${comfort.noiseLevel.toStringAsFixed(0)} dB', Icons.volume_up)),
            ],
          ),
          const SizedBox(height: 12),
          Text(comfort.suggestion, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _comfortMetric(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
      ],
    );
  }

  // ===== ADAPTIVE THRESHOLDS (Feature 19) =====
  Widget _buildAdaptiveThresholds(SmartFeaturesService svc) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: Color(0xFFFF9800), size: 18),
              const SizedBox(width: 8),
              const Text('Adaptive Thresholds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Auto-adjusting alert levels based on usage patterns', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 16),
          ...svc.adaptiveThresholds.values.map((threshold) {
            final isAdapted = threshold.learningProgress > 0.75;
            final minVal = threshold.currentThreshold * 0.8;
            final maxVal = threshold.currentThreshold * 1.2;
            return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('${threshold.sensorType} (${threshold.unit})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAdapted ? const Color(0xFF4CAF50).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(isAdapted ? 'Adapted' : 'Learning ${(threshold.learningProgress * 100).toInt()}%',
                      style: TextStyle(fontSize: 10, color: isAdapted ? const Color(0xFF4CAF50) : Colors.white54)),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current: ${threshold.currentThreshold.toStringAsFixed(1)} ${threshold.unit}',
                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                          Text('Suggested: ${threshold.suggestedThreshold.toStringAsFixed(1)} ${threshold.unit}',
                            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: threshold.learningProgress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation(
                            isAdapted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          }),
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

  String _formatDuration(DateTime? since) {
    if (since == null) return '';
    final d = DateTime.now().difference(since);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}

class _RoomData {
  final String name;
  final double temp;
  final int humidity;
  final IconData icon;
  final bool occupied;
  final int devices;
  _RoomData(this.name, this.temp, this.humidity, this.icon, this.occupied, this.devices);
}
