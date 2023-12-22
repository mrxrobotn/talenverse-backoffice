import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/admin.dart';

class AdminProvider extends ChangeNotifier {
  Admin _admin = Admin(isLoggedIn: false);

  Admin get admin => _admin;

  // Constructor to load user state from shared preferences
  AdminProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _admin = Admin(isLoggedIn: isLoggedIn);
    notifyListeners();
  }

  void login(BuildContext context) async {
    _admin = Admin(isLoggedIn: true);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);

    Navigator.pushNamed(context , '/dashboard');
  }

  void logout(BuildContext context) async {
    _admin = Admin(isLoggedIn: false);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);

    Navigator.pushNamed(context, '/login');
  }
}
