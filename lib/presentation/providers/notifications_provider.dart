import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationItem {
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationItem({
    required this.message,
    required this.date,
    this.isRead = false,
  });

  NotificationItem copyWith({String? message, DateTime? date, bool? isRead}) {
    return NotificationItem(
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'date': date.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super([]) {
    _loadFromPrefs();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleMessage(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessage(message);
    });
    FirebaseMessaging.onMessage.listen((message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    final notificationData = message.notification;
    final messageBody =
        notificationData?.body ?? message.data['message'] ?? '';
    if (messageBody.isNotEmpty) {
      final newNotification = NotificationItem(
        message: messageBody,
        date: DateTime.now(),
        isRead: false,
      );
      state = [...state, newNotification];
      _saveToPrefs();
    }
  }

  Future<void> markAsRead(NotificationItem item) async {
    state = [
      for (final n in state)
        if (n == item) n.copyWith(isRead: true) else n,
    ];
    await _saveToPrefs();
  }
  
  Future<void> removeNotification(NotificationItem item) async {
    state = state.where((n) => n != item).toList();
    await _saveToPrefs();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getStringList('notifications') ?? [];
    state = savedData
        .map((data) => NotificationItem.fromJson(json.decode(data)))
        .toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((n) => json.encode(n.toJson())).toList();
    await prefs.setStringList('notifications', data);
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  (ref) => NotificationsNotifier(),
);