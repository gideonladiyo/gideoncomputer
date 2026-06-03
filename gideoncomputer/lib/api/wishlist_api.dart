import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/course/course_model.dart';

class WishlistAPI {
  final supabase = Supabase.instance.client;

  String get _userId => supabase.auth.currentUser!.id;

  /// Fetch semua course yang di-wishlist user
  Future<List<CourseModel>> fetchWishlists() async {
    final response = await supabase
        .from('wishlists')
        .select('course_id, courses(*, categories(*))')
        .eq('user_id', _userId);

    return (response as List)
        .map((e) => CourseModel.fromJson(e['courses'] as Map<String, dynamic>))
        .toList();
  }

  /// Cek apakah course sudah di-wishlist
  Future<bool> isWishlisted(String courseId) async {
    final response = await supabase
        .from('wishlists')
        .select('id')
        .eq('user_id', _userId)
        .eq('course_id', courseId)
        .maybeSingle();
    return response != null;
  }

  /// Tambah wishlist
  Future<void> addWishlist(String courseId) async {
    await supabase.from('wishlists').insert({
      'user_id': _userId,
      'course_id': courseId,
    });
  }

  /// Hapus wishlist
  Future<void> removeWishlist(String courseId) async {
    await supabase
        .from('wishlists')
        .delete()
        .eq('user_id', _userId)
        .eq('course_id', courseId);
  }
}
