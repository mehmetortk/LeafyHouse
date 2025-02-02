import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../plants/plants_view.dart';
import '../../../providers/notifications_provider.dart';

class NotificationsView extends ConsumerWidget {
  const NotificationsView({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    // Örneğin: 02/02/2025 14:30:15
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimler")),
      body: notifications.isEmpty
          ? const Center(child: Text("Henüz bildirim yok."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        item.message,
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
                          ref.read(notificationsProvider.notifier).markAsRead(item);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PlantsView()),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}