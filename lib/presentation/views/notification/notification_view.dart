import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../plants/plants_view.dart';
import '../../../providers/notifications_provider.dart';

// Provider for filtering unread notifications
final unreadOnlyProvider = StateProvider<bool>((ref) => false);

class NotificationsView extends ConsumerWidget {
  const NotificationsView({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    // Örneğin: 02/02/2025 14:30:15 (salise olmadan)
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotifications = ref.watch(notificationsProvider);
    final unreadOnly = ref.watch(unreadOnlyProvider);
    final notifications = unreadOnly
        ? allNotifications.where((n) => !n.isRead).toList()
        : allNotifications;

    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimler")),
      body: Column(
        children: [
          // Checkbox to filter unread notifications
          CheckboxListTile(
            title: const Text("Sadece okunmamışları göster"),
            value: unreadOnly,
            onChanged: (value) =>
                ref.read(unreadOnlyProvider.notifier).state = value ?? false,
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text("Henüz bildirim yok."))
                : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          ref
                              .read(notificationsProvider.notifier)
                              .removeNotification(item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Card(
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(
                                item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: item.isRead ? Colors.grey : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatDate(item.date),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (!item.isRead) {
                                  ref
                                      .read(notificationsProvider.notifier)
                                      .markAsRead(item);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PlantsView()),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}