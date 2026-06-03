import 'package:flutter/material.dart';
import 'package:gideoncomputer/api/auth_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final _authAPI = AuthAPI();

  User? _user;
  User? get user => _user;

  // 🔥 LOGIN
  Future login(String email, String password) async {
    final res = await _authAPI.login(email, password);
    _user = res.user;
    notifyListeners();
    return res;
  }

  // 🔥 REGISTER
  Future register(String email, String password, String fullname) async {
    final res = await _authAPI.register(email, password, fullname);
    _user = res.user;
    notifyListeners();
    return res;
  }

  // 🔥 GET CURRENT USER
  void loadUser() {
    _user = Supabase.instance.client.auth.currentUser;
    notifyListeners();
  }

  // 🔥 LOGOUT
  Future logout() async {
    await _authAPI.logout();
    _user = null;
    notifyListeners();
  }
}
