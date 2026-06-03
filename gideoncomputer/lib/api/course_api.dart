import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gideoncomputer/model/course/course_model.dart';
import 'package:gideoncomputer/model/course/enrolled_course_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../model/review/review_model.dart';

class CourseAPI {
  final supabase = Supabase.instance.client;

  Future<List<CourseModel>> fetchAllCourse() async {
    print('🟡 [fetchAllCourse] START');
    try {
      // Hanya ambil course yang BELUM di-soft delete (deleted_at IS NULL)
      final response = await supabase
          .from('courses')
          .select('*, categories (*)')
          .filter('deleted_at', 'is', null);

      print(
        '🟢 [fetchAllCourse] RAW RESPONSE (${(response as List).length} items)',
      );

      final courses = <CourseModel>[];
      for (int i = 0; i < response.length; i++) {
        try {
          final course = CourseModel.fromJson(response[i]);
          courses.add(course);
        } catch (e) {
          print('🔴 [fetchAllCourse] PARSE ERROR at index $i: $e');
        }
      }
      print('🟢 [fetchAllCourse] DONE — ${courses.length} courses parsed');
      return courses;
    } catch (e, stack) {
      print('🔴 [fetchAllCourse] EXCEPTION: $e');
      print('🔴 STACK: $stack');
      rethrow;
    }
  }

  Future<CourseModel> fetchCourseById(String id) async {
    print('🟡 [fetchCourseById] id=$id');
    try {
      // fetchCourseById TIDAK memfilter deleted_at karena digunakan untuk
      // user yang sudah enrolled — mereka tetap bisa akses course yang dihapus.
      final response = await supabase
          .from('courses')
          .select('''
            *,
            categories (*),
            sections (
              *,
              materials (*)
            ),
            course_tools (
              *,
              tools (*)
            )
          ''')
          .eq('id', id)
          .single();

      final course = CourseModel.fromJson(response);
      course.sections?.forEach((section) {
        section.materials?.sort(
          (a, b) => (a.position ?? 0).compareTo(b.position ?? 0),
        );
      });
      return course;
    } catch (e, stack) {
      print('🔴 [fetchCourseById] EXCEPTION: $e');
      print('🔴 STACK: $stack');
      rethrow;
    }
  }

  Future<List<CourseModel>> searchCourseByName(String query) async {
    // Hanya tampilkan course yang BELUM di-soft delete pada hasil pencarian
    final response = await supabase
        .from('courses')
        .select()
        .ilike('course_name', '%$query%')
        .filter('deleted_at', 'is', null);
    return (response as List).map((e) => CourseModel.fromJson(e)).toList();
  }

  Future<void> enrollCourse(String courseId) async {
    final user = supabase.auth.currentUser;
    await supabase.from('enrollments').insert({
      'user_id': user!.id,
      'course_id': courseId,
    });
  }

  Future<bool> isEnrolled(String courseId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('enrollments')
        .select()
        .eq('user_id', user!.id)
        .eq('course_id', courseId);
    return (response as List).isNotEmpty;
  }

  Future<EnrolledCourseModel> getEnrollmentByCourse(String courseId) async {
    final user = supabase.auth.currentUser;
    print('🟡 [getEnrollmentByCourse] courseId=$courseId userId=${user?.id}');

    // Query ini juga TIDAK memfilter deleted_at — user yang enrolled tetap
    // bisa mengakses course meskipun sudah di-soft delete admin.
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
        .eq('user_id', user!.id)
        .eq('course_id', courseId)
        .single();

    print('🟢 [getEnrollmentByCourse] FRESH DATA: $response');

    final enrolled = EnrolledCourseModel.fromJson(response);
    enrolled.course?.sections?.forEach((section) {
      section.materials?.sort(
        (a, b) => (a.position ?? 0).compareTo(b.position ?? 0),
      );
    });
    return enrolled;
  }

  // Update learning_progress (ganti reports + progress lama)
  Future<void> updateCourseProgress(
    String enrollmentId,
    String materialId,
  ) async {
    print(
      '🟡 [updateCourseProgress] enrollmentId=$enrollmentId materialId=$materialId',
    );

    try {
      final existing = await supabase
          .from('learning_progress')
          .select()
          .eq('enrollment_id', enrollmentId)
          .eq('material_id', materialId)
          .maybeSingle();

      if (existing != null) {
        await supabase
            .from('learning_progress')
            .update({
              'is_completed': true,
              'completed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
        print('🟢 [updateCourseProgress] updated id=${existing['id']}');
      } else {
        await supabase.from('learning_progress').insert({
          'enrollment_id': enrollmentId,
          'material_id': materialId,
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        });
        print('🟢 [updateCourseProgress] inserted');
      }
    } catch (e) {
      print('🔴 [updateCourseProgress] ERROR: $e');
      rethrow;
    }
  }

  // Ambil material yang sudah completed via learning_progress
  Future<List<String>> getCompletedMaterials(String enrollmentId) async {
    final response = await supabase
        .from('learning_progress')
        .select('material_id')
        .eq('enrollment_id', enrollmentId)
        .eq('is_completed', true);
    return (response as List).map((e) => e['material_id'] as String).toList();
  }

  Future<void> redeemCourseCode(String code, String courseId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User belum login');

    // Ambil kode tanpa filter null dulu
    final result = await supabase
        .from('course_codes')
        .select()
        .eq('code', code)
        .eq('course_id', courseId)
        .maybeSingle();

    if (result == null) {
      throw Exception('Kode tidak valid');
    }

    // Cek used_by di sisi Dart — lebih reliable dari .isFilter
    if (result['used_by'] != null) {
      throw Exception('Kode sudah pernah digunakan');
    }

    // Tandai kode sebagai sudah dipakai
    await supabase
        .from('course_codes')
        .update({
          'used_by': user.id,
          'used_at': DateTime.now().toIso8601String(),
        })
        .eq('id', result['id']);

    // Cek apakah sudah pernah enroll (hindari duplikat)
    final existingEnroll = await supabase
        .from('enrollments')
        .select('id')
        .eq('user_id', user.id)
        .eq('course_id', courseId)
        .maybeSingle();

    if (existingEnroll == null) {
      await supabase.from('enrollments').insert({
        'user_id': user.id,
        'course_id': courseId,
      });
    }
  }
}
