import '../api/json.dart';

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

/// A notification as listed on the dashboards.
class NotificationItem extends AppNotification {
  const NotificationItem({
    required super.id,
    required super.title,
    required super.message,
    required super.isRead,
    super.interestRequestId,
    this.propertyTitle = '-',
    this.interestMessage = '',
    this.createdAt = '',
  });

  final String propertyTitle;

  /// The applicant's first message, when the query asks for it.
  final String interestMessage;
  final String createdAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final interest = json['interestRequest'] as Map<String, dynamic>?;
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      interestRequestId: interest?['id'] as String?,
      propertyTitle: nestedTitle(json['property']),
      interestMessage: interest?['message'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
}

const markNotificationReadMutation = r'''
mutation MarkNotificationRead($notificationId: ID!) {
  markNotificationRead(notificationId: $notificationId) { notification { id isRead } }
}
''';
