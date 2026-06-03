import 'package:gideoncomputer/model/course/enrolled_course_model.dart';
import 'package:gideoncomputer/model/profile/user_model.dart';
import 'package:gideoncomputer/model/request/request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserAPI {
  final supabase = Supabase.instance.client;

  Future<UserModel> getWhoLogin() async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();

    return UserModel.fromJson(data);
  }

  Future<List<UserModel>> fetchAllUser() async {
    final response = await supabase.from('profiles').select();

    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> fetchUserById(String id) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .single();

    return UserModel.fromJson(response);
  }

  Future<UserModel> updateProfile({String? fullname, String? avatar}) async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('profiles')
        .update({'fullname': fullname, 'avatar': avatar})
        .eq('id', user!.id)
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  Future changePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future enrollCourse(String courseId) async {
    final user = supabase.auth.currentUser;

    await supabase.from('enrollments').insert({
      'user_id': user!.id,
      'course_id': courseId,
    });
  }

  // INI BELUM
  Future<RequestModel> requestForm(String title, String requestType) async {
    final user = supabase.auth.currentUser;

    final data = await supabase
        .from('requests')
        .insert({
          'user_id': user!.id,
          'title': title,
          'request_type': requestType,
        })
        .select()
        .single();

    return RequestModel.fromJson(data);
  }

  Future<List<EnrolledCourseModel>> fetchEnrolledCourse() async {
    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('enrollments')
        .select('''
        *,
        courses (
          *,
          sections (
            *,
            materials (*)
          )
        ),
        learning_progress (
          *,
          materials (*)
        )
      ''')
        .eq('user_id', user!.id);

    print("RAW RESPONSE: $response");

    return (response as List)
        .map((e) => EnrolledCourseModel.fromJson(e))
        .toList();
  }

  Future<EnrolledCourseModel> fetchEnrolledById(String enrollmentId) async {
    final response = await supabase
        .from('enrollments')
        .select('''
        *,
        courses (
          *,
          sections (
            *,
            materials (*)
          )
        )
      ''')
        .eq('id', enrollmentId)
        .single();

    return EnrolledCourseModel.fromJson(response);
  }
}
