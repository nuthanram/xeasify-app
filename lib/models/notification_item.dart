class NotificationItem {
  final String id;
  final String notificationType;
  final String title;
  final String body;
  final String status;
  final DateTime queuedAt;

  const NotificationItem({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.status,
    required this.queuedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
        id: j['id'] as String,
        notificationType: j['notification_type'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        status: j['status'] as String? ?? '',
        queuedAt:
            DateTime.tryParse(j['queued_at'] as String? ?? '') ??
                DateTime.now(),
      );
}
