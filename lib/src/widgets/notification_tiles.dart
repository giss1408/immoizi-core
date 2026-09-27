import 'package:flutter/material.dart';

import '../i18n/tr.dart';
import '../notifications/app_notification.dart';
import '../theme.dart';

String _details(NotificationItem notification, bool showInterestMessage) {
  final lines = [notification.message, notification.propertyTitle];
  if (showInterestMessage) {
    lines.add(notification.interestMessage.isEmpty
        ? tr('Aucun message initial.')
        : notification.interestMessage);
  }
  return lines.join('\n');
}

class NotificationTile extends StatelessWidget {
  const NotificationTile(this.notification,
      {this.onTap, this.onDelete, this.showInterestMessage = false, super.key});

  final NotificationItem notification;

  /// Typically marks the notification read and opens the conversation.
  final VoidCallback? onTap;

  /// Shows a delete button when set.
  final VoidCallback? onDelete;

  /// Adds the applicant's first message (landlord view).
  final bool showInterestMessage;

  @override
  Widget build(BuildContext context) {
    final unreadDot = Icon(Icons.circle, size: 10, color: IvoryColors.orange);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          notification.isRead
              ? Icons.notifications_none
              : Icons.notifications_active,
          color: notification.isRead ? Colors.grey : IvoryColors.orange,
        ),
        title: Text(notification.title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          _details(notification, showInterestMessage),
          maxLines: showInterestMessage ? 4 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: onTap,
        trailing: onDelete == null
            ? (notification.isRead ? null : unreadDot)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!notification.isRead) unreadDot,
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                    tooltip: tr('Supprimer la notification'),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Highlights the first unread notification, with the count of the others.
class UnreadNotificationsBanner extends StatelessWidget {
  const UnreadNotificationsBanner(
      {required this.notifications,
      this.onTap,
      this.showInterestMessage = false,
      super.key});

  /// Unread notifications; must not be empty.
  final List<NotificationItem> notifications;
  final VoidCallback? onTap;

  /// Adds the applicant's first message (landlord view).
  final bool showInterestMessage;

  @override
  Widget build(BuildContext context) {
    final first = notifications.first;
    return Card(
      color: IvoryColors.orange.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.notifications_active, color: IvoryColors.orange),
        title: Text(first.title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          _details(first, showInterestMessage),
          maxLines: showInterestMessage ? 4 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: onTap,
        trailing: notifications.length > 1
            ? Text('+${notifications.length - 1}')
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
