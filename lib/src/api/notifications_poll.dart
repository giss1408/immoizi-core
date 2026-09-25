/// Lightweight query used for background polling: only notification ids and
/// read flags, so the full dashboard is reloaded only when something changed.
const notificationsPollQuery = r'''
query NotificationsPoll {
  notifications { id isRead }
}
''';

/// A compact fingerprint of a notification list, comparable across polls.
String notificationsSignature(Iterable<({String id, bool isRead})> items) =>
    (items.map((item) => '${item.id}:${item.isRead ? 1 : 0}').toList()..sort())
        .join(',');
