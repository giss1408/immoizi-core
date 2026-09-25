/// A backend notification, as both apps need it for badges and alerts.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.interestRequestId,
  });

  final String id;
  final String title;
  final String message;
  final bool isRead;

  /// Set when the notification is about an interest request.
  final String? interestRequestId;
}

const markNotificationReadMutation = r'''
mutation MarkNotificationRead($notificationId: ID!) {
  markNotificationRead(notificationId: $notificationId) { notification { id isRead } }
}
''';
