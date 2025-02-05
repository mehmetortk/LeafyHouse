import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../view_models/auth_notifier.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  bool rememberMe = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  int notificationCount = 3; // Örnek statik değer

  @override
  void initState() {
    super.initState();
    _checkRememberMe();
  }

  Future<void> _checkRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool("remember_me") ?? false;
    if (rememberMe) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, "/home");
      });
    }
  }

  Future<void> _onLoginPressed() async {
    await ref.read(authProvider.notifier).login(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("remember_me", true);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giriş yapılamadı, lütfen tekrar deneyin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [Colors.grey.shade900, Colors.black]
                  : [Colors.green.shade300, Colors.green.shade700],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Card(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.greenAccent : Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(70.0),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            height: 120,
                            width: 120,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "E-posta",
                            labelStyle: TextStyle(
                              color: isDark ? Colors.greenAccent : Colors.green,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: isDark ? Colors.greenAccent : Colors.green,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Şifre",
                            labelStyle: TextStyle(
                              color: isDark ? Colors.greenAccent : Colors.green,
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: isDark ? Colors.greenAccent : Colors.green,
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        CheckboxListTile(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          title: Text(
                            "Beni Hatırla",
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        authState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.0),
                                  gradient: LinearGradient(
                                    colors: isDark 
                                        ? [Colors.green.shade700, Colors.green.shade900]
                                        : [Colors.green, Colors.green.shade700],
                                  ),
                                  boxShadow: const [
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
                                    onTap: _onLoginPressed,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                        child: Text(
                                          "Giriş Yap",
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
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            "Hesabınız Yok mu? Kayıt Ol",
                            style: TextStyle(
                              color: isDark ? Colors.greenAccent : Colors.green.shade700,
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
      ),
    );
  }
}
