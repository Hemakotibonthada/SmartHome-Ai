import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/utils/responsive.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';
import 'package:smart_home_ai/shared/widgets/web_content_wrapper.dart';
import 'package:smart_home_ai/shared/widgets/hover_card.dart';
import 'package:smart_home_ai/shared/widgets/empty_state_widget.dart';
import 'package:smart_home_ai/core/services/advanced_home_service.dart';

class AIHubScreen extends StatelessWidget {
  const AIHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<AdvancedHomeService>();
    final isDemo = context.watch<DemoModeService>().isDemoMode;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: !isDemo && svc.predictions.isEmpty
              ? Column(
                  children: [
                    _buildHeader(context),
                    const Expanded(child: EmptyStateWidget(
                      icon: Icons.psychology_outlined,
                      title: 'No AI Insights Yet',
                      message: 'AI insights will be generated once sufficient sensor data has been collected. Enable Demo Mode to explore.',
                    )),
                  ],
                )
              : CustomScrollView(
            physics: WebContentWrapper.scrollPhysics,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Responsive.isDesktop(context)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(children: [
                                _buildPredictiveMaintenance(svc),
                                _buildHabitLearning(svc),
                                _buildWeatherAutomation(svc),
                                _buildHVACZones(svc),
                                _buildAutomationRules(svc),
                                _buildWeatherStation(svc),
                              ]),
                            ),
                            Expanded(
                              child: Column(children: [
                                _buildAnomalyDetection(svc),
                                _buildVoiceCommands(svc),
                                _buildCircadianLighting(svc),
                                _buildSleepQuality(svc),
                                _buildPlantCare(svc),
                              ]),
                            ),
                          ],
                        ),
                      )
                    : Column(children: [
                        _buildPredictiveMaintenance(svc),
                        _buildAnomalyDetection(svc),
                        _buildHabitLearning(svc),
                        _buildVoiceCommands(svc),
                        _buildWeatherAutomation(svc),
                        _buildCircadianLighting(svc),
                        _buildHVACZones(svc),
                        _buildSleepQuality(svc),
                        _buildAutomationRules(svc),
                        _buildPlantCare(svc),
                        _buildWeatherStation(svc),
                      ]),
              ),
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
                const Text('AI Intelligence Hub', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Predictive AI • Automation • Learning', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveMaintenance(AdvancedHomeService svc) {
    return _buildSectionCard('Predictive Maintenance AI', Icons.engineering, const Color(0xFFFF9800),
      Column(
        children: svc.predictions.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 4, height: 50,
                decoration: BoxDecoration(color: p.severityColor, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(p.component, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    Text(p.recommendation, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: p.severityColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(p.severity, style: TextStyle(color: p.severityColor, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text('${p.daysUntilFailure}d', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${(p.confidence * 100).toStringAsFixed(0)}% conf', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAnomalyDetection(AdvancedHomeService svc) {
    return _buildSectionCard('Anomaly Detection', Icons.warning_amber, const Color(0xFFF44336),
      Column(
        children: svc.anomalies.map((a) => GestureDetector(
          onTap: () => a.isAcknowledged ? null : svc.acknowledgeAnomaly(a.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: a.isAcknowledged ? AppTheme.darkSurface : a.alertColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: a.isAcknowledged ? null : Border.all(color: a.alertColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(a.severity > 0.7 ? Icons.error : Icons.warning, color: a.alertColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${a.deviceName} - ${a.anomalyType}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(a.description, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      Text('Action: ${a.suggestedAction}', style: TextStyle(color: a.alertColor, fontSize: 11)),
                    ],
                  ),
                ),
                if (a.isAcknowledged) const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHabitLearning(AdvancedHomeService svc) {
    return _buildSectionCard('Learned Habits', Icons.psychology, const Color(0xFF9C27B0),
      Column(
        children: svc.learnedHabits.map((h) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: h.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(h.icon, color: h.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.description, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(h.pattern, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Row(
                      children: [
                        Text('${(h.confidence * 100).toStringAsFixed(0)}% confidence', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        const SizedBox(width: 8),
                        Text('${h.occurrences}x observed', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => svc.toggleHabitAutomation(h.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: h.isAutomated ? AppTheme.successColor.withValues(alpha: 0.2) : Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(h.isAutomated ? 'Auto' : 'Manual', style: TextStyle(color: h.isAutomated ? AppTheme.successColor : Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildVoiceCommands(AdvancedHomeService svc) {
    return _buildSectionCard('Voice Command History', Icons.mic, const Color(0xFF2196F3),
      Column(
        children: svc.voiceCommands.map((v) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(v.wasSuccessful ? Icons.check_circle : Icons.cancel, color: v.wasSuccessful ? Colors.green : Colors.red, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('"${v.transcript}"', style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
                    Text(v.action, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              Text('${(v.confidence * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWeatherAutomation(AdvancedHomeService svc) {
    return _buildSectionCard('Weather-Reactive Automation', Icons.cloud, const Color(0xFF00BCD4),
      Column(
        children: svc.weatherAutomations.map((w) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(w.icon, color: w.color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${w.weatherCondition} > ${w.threshold}${w.unit}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(w.actions.join(' • '), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => svc.toggleWeatherAutomation(w.id),
                child: Switch(
                  value: w.isEnabled,
                  onChanged: (_) => svc.toggleWeatherAutomation(w.id),
                  activeColor: AppTheme.successColor,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCircadianLighting(AdvancedHomeService svc) {
    final cl = svc.circadianLighting;
    if (cl == null) return const SizedBox.shrink();

    return _buildSectionCard('Circadian Lighting', Icons.wb_twilight, const Color(0xFFFFAB91),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCircadianInfo('Phase', cl.currentPhase, cl.currentColor),
              _buildCircadianInfo('Color Temp', '${cl.currentColorTemp}K', Colors.white70),
              _buildCircadianInfo('Brightness', '${cl.currentBrightness}%', Colors.white70),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [Color(0xFFFFAB91), Color(0xFFFFF9C4), Color(0xFFFFFFFF), Color(0xFFFFE0B2), Color(0xFF3F51B5)]),
            ),
            child: Center(child: Text('Wake: ${cl.wakeTime.hour}:${cl.wakeTime.minute.toString().padLeft(2, '0')}  →  Sleep: ${cl.sleepTime.hour}:${cl.sleepTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 12))),
          ),
        ],
      ),
    );
  }

  Widget _buildCircadianInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildHVACZones(AdvancedHomeService svc) {
    return _buildSectionCard('Multi-Zone HVAC', Icons.thermostat, const Color(0xFF2196F3),
      Column(
        children: svc.hvacZones.map((z) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: z.modeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.thermostat, color: z.modeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${z.name} - ${z.room}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${z.currentTemp.toStringAsFixed(1)}°C → ${z.targetTemp.toStringAsFixed(0)}°C | ${z.mode}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('Fan: ${z.fanSpeed} | ${z.energyUsage.toStringAsFixed(1)} kWh today', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => svc.toggleHVACZone(z.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: z.isActive ? Colors.green.withValues(alpha: 0.2) : Colors.white12, borderRadius: BorderRadius.circular(8)),
                  child: Text(z.isActive ? 'ON' : 'OFF', style: TextStyle(color: z.isActive ? Colors.green : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSleepQuality(AdvancedHomeService svc) {
    if (svc.sleepHistory.isEmpty) return const SizedBox.shrink();
    final latest = svc.sleepHistory.last;

    return _buildSectionCard('Sleep Quality Analysis', Icons.bedtime, const Color(0xFF3F51B5),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSleepStat('Score', '${latest.score.toStringAsFixed(0)}', latest.scoreColor),
              _buildSleepStat('Total', '${latest.totalSleep.inHours}h ${latest.totalSleep.inMinutes % 60}m', Colors.white70),
              _buildSleepStat('Deep', '${latest.deepSleep.inHours}h ${latest.deepSleep.inMinutes % 60}m', const Color(0xFF3F51B5)),
              _buildSleepStat('Wake', '${latest.awakenings}x', Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(latest.recommendation, style: const TextStyle(color: Colors.white70, fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: Row(
              children: svc.sleepHistory.map((s) {
                final height = (s.score / 100 * 40).clamp(10.0, 40.0);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: height,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(color: s.scoreColor, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(height: 2),
                      Text(['M','T','W','T','F','S','S'][svc.sleepHistory.indexOf(s) % 7], style: const TextStyle(color: Colors.white38, fontSize: 8)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildAutomationRules(AdvancedHomeService svc) {
    return _buildSectionCard('IFTTT Automation Rules', Icons.auto_fix_high, const Color(0xFFFF9800),
      Column(
        children: svc.automationRules.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(r.icon, color: r.color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('IF ${r.triggerDevice} ${r.triggerCondition} ${r.triggerValue}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Text('THEN ${r.actionDevice}: ${r.actionCommand}', style: TextStyle(color: r.color, fontSize: 11)),
                    Text('Triggered ${r.executionCount}x', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => svc.toggleAutomationRule(r.id),
                child: Switch(value: r.isEnabled, onChanged: (_) => svc.toggleAutomationRule(r.id), activeColor: AppTheme.successColor),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPlantCare(AdvancedHomeService svc) {
    return _buildSectionCard('Smart Plant Care', Icons.eco, const Color(0xFF4CAF50),
      Column(
        children: svc.plants.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: p.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                child: Icon(p.icon, color: p.statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.plantName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(p.species, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    Row(
                      children: [
                        Text('💧 ${p.soilMoisture.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        const SizedBox(width: 8),
                        Text('☀ ${p.lightLevel.toStringAsFixed(0)} lux', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        const SizedBox(width: 8),
                        Text('🌡 ${p.temperature.toStringAsFixed(0)}°C', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: p.statusColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(p.healthStatus, style: TextStyle(color: p.statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildWeatherStation(AdvancedHomeService svc) {
    final ws = svc.weatherStation;
    if (ws == null) return const SizedBox.shrink();

    return _buildSectionCard('Weather Station', Icons.wb_sunny, ws.conditionColor,
      Column(
        children: [
          Row(
            children: [
              Icon(ws.conditionIcon, color: ws.conditionColor, size: 48),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${ws.temperature.toStringAsFixed(1)}°C', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  Text(ws.condition, style: TextStyle(color: ws.conditionColor, fontSize: 16)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('💧 ${ws.humidity.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('💨 ${ws.windSpeed.toStringAsFixed(0)} km/h ${ws.windDirection}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('UV: ${ws.uvIndex.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherStat('Pressure', '${ws.pressure.toStringAsFixed(0)} hPa'),
              _buildWeatherStat('Rain', '${ws.rainfall.toStringAsFixed(1)} mm'),
              _buildWeatherStat('Dew Point', '${ws.dewPoint.toStringAsFixed(1)}°C'),
              _buildWeatherStat('Visibility', '${ws.visibility.toStringAsFixed(0)} km'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ws.hourlyForecast.map((f) => Container(
                width: 50,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${f.hour}h', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    Icon(f.icon, color: Colors.white70, size: 16),
                    Text('${f.temp.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
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
}
