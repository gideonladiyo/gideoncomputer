import 'package:dio/dio.dart';
import 'package:gideoncomputer/model/profile/user_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/auth/auth_model.dart';

class AuthAPI {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    try {
      EasyLoading.show(status: "Loading");

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password
      );

      EasyLoading.dismiss();

      return response;
    } catch (e) {
      print("LOGIN ERROR: $e");
      EasyLoading.showError(e.toString());
      rethrow;
    }
  }

  Future<AuthResponse> register(
    String email,
    String password,
    String fullname,
  ) async {
    try {
      EasyLoading.show(status: 'Registering...');

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'fullname': fullname,
        },
      );

      final user = response.user;

      if (user != null) {
        try {
          await supabase.from('profiles').insert({
            'id': user.id,
            'fullname': fullname,
            'email': email,
            'role': 'student',
          });
        } catch (dbError) {
          print("⚠️ Profile insert warning (likely trigger handled it or RLS blocked it): $dbError");
        }
      }

      EasyLoading.dismiss();

      return response;
    } catch (e) {
      print("REGISTER ERROR: $e");
      EasyLoading.showError('Failed to Register!');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-callback/',
    );
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
