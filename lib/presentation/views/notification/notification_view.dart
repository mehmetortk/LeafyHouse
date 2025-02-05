import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../plants/plants_view.dart';
import '../../providers/notifications_provider.dart';

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
    var allNotifications = ref.watch(notificationsProvider);
    final unreadOnly = ref.watch(unreadOnlyProvider);
    
    // Bildirimleri tarihe göre sırala (en yeniden en eskiye)
    allNotifications = allNotifications.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
      
    final notifications = unreadOnly
        ? allNotifications.where((n) => !n.isRead).toList()
        : allNotifications;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noNotificationTextColor = isDark ? Colors.white : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirimler"),
        backgroundColor: isDark 
            ? const Color(0xFF1E1E1E)  // Dark mode için koyu gri
            : const Color(0xFF2E7D32), // Light mode için yeşil
        centerTitle: true,
        elevation: isDark ? 0 : 4,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
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
                    title: Text(
                      "Sadece okunmamışları göster",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    value: unreadOnly,
                    activeColor: Theme.of(context).colorScheme.secondary,
                    onChanged: (value) => ref
                        .read(unreadOnlyProvider.notifier)
                        .state = value ?? false,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ),
              // Notification List
              notifications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          "Henüz okunmamış bir bildirim yok.",
                          style: TextStyle(
                            fontSize: 18,
                            color: noNotificationTextColor,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        // Determine icon and text colors based on theme and read status.
                        Color leadingIconColor;
                        Color titleTextColor;
                        Color subtitleTextColor;
                        Color trailingIconColor;
                        
                        if (isDark) {
                          leadingIconColor = item.isRead ? Colors.grey : Colors.white;
                          titleTextColor = item.isRead ? Colors.grey : Colors.white;
                          subtitleTextColor = item.isRead ? Colors.grey : Colors.white;
                          trailingIconColor = item.isRead ? Colors.grey : Colors.white70;
                        } else {
                          // Light mode için renk güncellemeleri
                          leadingIconColor = item.isRead ? Colors.grey : Colors.green; // Okunmamış bildirimler için yeşil
                          titleTextColor = item.isRead ? Colors.grey : Colors.black;
                          subtitleTextColor = item.isRead ? Colors.grey : Colors.black54;
                          trailingIconColor = item.isRead ? Colors.black38 : Colors.green; // Ok işareti de yeşil olsun
                        }
                        
                        return Dismissible(
                          key: UniqueKey(),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.onError,
                            ),
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
                                  color: leadingIconColor,
                                  size: 28,
                                ),
                                title: Text(
                                  item.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: titleTextColor,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _formatDate(item.date),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtitleTextColor,
                                    ),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: trailingIconColor,
                                ),
                                onTap: () {
                                  if (!item.isRead) {
                                    ref
                                        .read(notificationsProvider.notifier)
                                        .markAsRead(item);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>  PlantsView()),
                                    );
                                  }
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