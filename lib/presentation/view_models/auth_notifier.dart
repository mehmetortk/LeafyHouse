// lib/view_models/auth_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// AuthState sınıfı
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// AuthNotifier sınıfı
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthNotifier() : super(AuthState()) {
    // Kullanıcı durumu dinleme
    _auth.authStateChanges().listen((user) {
      state = state.copyWith(user: user, isLoading: false, errorMessage: null);
    });
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(user: userCredential.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(user: userCredential.user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.signOut();
      state = AuthState(); // Oturum kapandı, varsayılan duruma dön
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// authProvider tanımı
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
