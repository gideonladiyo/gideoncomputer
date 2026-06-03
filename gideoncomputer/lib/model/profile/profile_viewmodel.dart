import 'dart:io';

import 'package:gideoncomputer/api/auth_api.dart';
import 'package:gideoncomputer/api/faq_api.dart';
import 'package:gideoncomputer/api/user_api.dart';
import 'package:gideoncomputer/model/course/enrolled_course_model.dart';
import 'package:gideoncomputer/model/faq/faq_model.dart';
import 'package:gideoncomputer/model/profile/user_model.dart';
import 'package:gideoncomputer/model/request/request_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../api/course_api.dart';

class ProfileViewModel extends ChangeNotifier {
  bool isLoading = true;
  bool isFaqLoading = true;
  bool isLoadingData = true;

  List<EnrolledCourseModel> _enrolledCourse = [];
  List<EnrolledCourseModel> get enrolledCourse => _enrolledCourse;

  List<EnrolledCourseModel> _finishedCourse = [];
  List<EnrolledCourseModel> get finishedCourse => _finishedCourse;

  List<FAQModel> _allFAQ = [];
  List<FAQModel> get allFAQ => _allFAQ;

  late UserModel _userData;
  UserModel get userData => _userData;

  late EnrolledCourseModel _enrolledCourseData;
  EnrolledCourseModel get enrolledCourseData => _enrolledCourseData;

  File? _reportData;
  File get reportData => _reportData!;

  Future<UserModel> getUserById(String id) async {
    final user = await UserAPI().fetchUserById(id);
    _userData = user;
    isLoading = false;
    notifyListeners();
    return user;
  }

  Future<void> updateProfile({required String fullname}) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    await client
        .from('profiles')
        .update({'fullname': fullname})
        .eq('id', user.id);

    // Update data lokal
    _userData = UserModel(
      id: _userData.id,
      email: _userData.email,
      fullname: fullname,
      avatar: _userData.avatar,
      role: _userData.role,
    );
    notifyListeners();
  }

  Future<UserModel?> getWhoLogin() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _userData = UserModel.fromJson(data);

      isLoading = false;
      notifyListeners();
      return _userData;
    }

    return null;
  }

  Future<UserModel> changePassword(
      String newPassword) async {
    final changedPassword =
        await UserAPI().changePassword(newPassword);
    _userData = changedPassword;
    notifyListeners();
    return changedPassword;
  }

  Future<List<EnrolledCourseModel>> getEnrolledCourse() async {
    isLoading = true;
    notifyListeners();

    final enrolled = await UserAPI().fetchEnrolledCourse();
    _enrolledCourse = enrolled;

    isLoading = false;
    notifyListeners();

    return enrolled;
  }

  Future<RequestModel> requestForm(
      String title, String requestType) async {
    final request =
        await UserAPI().requestForm(title, requestType);
    notifyListeners();
    return request;
  }

  Future<List<FAQModel>> getAllFAQ() async {
    isFaqLoading;
    final faqData = await FaqAPI().fetchAllFAQ();
    _allFAQ = faqData;
    isFaqLoading = false;
    notifyListeners();
    return allFAQ;
  }

  Future<EnrolledCourseModel> getEnrolledById(String enrolledCourseId) async {
    isLoadingData = true;
    notifyListeners();

    final enrolledData = await UserAPI().fetchEnrolledById(enrolledCourseId);

    _enrolledCourseData = enrolledData;

    isLoadingData = false;
    notifyListeners();

    return enrolledData;
  }

  Future<List<EnrolledCourseModel>> getFinishedCourse() async {
    final done = enrolledCourse.where((e) {
      final totalMaterials =
          e.course?.sections?.expand((s) => s.materials ?? []).length ?? 0;

      final completedMaterials =
          e.learningProgress?.where((r) => r.isCompleted == true).length ?? 0;

      return totalMaterials > 0 && completedMaterials == totalMaterials;
    }).toList();

    _finishedCourse = done;

    notifyListeners();

    return done;
  }

  void reset() {
    _enrolledCourse = [];
    _finishedCourse = [];
    _allFAQ = [];
    isLoading = true;
    isFaqLoading = true;
    isLoadingData = true;
    notifyListeners();
  }

  // Future<EnrolledCourseModel> updateCourseProgress(
  //     int enrolledCourseId, int materialId) async {
  //   final updateProgress =
  //       await CourseAPI().updateCourseProgress(enrolledCourseId, materialId);
  //   notifyListeners();
  //   return updateProgress;
  // }
}
