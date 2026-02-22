import 'package:flutter/material.dart';
import 'package:smart_home_ai/core/models/user_model.dart';
import 'package:smart_home_ai/core/services/demo_mode_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  DemoModeService? _demoModeService;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  /// Whether the current session is a demo session.
  bool get isDemoSession => _demoModeService?.isDemoMode ?? false;

  /// Inject the DemoModeService reference (called from app_providers).
  void setDemoModeService(DemoModeService service) {
    _demoModeService = service;
  }

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
      // Normal login → live mode (no demo data)
      _demoModeService?.disableDemoMode();
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
    // Registration → live mode (no demo data)
    _demoModeService?.disableDemoMode();
    notifyListeners();
    return true;
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    // Exiting → disable demo
    _demoModeService?.disableDemoMode();
    notifyListeners();
  }

  void demoLogin() {
    _user = UserModel(
      id: 'demo_user',
      name: 'Demo User',
      email: 'demo@circuvent.com',
      role: UserRole.admin,
      homeId: 'home_demo',
    );
    _isLoggedIn = true;
    // Demo login → enable demo mode so services generate dummy data
    _demoModeService?.enableDemoMode();
    notifyListeners();
  }
}
