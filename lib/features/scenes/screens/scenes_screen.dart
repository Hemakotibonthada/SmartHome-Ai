import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';

class ScenesScreen extends StatelessWidget {
  const ScenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final features = context.watch<SmartFeaturesService>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildActiveScene(features)),
              SliverToBoxAdapter(child: _buildSectionTitle('All Scenes')),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSceneCard(context, features, features.scenes[index]),
                    childCount: features.scenes.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildSectionTitle('Quick Routines')),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildRoutineCard(context, features, features.routines[index]),
                  childCount: features.routines.length,
                ),
              ),
              SliverToBoxAdapter(child: _buildSectionTitle('Schedules')),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildScheduleCard(context, features, features.schedules[index]),
                  childCount: features.schedules.length,
                ),
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
          const Expanded(child: Text('Scenes & Routines', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.add, color: AppTheme.primaryColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveScene(SmartFeaturesService features) {
    if (features.activeScene == null) return const SizedBox.shrink();
    final scene = features.activeScene!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [scene.color.withValues(alpha: 0.3), scene.color.withValues(alpha: 0.1)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scene.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: scene.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(scene.icon, color: scene.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('NOW ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: scene.color, letterSpacing: 1)),
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: scene.color)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(scene.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(scene.description, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => features.deactivateAllScenes(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.stop_circle_outlined, color: scene.color, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.4), letterSpacing: 0.5)),
    );
  }

  Widget _buildSceneCard(BuildContext context, SmartFeaturesService features, SceneModel scene) {
    return GestureDetector(
      onTap: () => features.activateScene(scene.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scene.isActive ? scene.color.withValues(alpha: 0.15) : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(22),
          border: scene.isActive ? Border.all(color: scene.color.withValues(alpha: 0.4)) : null,
          boxShadow: scene.isActive ? [BoxShadow(color: scene.color.withValues(alpha: 0.1), blurRadius: 12)] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: scene.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                  child: Icon(scene.icon, color: scene.color, size: 24),
                ),
                if (scene.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: scene.color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: scene.color)),
                  ),
              ],
            ),
            const Spacer(),
            Text(scene.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(scene.description, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.touch_app, size: 12, color: Colors.white.withValues(alpha: 0.3)),
                const SizedBox(width: 4),
                Text('${scene.usageCount} uses', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                const Spacer(),
                Text('${scene.actions.length} actions', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, SmartFeaturesService features, QuickRoutine routine) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: routine.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(routine.icon, color: routine.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routine.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text('${routine.actions.length} actions • ${routine.executionCount} runs',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => features.toggleRoutineFavorite(routine.id),
            child: Icon(routine.isFavorite ? Icons.star : Icons.star_border,
              color: routine.isFavorite ? const Color(0xFFFFD700) : Colors.white24, size: 20),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              features.executeRoutine(routine.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${routine.name} routine executed!'), backgroundColor: routine.color,
                  behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [routine.color, routine.color.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(12)),
              child: const Text('Run', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, SmartFeaturesService features, ScheduleRule schedule) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: schedule.isEnabled ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)) : null,
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(schedule.time.format(context), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(schedule.time.hour < 12 ? 'AM' : 'PM', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(schedule.daysLabel, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              ],
            ),
          ),
          Switch(
            value: schedule.isEnabled,
            onChanged: (_) => features.toggleSchedule(schedule.id),
            activeColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
