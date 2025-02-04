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
    // Format: dd/MM/yyyy HH:mm:ss
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
      appBar: AppBar(
        title: const Text("Bildirimler"),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simulate refresh; you may add your refresh logic here.
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Filter Card
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CheckboxListTile(
                    title: const Text("Sadece okunmamışları göster"),
                    value: unreadOnly,
                    activeColor: Colors.green,
                    onChanged: (value) =>
                        ref.read(unreadOnlyProvider.notifier).state = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ),
              // Notification List
              notifications.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          "Henüz bildirim yok.",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        return Dismissible(
                          key: UniqueKey(),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                horizontal: 12, vertical: 6),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Icon(
                                  item.isRead
                                      ? Icons.mark_email_read
                                      : Icons.mark_email_unread,
                                  color: item.isRead ? Colors.grey : Colors.green,
                                  size: 28,
                                ),
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
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.black38,
                                ),
                                onTap: () {
                                  if (!item.isRead) {
                                    ref
                                        .read(notificationsProvider.notifier)
                                        .markAsRead(item);
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>  PlantsView(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}