// lib/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/auth_notifier.dart';
import '../../../core/utils/ui_helpers.dart'; // Hata ve başarı mesajları için

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Parola kriterleri için değişkenler
  bool has8Chars = false;
  bool hasSpecialChar = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool passwordsMatch = false;
  bool passwordIsNotEmpty = false;

  // Parola kontrol fonksiyonu
  void checkPassword(String value) {
    setState(() {
      has8Chars = value.length >= 8;
      hasSpecialChar = RegExp(r'[?,@,!,#,%,\+,\-,\*,%]').hasMatch(value);
      hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      passwordsMatch = value == confirmPasswordController.text;
      passwordIsNotEmpty =
          value.isNotEmpty && confirmPasswordController.text.isNotEmpty;
    });
  }

  // Parola tekrar kontrolü
  void checkConfirmPassword(String value) {
    setState(() {
      passwordsMatch = value == passwordController.text;
      passwordIsNotEmpty =
          passwordController.text.isNotEmpty && value.isNotEmpty;
    });
  }

  // Tüm kriterlerin sağlanıp sağlanmadığını kontrol etme
  bool get isPasswordValid {
    return has8Chars &&
        hasSpecialChar &&
        hasUpperCase &&
        hasLowerCase &&
        hasNumber &&
        passwordsMatch &&
        passwordIsNotEmpty;
  }

  Widget buildPasswordCriteria({required String text, required bool isValid}) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 20,
        ),
        SizedBox(width: 5),
        Expanded(child: Text(text)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Scrollable yapmak için
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Butonları genişletmek için
            children: [
              // Logo ve diğer Widget'lar
              Center(
                child: Image.asset(
                  'assets/images/app_logo.png', // Logonun yolu
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: checkPassword,
              ),
              SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "Şifre Tekrar",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: checkConfirmPassword,
              ),
              SizedBox(height: 20),
              // Parola kriterleri
              buildPasswordCriteria(
                  text: "En az 8 karakter", isValid: has8Chars),
              buildPasswordCriteria(
                  text: "En az bir özel karakter (?, @, !, #, %, +, -, *, %)",
                  isValid: hasSpecialChar),
              buildPasswordCriteria(
                  text: "En az bir büyük harf", isValid: hasUpperCase),
              buildPasswordCriteria(
                  text: "En az bir küçük harf", isValid: hasLowerCase),
              buildPasswordCriteria(
                  text: "En az bir rakam (0-9)", isValid: hasNumber),
              buildPasswordCriteria(
                  text: "Parolalar eşleşmeli",
                  isValid: passwordsMatch && passwordIsNotEmpty),
              SizedBox(height: 30),
              authState.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: isPasswordValid
                          ? () async {
                              await authNotifier.register(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              if (authState.errorMessage != null) {
                                showErrorMessage(context,
                                    "Kayıt Başarısız: ${authState.errorMessage}");
                              } else {
                                showSuccessMessage(context,
                                    "Kayıt Başarılı! Giriş yapabilirsiniz.");
                                Navigator.pop(context); // Giriş ekranına dön
                              }
                            }
                          : null,
                      child: Text("Kayıt Ol"),
                    ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Giriş Ekranına Dön"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
