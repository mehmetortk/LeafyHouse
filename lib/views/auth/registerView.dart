import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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

  Future<void> registerUser() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pop(context); // Login ekranına geri dön
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Kayıt Başarısız: $e")));
    }
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/app_logo.png', // Logonun yolu
              height: 100,
              width: 100,
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "E-posta"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
              onChanged: checkPassword,
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: "Şifre Tekrar"),
              obscureText: true,
              onChanged: checkConfirmPassword,
            ),
            SizedBox(height: 20),
            // Parola kriterleri
            buildPasswordCriteria(text: "En az 8 karakter", isValid: has8Chars),
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
            ElevatedButton(
              onPressed: isPasswordValid ? registerUser : null,
              child: Text("Kayıt Ol"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Giriş Ekranına Dön"),
            ),
          ],
        ),
      ),
    );
  }
}
