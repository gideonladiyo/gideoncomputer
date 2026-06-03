import 'package:gideoncomputer/api/category_api.dart';
import 'package:gideoncomputer/model/course/course_model.dart';
import 'package:flutter/material.dart';

import '../../api/course_api.dart';
import '../category/category_model.dart';
import '../review/review_model.dart';

class CourseViewModel extends ChangeNotifier {
  bool isLoadingCategory = true;
  bool isLoadingCourse = true;

  List<CategoryModel> _allCategory = [];
  List<CategoryModel> get allCategory => _allCategory;

  List<CourseModel> _allCourse = [];
  List<CourseModel> _filteredCourse = [];
  List<CourseModel> get allCourse => _filteredCourse;

  List<Review> _allReview = [];
  List<Review>? get allReview => _allReview;

  late CourseModel _courseData;
  CourseModel get courseData => _courseData;

  Future<List<CategoryModel>> getAllCategory() async {
    print('🟡 [CourseViewModel.getAllCategory] START');
    isLoadingCategory = true;
    notifyListeners();
    try {
      final categoryData = await CategoryAPI().fetchAllCategory();
      _allCategory = categoryData;
      print(
        '🟢 [CourseViewModel.getAllCategory] ${categoryData.length} categories loaded',
      );
      isLoadingCategory = false;
      notifyListeners();
      return allCategory;
    } catch (e, stack) {
      print('🔴 [CourseViewModel.getAllCategory] ERROR: $e');
      print('🔴 STACK: $stack');
      isLoadingCategory = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<CourseModel>> getAllCourse() async {
    print('🟡 [CourseViewModel.getAllCourse] START');
    isLoadingCourse = true;
    notifyListeners();
    try {
      final courseData = await CourseAPI().fetchAllCourse();
      // API sudah memfilter deleted_at IS NULL, tapi kita double-check
      // di sini sebagai safety net — pastikan tidak ada soft-deleted yang lolos.
      _allCourse = courseData.where((c) => !c.isDeleted).toList();
      _filteredCourse = _allCourse;
      print(
        '🟢 [CourseViewModel.getAllCourse] ${_allCourse.length} courses loaded, notifying listeners',
      );
      isLoadingCourse = false;
      notifyListeners();
      return _allCourse;
    } catch (e, stack) {
      print('🔴 [CourseViewModel.getAllCourse] ERROR: $e');
      print('🔴 STACK: $stack');
      isLoadingCourse = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<CourseModel> getCourseById(String id) async {
    final course = await CourseAPI().fetchCourseById(id);
    _courseData = course;
    isLoadingCourse = false;
    notifyListeners();
    return course;
  }

  Future<void> enrollCourse(String courseId) async {
    try {
      await CourseAPI().enrollCourse(courseId);
    } catch (e) {
      print('🔴 [CourseViewModel.enrollCourse] ERROR: $e');
      rethrow;
    }
  }

  Future<List<CourseModel>> searchCourseByName(String query) async {
    print('🟡 [CourseViewModel.searchCourseByName] query=$query');
    if (query.isEmpty) {
      _filteredCourse = _allCourse;
      notifyListeners();
      return _allCourse;
    }
    final data = await CourseAPI().searchCourseByName(query);
    // API sudah memfilter, tapi kita pastikan lagi
    _filteredCourse = data.where((c) => !c.isDeleted).toList();
    notifyListeners();
    return _filteredCourse;
  }

  Future<List<CourseModel>> filterCourseByCategory(String query) async {
    print(
      '🟡 [CourseViewModel.filterCourseByCategory] query=$query, _allCourse.length=${_allCourse.length}',
    );
    if (query == 'All' || query.isEmpty) {
      _filteredCourse = _allCourse;
    } else {
      _filteredCourse = _allCourse
          .where((e) => e.category?.categoryName == query)
          .toList();
    }
    print(
      '🟢 [CourseViewModel.filterCourseByCategory] _filteredCourse.length=${_filteredCourse.length}',
    );
    notifyListeners();
    return _filteredCourse;
  }

  void reset() {
    isLoadingCategory = true;
    isLoadingCourse = true;
    _allCategory = [];
    _allCourse = [];
    _filteredCourse = [];
    _allReview = [];
    notifyListeners();
  }
}
