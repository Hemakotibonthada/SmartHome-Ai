import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/ai_service.dart';
import 'package:smart_home_ai/core/services/ai_prediction_engine.dart';
import 'package:smart_home_ai/core/services/ai_anomaly_engine.dart';
import 'package:smart_home_ai/core/services/ai_nlp_engine.dart';
import 'package:smart_home_ai/core/services/ai_vision_engine.dart';
import 'package:smart_home_ai/core/services/ai_learning_engine.dart';
import 'package:smart_home_ai/core/services/ai_automation_engine.dart';
import 'package:smart_home_ai/core/services/ai_health_engine.dart';
import 'package:smart_home_ai/core/services/ai_security_engine.dart';
import 'package:smart_home_ai/core/services/ai_advanced_analytics.dart';

/// AI Features Hub — Showcases all 100 AI Features across 9 engines.
/// Navigate here from the analytics or settings screen.
class AIFeaturesHubScreen extends StatefulWidget {
  const AIFeaturesHubScreen({super.key});

  @override
  State<AIFeaturesHubScreen> createState() => _AIFeaturesHubScreenState();
}

class _AIFeaturesHubScreenState extends State<AIFeaturesHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nlpController = TextEditingController();
  String _nlpResponse = '';

  final List<_EngineTab> _tabs = const [
    _EngineTab('Overview', Icons.dashboard, Color(0xFF6C63FF)),
    _EngineTab('Predict', Icons.trending_up, Color(0xFF00BCD4)),
    _EngineTab('Anomaly', Icons.warning_amber, Color(0xFFF44336)),
    _EngineTab('NLP', Icons.chat, Color(0xFF2196F3)),
    _EngineTab('Vision', Icons.visibility, Color(0xFF9C27B0)),
    _EngineTab('Learn', Icons.psychology, Color(0xFFFF9800)),
    _EngineTab('Auto', Icons.auto_fix_high, Color(0xFF4CAF50)),
    _EngineTab('Health', Icons.favorite, Color(0xFFE91E63)),
    _EngineTab('Security', Icons.shield, Color(0xFF607D8B)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // Initialize engines
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIPredictionEngine>().initialize();
      context.read<AIAnomalyEngine>().initialize();
      context.read<AINLPEngine>().initialize();
      context.read<AIVisionEngine>().initialize();
      context.read<AILearningEngine>().initialize();
      context.read<AIAutomationEngine>().initialize();
      context.read<AIHealthEngine>().initialize();
      context.read<AISecurityEngine>().initialize();
      context.read<AIAdvancedAnalytics>().initialize();
      context.read<AIService>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nlpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildOverviewTab(),
                    _buildPredictionTab(),
                    _buildAnomalyTab(),
                    _buildNLPTab(),
                    _buildVisionTab(),
                    _buildLearningTab(),
                    _buildAutomationTab(),
                    _buildHealthTab(),
                    _buildSecurityTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HEADER & TAB BAR
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Features Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('100 AI Features • 9 Engines', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 44,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF6C63FF),
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: _tabs
            .map((t) => Tab(
                  child: Row(
                    children: [
                      Icon(t.icon, size: 16, color: t.color),
                      const SizedBox(width: 6),
                      Text(t.label, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: OVERVIEW
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildOverviewTab() {
    final aiService = context.watch<AIService>();
    final summary = aiService.getAIDashboardSummary();
    final score = aiService.getCompositeSmartHomeScore();
    final catalogue = aiService.getFullFeatureCatalogue();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Composite Score Card
        _glassCard(
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, color: Color(0xFF6C63FF), size: 22),
                  const SizedBox(width: 10),
                  const Text('Smart Home Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
                    child: Text('${score['grade']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildScoreBar('Overall', score['overall_score'] as int, const Color(0xFF6C63FF)),
              ...(score['breakdown'] as Map<String, dynamic>).entries.map((e) {
                final data = e.value as Map<String, dynamic>;
                return _buildScoreBar(
                  e.key.replaceAll('_', ' ').toUpperCase(),
                  data['score'] as int,
                  _categoryColor(e.key),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Engine Status Grid
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.hub, color: Color(0xFF00BCD4), size: 22),
                  SizedBox(width: 10),
                  Text('AI Engines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (summary['engines'] as List).map<Widget>((engine) {
                  final eng = engine as Map<String, dynamic>;
                  return Container(
                    width: (MediaQuery.of(context).size.width - 64) / 3,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        Text('${eng['features']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6C63FF))),
                        Text('${eng['name']}'.replaceAll(' Engine', ''), style: const TextStyle(fontSize: 10, color: Colors.white70), textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Active', style: TextStyle(fontSize: 9, color: Colors.green)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Full Feature Catalogue (collapsible by category)
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.list_alt, color: Color(0xFFFF9800), size: 22),
                  SizedBox(width: 10),
                  Text('All 100 Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              ...catalogue.map<Widget>((f) {
                final feat = f;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('#${feat['id']}', style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${feat['name']}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                            Text('${feat['description']}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _categoryColor('${feat['category']}').withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                        child: Text('${feat['category']}'.substring(0, (feat['category'] as String).length.clamp(0, 8)), style: TextStyle(fontSize: 8, color: _categoryColor('${feat['category']}'))),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: PREDICTION ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPredictionTab() {
    final engine = context.watch<AIPredictionEngine>();

    final energyForecast = engine.forecastEnergy(24);
    final tempPrediction = engine.predictTemperature(12);
    final billEstimate = engine.estimateElectricityBill();
    final solarForecast = engine.forecastSolarGeneration();
    final peakLoad = engine.predictPeakLoad();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 1–15: Predictive AI', Icons.trending_up, const Color(0xFF00BCD4)),

        // Energy Forecast
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Energy Forecast (24h)', Icons.bolt, Colors.amber),
              const SizedBox(height: 8),
              ...energyForecast.take(6).map((f) => _kvRow(
                    '${(f['timestamp'] as String).substring(11, 16)}',
                    '${(f['value'] as double).toStringAsFixed(1)} kWh  (${((f['confidence'] as double) * 100).toStringAsFixed(0)}%)',
                  )),
            ],
          ),
        ),

        // Temperature
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Temperature Prediction', Icons.thermostat, Colors.deepOrange),
              const SizedBox(height: 8),
              ...tempPrediction.take(6).map((f) => _kvRow(
                    '${(f['timestamp'] as String).substring(11, 16)}',
                    '${(f['value'] as double).toStringAsFixed(1)}°C  ±${(f['confidence'] as double).toStringAsFixed(2)}',
                  )),
            ],
          ),
        ),

        // Bill
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Bill Estimate', Icons.receipt_long, Colors.green),
              const SizedBox(height: 8),
              _kvRow('Monthly kWh', '${(billEstimate['predicted_monthly_kwh'] as double).toStringAsFixed(0)}'),
              _kvRow('Estimated Bill', '₹${(billEstimate['estimated_bill'] as double).toStringAsFixed(0)}'),
              _kvRow('Savings Potential', '₹${billEstimate['savings_potential']}'),
            ],
          ),
        ),

        // Solar & Peak Load
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Solar & Peak Load', Icons.solar_power, Colors.orange),
              const SizedBox(height: 8),
              _kvRow('Solar Today', '${solarForecast['total_generation_kwh']} kWh'),
              _kvRow('Peak Hour', '${solarForecast['peak_hour']}:00'),
              _kvRow('Peak Load kW', '${(peakLoad['predicted_peak_kw'] as double).toStringAsFixed(1)}'),
              _kvRow('Peak Window', '${peakLoad['peak_window']}'),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: ANOMALY ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAnomalyTab() {
    final engine = context.watch<AIAnomalyEngine>();
    final scan = engine.runFullScan();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 16–25: Anomaly Detection', Icons.warning_amber, const Color(0xFFF44336)),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Full Anomaly Scan', Icons.radar, Colors.red),
              const SizedBox(height: 8),
              _kvRow('Total Anomalies', '${scan['total_anomalies']}'),
              _kvRow('Scanned', scan['timestamp'] as String),
              const Divider(color: Colors.white12),
              ...(scan['results'] as Map<String, dynamic>).entries.map((e) {
                final list = e.value as List;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.key.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.white70))),
                      Text('${list.length} found', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: NLP ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNLPTab() {
    final engine = context.watch<AINLPEngine>();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 26–35: Natural Language', Icons.chat, const Color(0xFF2196F3)),

        // Chat Interface
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Conversational AI', Icons.smart_toy, Colors.blue),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nlpController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about your home...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: AppTheme.darkSurface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (_nlpController.text.trim().isEmpty) return;
                      final response = engine.chat(_nlpController.text.trim());
                      setState(() => _nlpResponse = response['response'] as String);
                      _nlpController.clear();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              if (_nlpResponse.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF2196F3).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2196F3).withValues(alpha: 0.3))),
                  child: Text(_nlpResponse, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),

        // Status Summary
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Home Status Summary', Icons.summarize, Colors.blue),
              const SizedBox(height: 8),
              Text(engine.getStatusSummary({})['summary'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),

        // Languages
        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Multi-Language Support', Icons.translate, Colors.blue),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['English', 'Spanish', 'French', 'German', 'Hindi', 'Telugu'].map((lang) {
                  final translated = engine.translate('Welcome', lang.substring(0, 2).toLowerCase());
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(lang, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                        Text(translated, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: VISION ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildVisionTab() {
    final engine = context.watch<AIVisionEngine>();

    final occupancy = engine.countRoomOccupancy('living_room');
    final smokeCheck = engine.detectSmokeOrFire('camera_kitchen');
    final parking = engine.detectParkingOccupancy();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 36–45: Computer Vision', Icons.visibility, const Color(0xFF9C27B0)),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Room Occupancy', Icons.people, Colors.purple),
              const SizedBox(height: 8),
              _kvRow('People Count', '${occupancy['estimated_count']}'),
              _kvRow('Confidence', '${occupancy['confidence']}'),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Smoke / Fire Detection', Icons.local_fire_department, Colors.red),
              const SizedBox(height: 8),
              _kvRow('Smoke Detected', '${smokeCheck['smoke_detected']}'),
              _kvRow('Fire Detected', '${smokeCheck['fire_detected']}'),
              _kvRow('Severity', '${smokeCheck['severity']}'),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Parking Detection', Icons.local_parking, Colors.purple),
              const SizedBox(height: 8),
              ...(parking['spots'] as List).map((s) {
                final spot = s as Map<String, dynamic>;
                return _kvRow('${spot['name']}', '${spot['occupied'] == true ? 'Occupied' : 'Available'}');
              }),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: LEARNING ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLearningTab() {
    final engine = context.watch<AILearningEngine>();

    final sleep = engine.getSleepPatterns();
    final tempPref = engine.getTemperaturePreferences();
    final routines = engine.getDetectedRoutines();
    final habits = engine.getEnergySavingHabits();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 46–60: Learning & Adaptation', Icons.psychology, const Color(0xFFFF9800)),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Sleep Pattern Analysis', Icons.bedtime, Colors.indigo),
              const SizedBox(height: 8),
              _kvRow('Avg Bedtime', '${sleep['average_bedtime']}'),
              _kvRow('Avg Wake', '${sleep['average_wake_time']}'),
              _kvRow('Duration', '${sleep['average_sleep_duration_hours']} hrs'),
              _kvRow('Consistency', '${sleep['consistency_score']}%'),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Temperature Preferences', Icons.thermostat, Colors.orange),
              const SizedBox(height: 8),
              ...(tempPref['by_time_of_day'] as Map<String, dynamic>).entries.map((e) {
                final val = e.value as Map<String, dynamic>;
                return _kvRow(e.key, '${val['preferred_temp']}°C');
              }),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Detected Routines', Icons.repeat, Colors.teal),
              const SizedBox(height: 8),
              ...(routines['routines'] as List).take(5).map((r) {
                final routine = r as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${routine['name']}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                      Text('${routine['time']}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Energy Saving Score', Icons.eco, Colors.green),
              const SizedBox(height: 8),
              _kvRow('Score', '${habits['score']}/100'),
              _kvRow('Level', '${habits['level']}'),
              _kvRow('Streak', '${habits['streak_days']} days'),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: AUTOMATION ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildAutomationTab() {
    final engine = context.watch<AIAutomationEngine>();

    final scenes = engine.generateSmartScenes();
    final groups = engine.getIntelligentGroups();
    final loadBalance = engine.getLoadBalancingPlan('10');

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 61–75: Automation Intelligence', Icons.auto_fix_high, const Color(0xFF4CAF50)),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('AI-Generated Scenes', Icons.palette, Colors.green),
              const SizedBox(height: 8),
              ...(scenes['scenes'] as List).take(4).map((s) {
                final scene = s as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${scene['name']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('${scene['trigger']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                      Text('${scene['confidence']}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Intelligent Device Groups', Icons.device_hub, Colors.green),
              const SizedBox(height: 8),
              ...(groups['groups'] as List).take(4).map((g) {
                final group = g as Map<String, dynamic>;
                return _kvRow('${group['name']}', '${(group['devices'] as List).length} devices');
              }),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Load Balancing', Icons.balance, Colors.green),
              const SizedBox(height: 8),
              _kvRow('Max Capacity', '${loadBalance['max_capacity_kw']} kW'),
              _kvRow('Current Load', '${(loadBalance['current_load_kw'] as double).toStringAsFixed(1)} kW'),
              _kvRow('Available', '${(loadBalance['available_kw'] as double).toStringAsFixed(1)} kW'),
              _kvRow('Strategy', '${loadBalance['strategy']}'),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: HEALTH ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHealthTab() {
    final engine = context.watch<AIHealthEngine>();

    final wellness = engine.getWellnessReport();
    final circadian = engine.getCircadianLighting();
    final noise = engine.analyzeNoisePollution();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 76–85: Health & Wellness', Icons.favorite, const Color(0xFFE91E63)),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Wellness Report', Icons.health_and_safety, Colors.pink),
              const SizedBox(height: 8),
              _kvRow('Overall Score', '${wellness['overall_wellness_score']}/100'),
              ...(wellness['component_scores'] as Map<String, dynamic>).entries.map((e) {
                return _kvRow(e.key.replaceAll('_', ' '), '${e.value}');
              }),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Circadian Lighting', Icons.wb_twilight, Colors.amber),
              const SizedBox(height: 8),
              _kvRow('Phase', '${circadian['current_phase']}'),
              _kvRow('Color Temp', '${circadian['color_temperature_k']}K'),
              _kvRow('Brightness', '${circadian['brightness_percent']}%'),
              _kvRow('Recommendation', '${circadian['recommendation']}'),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Noise Analysis', Icons.volume_up, Colors.teal),
              const SizedBox(height: 8),
              _kvRow('Current dB', '${noise['current_db']}'),
              _kvRow('Level', '${noise['noise_level']}'),
              _kvRow('Health Risk', '${noise['health_risk']}'),
              _kvRow('Recommendation', '${noise['recommendation']}'),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  TAB: SECURITY ENGINE
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildSecurityTab() {
    final engine = context.watch<AISecurityEngine>();

    final assessment = engine.runFullSecurityAssessment();
    final riskScore = engine.getSecurityRiskScore();
    final escapeRoutes = engine.getEscapeRoutes();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('Features 86–95: Security Intelligence', Icons.shield, const Color(0xFF607D8B)),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Security Assessment', Icons.security, Colors.blueGrey),
              const SizedBox(height: 8),
              _kvRow('Overall Score', '${assessment['overall_score']}/100'),
              _kvRow('Risk Level', '${assessment['risk_level']}'),
              _kvRow('Threat Level', '${assessment['threat_level']}'),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Risk Score Breakdown', Icons.assessment, Colors.orange),
              const SizedBox(height: 8),
              _kvRow('Overall', '${riskScore['overall_risk_score']}/100'),
              ...(riskScore['category_scores'] as Map<String, dynamic>).entries.map((e) {
                return _buildScoreBar(e.key.replaceAll('_', ' '), e.value as int, Colors.orange);
              }),
            ],
          ),
        ),

        _glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardHeader('Emergency Escape Routes', Icons.directions_run, Colors.red),
              const SizedBox(height: 8),
              ...(escapeRoutes['routes'] as List).map((r) {
                final route = r as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.darkSurface, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${route['name']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('Time: ${route['estimated_time']} • Status: ${route['status']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  SHARED WIDGETS
  // ═══════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }

  Widget _cardHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _kvRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(key, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          const Spacer(),
          Flexible(child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54))),
              Text('$score', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'prediction':
        return const Color(0xFF00BCD4);
      case 'anomaly':
        return const Color(0xFFF44336);
      case 'nlp':
        return const Color(0xFF2196F3);
      case 'vision':
        return const Color(0xFF9C27B0);
      case 'learning':
        return const Color(0xFFFF9800);
      case 'automation':
        return const Color(0xFF4CAF50);
      case 'health':
        return const Color(0xFFE91E63);
      case 'security':
        return const Color(0xFF607D8B);
      case 'analytics':
        return const Color(0xFF6C63FF);
      case 'energy_efficiency':
        return Colors.amber;
      case 'comfort':
        return Colors.teal;
      case 'health_wellness':
        return Colors.pink;
      default:
        return const Color(0xFF6C63FF);
    }
  }
}

class _EngineTab {
  final String label;
  final IconData icon;
  final Color color;
  const _EngineTab(this.label, this.icon, this.color);
}
