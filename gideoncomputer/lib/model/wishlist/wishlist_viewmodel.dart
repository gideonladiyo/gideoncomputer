import 'package:flutter/material.dart';
import 'package:gideoncomputer/api/wishlist_api.dart';
import 'package:gideoncomputer/model/course/course_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final _api = WishlistAPI();

  List<CourseModel> _wishlists = [];
  List<CourseModel> get wishlishedCourse => _wishlists;

  // Set untuk tracking course_id yang sudah di-wishlist (untuk toggle cepat)
  final Set<String> _wishlistedIds = {};
  bool isWishlisted(String courseId) => _wishlistedIds.contains(courseId);

  bool isLoading = false;

  /// Load semua wishlist user dari Supabase
  Future<void> fetchWishlists() async {
    isLoading = true;
    notifyListeners();
    try {
      _wishlists = await _api.fetchWishlists();
      _wishlistedIds
        ..clear()
        ..addAll(_wishlists.map((c) => c.id!));
    } catch (e) {
      print('🔴 [WishlistViewModel.fetchWishlists] ERROR: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  /// Toggle wishlist — add jika belum ada, remove jika sudah ada
  Future<void> toggleWishlist(CourseModel course) async {
    final id = course.id!;
    final wasWishlisted = _wishlistedIds.contains(id);

    // Optimistic update
    if (wasWishlisted) {
      _wishlistedIds.remove(id);
      _wishlists.removeWhere((c) => c.id == id);
    } else {
      _wishlistedIds.add(id);
      _wishlists.add(course);
    }
    notifyListeners();

    try {
      if (wasWishlisted) {
        await _api.removeWishlist(id);
      } else {
        await _api.addWishlist(id);
      }
    } catch (e) {
      // Rollback kalau gagal
      print('🔴 [WishlistViewModel.toggleWishlist] ERROR: $e');
      if (wasWishlisted) {
        _wishlistedIds.add(id);
        _wishlists.add(course);
      } else {
        _wishlistedIds.remove(id);
        _wishlists.removeWhere((c) => c.id == id);
      }
      notifyListeners();
    }
  }

  void reset() {
    _wishlists = [];
    _wishlistedIds.clear();
    isLoading = false;
    notifyListeners();
  }
}
