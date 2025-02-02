import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationItem {
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationItem({
    required this.message,
    required this.date,
    this.isRead = false,
  });
}

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super([]) {
    // Dinamik bildirimlerin alınması için Firebase Messaging dinleyicisi
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      final notificationData = remoteMessage.notification;
      // Push mesajında notification varsa body'sini, yoksa data'dan "message" değerini kullanın
      final messageBody =
          notificationData?.body ?? remoteMessage.data['message'] ?? '';
      if (messageBody.isNotEmpty) {
        final newNotification = NotificationItem(
          message: messageBody,
          date: DateTime.now(),
          isRead: false,
        );
        state = [...state, newNotification];
      }
    });
  }

  void markAsRead(NotificationItem item) {
    state = [
      for (final n in state)
        if (n == item)
          NotificationItem(message: n.message, date: n.date, isRead: true)
        else
          n
    ];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  (ref) => NotificationsNotifier(),
);