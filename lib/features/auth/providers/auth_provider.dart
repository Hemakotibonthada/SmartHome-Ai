import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && password.isNotEmpty) {
      _user = UserModel(
        id: 'user_1',
        name: email.contains('admin') ? 'Admin User' : 'John Doe',
        email: email,
        role: email.contains('admin') ? UserRole.admin : UserRole.user,
        homeId: 'home_1',
      );
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _user = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: UserRole.user,
      homeId: 'home_1',
    );
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void demoLogin() {
    _user = UserModel(
      id: 'demo_user',
      name: 'Demo User',
      email: 'demo@smarthome.ai',
      role: UserRole.admin,
      homeId: 'home_demo',
    );
    _isLoggedIn = true;
    notifyListeners();
  }
}
