import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_ai/core/theme/app_theme.dart';
import 'package:smart_home_ai/core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();
    final notifications = service.notifications.where((n) {
      if (_filter == 'all') return true;
      if (_filter == 'unread') return !n.isRead;
      return n.type.name == _filter;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(service),
              _buildFilters(),
              Expanded(
                child: notifications.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        physics: const BouncingScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(
                            notifications[index],
                            index,
                            service,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(NotificationService service) {
    final unread = service.notifications.where((n) => !n.isRead).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unread new',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.5)),
            color: AppTheme.darkCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: AppTheme.primaryColor, size: 18),
                    const SizedBox(width: 10),
                    const Text('Mark all as read', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppTheme.errorColor, size: 18),
                    const SizedBox(width: 10),
                    const Text('Clear all', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'read_all') {
                for (var n in service.notifications) {
                  service.markAsRead(n.id);
                }
              } else if (value == 'clear') {
                service.clearAll();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.all_inbox},
      {'key': 'unread', 'label': 'Unread', 'icon': Icons.mark_email_unread},
      {'key': 'alert', 'label': 'Alerts', 'icon': Icons.warning_amber},
      {'key': 'security', 'label': 'Security', 'icon': Icons.security},
      {'key': 'info', 'label': 'Info', 'icon': Icons.info_outline},
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = _filter == filter['key'];
          return GestureDetector(
            onTap: () => setState(() => _filter = filter['key'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppTheme.primaryColor.withOpacity(0.4) : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 16,
                    color: selected ? AppTheme.primaryColor : Colors.white38,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppTheme.primaryColor : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, int index, NotificationService service) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);
    final timeAgo = _getTimeAgo(notification.timestamp);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete, color: AppTheme.errorColor),
        ),
        onDismissed: (_) {
          service.clearAll();
        },
        child: GestureDetector(
          onTap: () {
            service.markAsRead(notification.id);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? AppTheme.darkCard
                  : AppTheme.darkCard.withOpacity(0.95),
              borderRadius: BorderRadius.circular(18),
              border: notification.isRead
                  ? null
                  : Border.all(color: color.withOpacity(0.2)),
              boxShadow: notification.isRead
                  ? null
                  : [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.3)),
          ),
          const SizedBox(height: 6),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.15)),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return AppTheme.errorColor;
      case NotificationType.warning:
        return AppTheme.warningColor;
      case NotificationType.security:
        return const Color(0xFFE040FB);
      case NotificationType.success:
        return AppTheme.successColor;
      case NotificationType.info:
        return AppTheme.secondaryColor;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.alert:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.security:
        return Icons.security;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
