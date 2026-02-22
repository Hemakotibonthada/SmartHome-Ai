import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/smart_features_service.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String _selectedCategory = 'All';
  final _categories = ['All', 'device', 'sensor', 'automation', 'security', 'system', 'user'];

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SmartFeaturesService>();
    final filtered = _selectedCategory == 'All'
        ? svc.activityLog
        : svc.activityLog.where((e) => e.category.name == _selectedCategory).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildCategoryFilter(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text('No activity logs', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _buildLogItem(filtered[i], i > 0 ? filtered[i - 1] : null),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final svc = context.read<SmartFeaturesService>();
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
          const Expanded(child: Text('Activity Log', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
          Text('${svc.activityLog.length} entries', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(cat[0].toUpperCase() + cat.substring(1),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                  color: selected ? AppTheme.primaryColor : Colors.white38)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogItem(ActivityLogEntry entry, ActivityLogEntry? prev) {
    final showDate = prev == null ||
        entry.timestamp.day != prev.timestamp.day ||
        entry.timestamp.month != prev.timestamp.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDate) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _formatDate(entry.timestamp),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
        ],
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dot and line
              Column(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: _categoryColor(entry.category.name),
                      border: Border.all(color: _categoryColor(entry.category.name).withValues(alpha: 0.3), width: 2),
                    ),
                  ),
                  Container(width: 2, height: 45, color: Colors.white.withValues(alpha: 0.05)),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_categoryIcon(entry.category.name), size: 14, color: _categoryColor(entry.category.name)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(entry.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                          ),
                          Text(
                            '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3)),
                          ),
                        ],
                      ),
                      if (entry.details.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(entry.details, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _categoryColor(entry.category.name).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(entry.category.name, style: TextStyle(fontSize: 9, color: _categoryColor(entry.category.name))),
                          ),
                          const SizedBox(width: 6),
                          Text(entry.userName, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'device': return const Color(0xFF2196F3);
      case 'automation': return const Color(0xFF9C27B0);
      case 'security': return const Color(0xFFF44336);
      case 'energy': return const Color(0xFF4CAF50);
      case 'system': return const Color(0xFFFF9800);
      default: return Colors.white54;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'device': return Icons.devices;
      case 'automation': return Icons.auto_awesome;
      case 'security': return Icons.security;
      case 'energy': return Icons.bolt;
      case 'system': return Icons.settings;
      default: return Icons.info;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) return 'Today';
    if (dt.day == now.day - 1 && dt.month == now.month && dt.year == now.year) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
