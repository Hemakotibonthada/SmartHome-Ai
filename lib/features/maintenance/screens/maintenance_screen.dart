import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SmartFeaturesService>();
    final overdue = svc.maintenanceTasks.where((t) => t.isOverdue).toList();
    final upcoming = svc.maintenanceTasks.where((t) => !t.isOverdue && !t.isCompleted).toList();
    final completed = svc.maintenanceTasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, svc),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Summary
                    Row(
                      children: [
                        Expanded(child: _summaryCard('Overdue', overdue.length.toString(), const Color(0xFFF44336))),
                        const SizedBox(width: 12),
                        Expanded(child: _summaryCard('Upcoming', upcoming.length.toString(), const Color(0xFFFF9800))),
                        const SizedBox(width: 12),
                        Expanded(child: _summaryCard('Done', completed.length.toString(), const Color(0xFF4CAF50))),
                      ],
                    ),
                    // Overdue
                    if (overdue.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionHeader('Overdue', const Color(0xFFF44336)),
                      const SizedBox(height: 8),
                      ...overdue.map((t) => _buildTaskCard(t, svc)),
                    ],
                    // Upcoming
                    if (upcoming.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionHeader('Upcoming', const Color(0xFFFF9800)),
                      const SizedBox(height: 8),
                      ...upcoming.map((t) => _buildTaskCard(t, svc)),
                    ],
                    // Completed
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionHeader('Completed', const Color(0xFF4CAF50)),
                      const SizedBox(height: 8),
                      ...completed.map((t) => _buildTaskCard(t, svc)),
                    ],
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
          const Expanded(child: Text('Maintenance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.build_circle, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildTaskCard(MaintenanceTask task, SmartFeaturesService svc) {
    final color = task.isOverdue
        ? const Color(0xFFF44336)
        : task.isCompleted
            ? const Color(0xFF4CAF50)
            : const Color(0xFFFF9800);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: task.isOverdue ? Border.all(color: const Color(0xFFF44336).withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => svc.toggleMaintenanceComplete(task.id),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? const Color(0xFF4CAF50) : color.withValues(alpha: 0.5), width: 2),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(task.description, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority.name).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(task.priority.name, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600,
                        color: _priorityColor(task.priority.name))),
                    ),
                    const SizedBox(width: 6),
                    Text(task.deviceName, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                  ],
                ),
              ],
            ),
          ),
          if (task.isOverdue && !task.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${DateTime.now().difference(task.dueDate).inDays}d late',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF44336)),
              ),
            ),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'critical': return const Color(0xFFF44336);
      case 'high': return const Color(0xFFF44336);
      case 'medium': return const Color(0xFFFF9800);
      case 'low': return const Color(0xFF4CAF50);
      default: return Colors.white54;
    }
  }
}
