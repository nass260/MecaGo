import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Injection de dépendance du service de sécurité cloud
  AuthNotifier({
    AuthService authService = const AuthService(),
  }) : _authService = authService;

  // Getters sécurisés pour exposer l'état de session à l'interface
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Exécute l'ouverture de session asynchrone de l'utilisateur sur Firebase Auth
  Future<bool> login({required String email, required String password}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bool success = await _authService.loginUser(email: email, password: password);
      if (success) {
        _isAuthenticated = true;
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = "Identifiants invalides ou compte inexistant.";
        _isAuthenticated = false;
        return false;
      }
    } catch (e) {
      _errorMessage = "Une erreur de connexion au serveur est survenue.";
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // Rafraîchit l'interface utilisateur
    }
  }

  /// Exécute la déconnexion et réinitialise l'état global
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logoutUser();
    _isAuthenticated = false;
    _errorMessage = null;
    _isLoading = false;
    
    notifyListeners();
  }
}
