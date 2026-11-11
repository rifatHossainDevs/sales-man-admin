import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../models/login_request_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _keepMeSignedIn = true;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get keepMeSignedIn => _keepMeSignedIn;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setKeepMeSignedIn(bool value) {
    _keepMeSignedIn = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequestModel(
        emailOrPhone: emailOrPhone,
        password: password,
        keepSignedIn: _keepMeSignedIn,
      );

      _currentUser = await _authRepository.login(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
