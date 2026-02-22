import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen> {
  final _random = Random();
  late List<_Suggestion> _suggestions;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _suggestions = _generateSuggestions();
  }

  List<_Suggestion> _generateSuggestions() {
    return [
      _Suggestion('energy', 'Shift washing machine to off-peak hours (10 PM - 6 AM) to save ₹120/month',
        Icons.schedule, const Color(0xFF4CAF50), 'AI Detected: 80% of washing done during peak tariff', 92, true),
      _Suggestion('comfort', 'Lower AC to 24°C from 22°C – saves 15% energy with minimal comfort impact',
        Icons.thermostat, const Color(0xFF2196F3), 'Current temp 22°C is over-cooling your bedroom', 88, false),
      _Suggestion('security', 'Enable auto-lock on front door after 11 PM',
        Icons.lock_clock, const Color(0xFFF44336), 'Door was left unlocked past midnight 3 times this week', 95, true),
      _Suggestion('energy', 'Your geyser runs 45 min daily. Timer at 20 min is sufficient',
        Icons.hot_tub, const Color(0xFFFF9800), 'Water reaches target temp in 18 min on average', 85, false),
      _Suggestion('automation', 'Create "Good Morning" routine: lights 30%, coffee maker ON, news briefing',
        Icons.wb_sunny, const Color(0xFFFFD700), 'You manually do this sequence 5 days/week at 7:15 AM', 90, false),
      _Suggestion('maintenance', 'AC filter needs cleaning in ~5 days based on run-time analysis',
        Icons.filter_alt, const Color(0xFF9C27B0), 'Current filter run: 340 hrs (recommended: 350 hrs)', 78, false),
      _Suggestion('energy', 'Turn off standby power for TV & soundbar at night – saves ₹45/month',
        Icons.power_off, const Color(0xFF4CAF50), 'Phantom load: 15W continuous from entertainment unit', 82, true),
      _Suggestion('comfort', 'Open bedroom windows at 6 AM for fresh air – AQI is 42 (Good)',
        Icons.air, const Color(0xFF00BCD4), 'Indoor CO₂ rises overnight. Morning ventilation recommended', 75, false),
      _Suggestion('security', 'Motion detected in garden at 2:30 AM last night',
        Icons.motion_photos_on, const Color(0xFFF44336), 'Unusual activity. Consider adjusting outdoor sensor zones', 96, true),
      _Suggestion('automation', 'Auto-dim living room lights at sunset for ambient mood',
        Icons.dark_mode, const Color(0xFF673AB7), 'Sunset today: 6:42 PM. You dim lights manually around 6:50 PM', 80, false),
      _Suggestion('energy', 'Solar panels generating 20% below capacity – check panel 3 for dust',
        Icons.solar_power, const Color(0xFFFF9800), 'Panel 3 output dropped from 380W to 310W over 2 weeks', 87, true),
      _Suggestion('comfort', 'Humidity at 72% in bathroom. Auto-exhaust fan recommended post-shower',
        Icons.water, const Color(0xFF2196F3), 'High humidity persists 40+ min after shower without exhaust', 83, false),
      _Suggestion('automation', 'Set up voice command "Movie Time" to dim lights + close blinds + TV ON',
        Icons.mic, const Color(0xFF9C27B0), 'This 3-step combo is your most repeated manual action', 77, false),
      _Suggestion('energy', 'Switch to LED in study room – current CFL uses 3x power',
        Icons.lightbulb, const Color(0xFF4CAF50), 'Study light runs 6hrs/day. LED would save ₹30/month', 70, false),
      _Suggestion('security', 'Add water leak sensor under kitchen sink',
        Icons.water_damage, const Color(0xFFF44336), 'Kitchen sink area has no leak coverage in smart mesh', 65, false),
      _Suggestion('weather', 'Rain expected at 4 PM – Close smart windows & retract awning',
        Icons.cloud, const Color(0xFF607D8B), 'Weather API: 80% chance of rain, wind 25 km/h', 91, true),
      _Suggestion('automation', 'Create "Leaving Home" routine: all lights OFF, AC OFF, arm security',
        Icons.exit_to_app, const Color(0xFF673AB7), 'You do this manually every weekday at 8:40 AM ± 5 min', 89, false),
      _Suggestion('energy', 'Night mode: Cap AC at 26°C after midnight for better sleep & savings',
        Icons.bedtime, const Color(0xFF4CAF50), 'Sleep research: 24-26°C optimal. Current: 22°C until 6 AM', 84, false),
      _Suggestion('comfort', 'Smart blinds: Auto-adjust based on sun angle to reduce glare & heat',
        Icons.blinds, const Color(0xFF00BCD4), 'South-facing windows get direct sun 2-5 PM, raises room by 3°C', 79, false),
      _Suggestion('maintenance', 'Water purifier filter at 85% life – schedule replacement in 2 weeks',
        Icons.filter_drama, const Color(0xFF9C27B0), 'TDS readings stable but filter throughput declining', 73, false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _suggestions : _suggestions.where((s) => s.category == _filter).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildFilterChips(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == filtered.length) return const SizedBox(height: 100);
                    return _buildSuggestionCard(filtered[i]);
                  },
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
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Suggestions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('AI-powered recommendations', style: TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          )),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'energy', 'comfort', 'security', 'automation', 'maintenance', 'weather'];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          final selected = f == _filter;
          final color = _categoryColor(f);
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(f[0].toUpperCase() + f.substring(1),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? color : Colors.white38)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSuggestionCard(_Suggestion s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: s.isUrgent ? Border.all(color: _categoryColor(s.category).withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: s.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(s.icon, color: s.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, size: 12, color: AppTheme.primaryColor),
                          const SizedBox(width: 6),
                          Expanded(child: Text(s.reasoning, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _categoryColor(s.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(s.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _categoryColor(s.category))),
              ),
              const SizedBox(width: 8),
              Text('${s.confidence}% confidence', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
              if (s.isUrgent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF44336).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                  child: const Text('URGENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() => _suggestions.remove(s));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Suggestion dismissed'), duration: const Duration(seconds: 1)),
                  );
                },
                child: Icon(Icons.close, size: 16, color: Colors.white.withValues(alpha: 0.2)),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Suggestion applied!'), backgroundColor: Color(0xFF4CAF50), duration: Duration(seconds: 1)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: s.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('Apply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: s.color)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'energy': return const Color(0xFF4CAF50);
      case 'comfort': return const Color(0xFF2196F3);
      case 'security': return const Color(0xFFF44336);
      case 'automation': return const Color(0xFF9C27B0);
      case 'maintenance': return const Color(0xFFFF9800);
      case 'weather': return const Color(0xFF607D8B);
      default: return AppTheme.primaryColor;
    }
  }
}

class _Suggestion {
  final String category;
  final String text;
  final IconData icon;
  final Color color;
  final String reasoning;
  final int confidence;
  final bool isUrgent;

  _Suggestion(this.category, this.text, this.icon, this.color, this.reasoning, this.confidence, this.isUrgent);
}
