// lib/views/auth/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_models/auth_notifier.dart';
import '../../../core/utils/ui_helpers.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool has8Chars = false;
  bool hasSpecialChar = false;
  bool hasUpperCase = false;
  bool hasLowerCase = false;
  bool hasNumber = false;
  bool passwordsMatch = false;
  bool passwordIsNotEmpty = false;

  void checkPassword(String value) {
    setState(() {
      has8Chars = value.length >= 8;
      hasSpecialChar = RegExp(r'[?,@,!,#,%,\+,\-,\*,%]').hasMatch(value);
      hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      passwordsMatch = value == confirmPasswordController.text;
      passwordIsNotEmpty = value.isNotEmpty && confirmPasswordController.text.isNotEmpty;
    });
  }

  void checkConfirmPassword(String value) {
    setState(() {
      passwordsMatch = value == passwordController.text;
      passwordIsNotEmpty = passwordController.text.isNotEmpty && value.isNotEmpty;
    });
  }

  bool get isPasswordValid {
    return has8Chars &&
        hasSpecialChar &&
        hasUpperCase &&
        hasLowerCase &&
        hasNumber &&
        passwordsMatch &&
        passwordIsNotEmpty;
  }

  Widget buildPasswordCriteria({required String text}) {
    return Row(
      children: [
        Icon(
          Icons.cancel,
          color: Colors.red,
          size: 20,
        ),
        SizedBox(width: 5),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height, // Ekran yüksekliğini ayarla
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Bu sayede içerik ekranın yüksekliğini aşsa dahi kaydırarak görüntülenir.
            child: Center(
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    // Main content adjusted to fit in one screen if possible
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          "Kayıt Ol",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(70.0),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          height: 120,
                          width: 120,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "E-posta",
                          prefixIcon: Icon(Icons.email, color: Colors.teal),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Şifre",
                          prefixIcon: Icon(Icons.lock, color: Colors.teal),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        onChanged: checkPassword,
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: "Şifre Tekrar",
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        onChanged: checkConfirmPassword,
                      ),
                      // Şartlar sağlanmadığında şifre kriterleri görünür
                      if ((passwordController.text.isNotEmpty ||
                              confirmPasswordController.text.isNotEmpty) &&
                          !isPasswordValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!has8Chars)
                                buildPasswordCriteria(text: "En az 8 karakter"),
                              if (!hasSpecialChar)
                                buildPasswordCriteria(
                                    text: "En az bir özel karakter (?, @, !, #, %, +, -, *, %)"),
                              if (!hasUpperCase)
                                buildPasswordCriteria(text: "En az bir büyük harf"),
                              if (!hasLowerCase)
                                buildPasswordCriteria(text: "En az bir küçük harf"),
                              if (!hasNumber)
                                buildPasswordCriteria(text: "En az bir rakam (0-9)"),
                              if (!passwordsMatch || !passwordIsNotEmpty)
                                buildPasswordCriteria(text: "Parolalar eşleşmeli"),
                            ],
                          ),
                        ),
                      SizedBox(height: 20),
                      authState.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                gradient: LinearGradient(
                                  colors: isPasswordValid
                                      ? [Colors.teal, Colors.teal.shade700]
                                      : [Colors.grey.shade400, Colors.grey.shade600],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12.0),
                                  onTap: isPasswordValid
                                      ? () async {
                                          await authNotifier.register(
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );

                                          if (authState.errorMessage != null) {
                                            showErrorMessage(
                                              context,
                                              "Kayıt Başarısız: ${authState.errorMessage}",
                                            );
                                          } else {
                                            showSuccessMessage(context, "Kayıt Başarılı! Giriş yapabilirsiniz.");
                                            Navigator.pop(context);
                                          }
                                        }
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(
                                      child: Text(
                                        "Kayıt Ol",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Giriş Ekranına Dön",
                          style: TextStyle(
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
