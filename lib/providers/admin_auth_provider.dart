import 'package:flutter/foundation.dart';

class AdminAuthProvider with ChangeNotifier {
  bool _isAdmin = false;
  String? _adminName;

  bool get isAdmin => _isAdmin;
  String? get adminName => _adminName;

  // Hardcoded Admin Credentials
  static const String adminEmail = 'admin@fashion.com';
  static const String adminPassword = 'admin123';

  Future<bool> login(String email, String password) async {
    // Simulate brief network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPass = password.trim();

    if ((trimmedEmail == adminEmail || trimmedEmail == 'admin') &&
        trimmedPass == adminPassword) {
      _isAdmin = true;
      _adminName = 'Fashion Store Admin';
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _isAdmin = false;
    _adminName = null;
    notifyListeners();
  }
}
