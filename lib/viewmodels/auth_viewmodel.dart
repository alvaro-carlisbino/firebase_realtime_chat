import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthViewModel(this._authService);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      _currentUser = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      _setLoading(false);
      return _currentUser != null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Ocorreu um erro inesperado');
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _setError(null);

      _currentUser = await _authService.registerWithEmailAndPassword(
        email,
        password,
        displayName,
      );

      _setLoading(false);
      return _currentUser != null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Ocorreu um erro inesperado');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'E-mail já cadastrado';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'E-mail inválido';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      default:
        return 'Falha na autenticação';
    }
  }

  void clearError() {
    _setError(null);
  }
}
