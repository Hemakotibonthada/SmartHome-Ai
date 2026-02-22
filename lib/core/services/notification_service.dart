class NotificationService {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    if (_notifications.length > 100) {
      _notifications.removeLast();
    }
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void clearAll() {
    _notifications.clear();
  }

  /// Generate sample notifications
  List<AppNotification> getSampleNotifications() {
    return [
      AppNotification(
        id: 'notif_1',
        title: 'High Temperature Alert',
        message: 'Living room temperature reached 34°C. AC has been turned on automatically.',
        type: NotificationType.alert,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Water Tank Low',
        message: 'Water level dropped below 20%. Water pump started.',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 'notif_3',
        title: 'Weekly Energy Report',
        message: 'Your energy consumption decreased by 12% this week. Great job!',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif_4',
        title: 'Motion Detected',
        message: 'Motion detected at front door camera at 11:45 PM.',
        type: NotificationType.security,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif_5',
        title: 'Device Offline',
        message: 'Kitchen light sensor went offline. Check connection.',
        type: NotificationType.alert,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      AppNotification(
        id: 'notif_6',
        title: 'Voltage Fluctuation',
        message: 'Power supply voltage fluctuated between 195V-245V. Stabilizer recommended.',
        type: NotificationType.warning,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'notif_7',
        title: 'Maintenance Due',
        message: 'AC filter cleaning is due. Last cleaned 45 days ago.',
        type: NotificationType.info,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
    );
  }
}

enum NotificationType {
  info,
  warning,
  alert,
  security,
  success,
}
