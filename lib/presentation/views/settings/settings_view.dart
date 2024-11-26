// lib/views/settings/settings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/auth_notifier.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AuthNotifier'a erişim
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Ayarlar")),
      body: Center(
        child: authState.isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () async {
                  await authNotifier.logout();

                  if (authState.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Çıkış Yapılırken Hata Oluştu: ${authState.errorMessage}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Başarıyla Çıkış Yapıldı"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                child: Text("Çıkış Yap"),
              ),
      ),
    );
  }
}
