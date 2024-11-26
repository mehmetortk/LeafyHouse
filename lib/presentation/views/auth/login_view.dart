import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/auth_notifier.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "E-posta"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            authState.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      await authNotifier.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );

                      if (authState.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Giriş Başarısız: ${authState.errorMessage}"),
                          ),
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Text("Giriş Yap"),
                  ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text("Hesabınız Yok mu? Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
