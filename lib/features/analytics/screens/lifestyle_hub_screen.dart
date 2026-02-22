import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/advanced_home_service.dart';
import 'package:smart_home_ai/core/services/security_lifestyle_service.dart';

class LifestyleHubScreen extends StatelessWidget {
  const LifestyleHubScreen({super.key});

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
              SliverToBoxAdapter(child: _buildMultiRoomAudio(adv)),
              SliverToBoxAdapter(child: _buildHomeTheater(adv)),
              SliverToBoxAdapter(child: _buildGamingMode(adv)),
              SliverToBoxAdapter(child: _buildWellness(adv)),
              SliverToBoxAdapter(child: _buildWorkout(adv)),
              SliverToBoxAdapter(child: _buildAquarium(adv)),
              SliverToBoxAdapter(child: _buildWasteManagement(adv)),
              SliverToBoxAdapter(child: _buildRainwaterHarvesting(sec)),
              SliverToBoxAdapter(child: _buildCarbonTracking(sec)),
              SliverToBoxAdapter(child: _buildGreenEnergyScore(sec)),
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
                const Text('Lifestyle & Sustainability', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Entertainment • Wellness • Green Living', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF00BCD4)]), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.spa, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiRoomAudio(AdvancedHomeService svc) {
    return _buildSectionCard('Multi-Room Audio', Icons.speaker_group, const Color(0xFF2196F3),
      Column(
        children: svc.audioZones.map((z) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => svc.toggleAudioZone(z.id),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: z.isPlaying ? const Color(0xFF2196F3).withValues(alpha: 0.2) : Colors.white12, borderRadius: BorderRadius.circular(10)),
                  child: Icon(z.isPlaying ? Icons.pause : Icons.play_arrow, color: z.isPlaying ? const Color(0xFF2196F3) : Colors.white54, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(z.zoneName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    if (z.isPlaying) Text('${z.currentTrack} • ${z.artist}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(z.source, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Row(
                  children: [
                    const Icon(Icons.volume_down, color: Colors.white38, size: 14),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5), overlayShape: SliderComponentShape.noOverlay),
                        child: Slider(
                          value: z.volume.toDouble(),
                          max: 100,
                          activeColor: const Color(0xFF2196F3),
                          inactiveColor: Colors.white24,
                          onChanged: (v) => svc.setAudioVolume(z.id, v.toInt()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHomeTheater(AdvancedHomeService svc) {
    final ht = svc.homeTheater;
    if (ht == null) return const SizedBox.shrink();

    return _buildSectionCard('Home Theater', Icons.movie, const Color(0xFF9C27B0),
      Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: ht.isActive ? const Color(0xFF9C27B0).withValues(alpha: 0.2) : Colors.white12, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.movie_filter, color: ht.isActive ? const Color(0xFF9C27B0) : Colors.white54, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ht.isActive ? 'Theater Active' : 'Theater Standby', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Mode: ${ht.mode}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('Projector: ${ht.projectorStatus} | Sound: ${ht.soundMode}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => svc.toggleHomeTheater(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: ht.isActive ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(ht.isActive ? 'Stop' : 'Start', style: TextStyle(color: ht.isActive ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
          if (ht.isActive) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTheaterStat('Screen', ht.screenPosition),
                _buildTheaterStat('Lights', '${ht.ambientBrightness}%'),
                _buildTheaterStat('Input', ht.currentInput),
                _buildTheaterStat('Volume', '${ht.volume}%'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTheaterStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildGamingMode(AdvancedHomeService svc) {
    final gm = svc.gamingMode;
    if (gm == null) return const SizedBox.shrink();

    return _buildSectionCard('Gaming Mode', Icons.sports_esports, const Color(0xFF00E676),
      Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: gm.isActive ? const Color(0xFF00E676).withValues(alpha: 0.2) : Colors.white12, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.sports_esports, color: gm.isActive ? const Color(0xFF00E676) : Colors.white54, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gm.currentGame, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${gm.platform} | ${gm.displayMode} | ${gm.networkPriority}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => svc.toggleGamingMode(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: gm.isActive ? const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00BCD4)]) : null, color: gm.isActive ? null : Colors.white12, borderRadius: BorderRadius.circular(8)),
                  child: Text(gm.isActive ? 'ACTIVE' : 'OFF', style: TextStyle(color: gm.isActive ? Colors.black : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          if (gm.isActive) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGameStat('RGB', gm.rgbLighting, const Color(0xFF00E676)),
                _buildGameStat('Latency', '${gm.networkLatency}ms', Colors.white),
                _buildGameStat('Lights', '${gm.ambientBrightness}%', Colors.white70),
                _buildGameStat('DND', gm.doNotDisturb ? 'ON' : 'OFF', gm.doNotDisturb ? Colors.green : Colors.red),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildWellness(AdvancedHomeService svc) {
    final w = svc.wellness;
    if (w == null) return const SizedBox.shrink();

    return _buildSectionCard('Wellness Center', Icons.self_improvement, const Color(0xFFEC407A),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWellnessStat('Overall', '${w.overallScore.toStringAsFixed(0)}/100', w.scoreColor),
              _buildWellnessStat('Stress', w.stressLevel.toStringAsFixed(0), w.stressColor),
              _buildWellnessStat('Air', '${w.airQualityScore.toStringAsFixed(0)}', Colors.white70),
              _buildWellnessStat('Mood', w.currentMood, Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          ...w.goals.map((g) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(g.icon, color: g.color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: g.progress, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(g.color), minHeight: 4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(g.progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: g.color, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWellnessStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildWorkout(AdvancedHomeService svc) {
    final wo = svc.workout;
    if (wo == null) return const SizedBox.shrink();

    return _buildSectionCard('Workout Environment', Icons.fitness_center, const Color(0xFFFF5722),
      Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFF5722).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.fitness_center, color: Color(0xFFFF5722), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(wo.workoutType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${wo.duration.inMinutes} min | ${wo.caloriesBurned} cal | ${wo.heartRate} bpm', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWorkoutStat('Temp', '${wo.roomTemp.toStringAsFixed(0)}°C'),
              _buildWorkoutStat('Fan', '${wo.fanSpeed}%'),
              _buildWorkoutStat('Music', wo.musicGenre),
              _buildWorkoutStat('Light', '${wo.lightBrightness}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildAquarium(AdvancedHomeService svc) {
    final aq = svc.aquarium;
    if (aq == null) return const SizedBox.shrink();

    return _buildSectionCard('Smart Aquarium', Icons.water, const Color(0xFF00BCD4),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAquaStat('Water Temp', '${aq.waterTemp.toStringAsFixed(1)}°C', Colors.cyan),
              _buildAquaStat('pH', aq.pH.toStringAsFixed(1), aq.pHColor),
              _buildAquaStat('Ammonia', '${aq.ammonia.toStringAsFixed(2)} ppm', aq.ammoniaColor),
              _buildAquaStat('Salinity', '${aq.salinity.toStringAsFixed(1)} ppt', Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAquaInfo('Tank', '${aq.tankSize}L'),
                _buildAquaInfo('Fish', '${aq.fishCount}'),
                _buildAquaInfo('Light', aq.lightMode),
                _buildAquaInfo('Filter', aq.filterStatus),
                _buildAquaInfo('Feed', '${aq.lastFed.hour}:${aq.lastFed.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAquaStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildAquaInfo(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }

  Widget _buildWasteManagement(AdvancedHomeService svc) {
    final wm = svc.wasteManagement;
    if (wm == null) return const SizedBox.shrink();

    return _buildSectionCard('Smart Waste Management', Icons.delete_outline, const Color(0xFF795548),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWasteBin('🗑️ General', wm.generalWaste, wm.generalWasteColor),
              _buildWasteBin('♻️ Recycle', wm.recycling, const Color(0xFF4CAF50)),
              _buildWasteBin('🌱 Compost', wm.composting, const Color(0xFF795548)),
              _buildWasteBin('⚡ E-Waste', wm.eWaste, const Color(0xFFFF9800)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text('Next Collection: ${wm.nextCollection}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                const Spacer(),
                Text('Rate: ${wm.recyclingRate.toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteBin(String label, double fillLevel, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: 30,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                heightFactor: fillLevel / 100,
                child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('${fillLevel.toStringAsFixed(0)}%', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9)),
      ],
    );
  }

  Widget _buildRainwaterHarvesting(SecurityLifestyleService sec) {
    final rw = sec.rainwater;
    if (rw == null) return const SizedBox.shrink();

    return _buildSectionCard('Rainwater Harvesting', Icons.water_drop, const Color(0xFF42A5F5),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRainStat('Tank Level', '${rw.tankLevel.toStringAsFixed(0)}%', rw.tankColor),
              _buildRainStat('Capacity', '${rw.tankCapacity}L', Colors.white70),
              _buildRainStat('Current', '${rw.currentVolume.toStringAsFixed(0)}L', const Color(0xFF42A5F5)),
              _buildRainStat('Saved', '\$${rw.totalSaved.toStringAsFixed(0)}', Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('pH: ${rw.waterQualityPh.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('Filter: ${rw.filterStatus}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('Pump: ${rw.pumpStatus}', style: TextStyle(color: rw.pumpStatus == 'Active' ? Colors.green : Colors.white54, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: rw.tankLevel / 100, backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation(rw.tankColor), minHeight: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRainStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildCarbonTracking(SecurityLifestyleService sec) {
    final ct = sec.carbonTracking;
    if (ct == null) return const SizedBox.shrink();

    return _buildSectionCard('Carbon Footprint Tracker', Icons.co2, const Color(0xFF4CAF50),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCarbonStat('Today', '${ct.todayEmissions.toStringAsFixed(1)} kg', ct.emissionColor),
              _buildCarbonStat('Monthly', '${ct.monthlyEmissions.toStringAsFixed(0)} kg', Colors.white70),
              _buildCarbonStat('Saved', '${ct.totalOffset.toStringAsFixed(0)} kg', Colors.green),
              _buildCarbonStat('Trees', '${ct.treesEquivalent}', Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          ...ct.sources.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(width: 3, height: 20, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 10),
                Expanded(child: Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 12))),
                Text('${s.emissions.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(width: 8),
                Text('${s.percentage.toStringAsFixed(0)}%', style: TextStyle(color: s.color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCarbonStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildGreenEnergyScore(SecurityLifestyleService sec) {
    final gs = sec.greenScore;
    if (gs == null) return const SizedBox.shrink();

    return _buildSectionCard('Green Energy Score', Icons.eco, const Color(0xFF66BB6A),
      Column(
        children: [
          Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gs.scoreColor, width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${gs.score.toStringAsFixed(0)}', style: TextStyle(color: gs.scoreColor, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(gs.grade, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${gs.renewablePercentage.toStringAsFixed(0)}% Renewable', style: TextStyle(color: gs.scoreColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Solar: ${gs.solarGeneration.toStringAsFixed(1)} kWh today', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text('Grid usage reduced by ${gs.gridReduction.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...gs.tips.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(t.icon, color: t.impactColor, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(t.tip, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                Text(t.impact, style: TextStyle(color: t.impactColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
        ],
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
