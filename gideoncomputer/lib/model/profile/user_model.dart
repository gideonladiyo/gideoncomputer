import 'package:gideoncomputer/model/course/course_model.dart';
import 'package:json_annotation/json_annotation.dart';

import '../category/category_model.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  String? id;
  @JsonKey(name: 'profile_image')
  String? avatar;
  String? fullname;
  String? email;
  String? password;
  String? role;
  @JsonKey(name: 'enrolled_course')
  List<CourseModel>? enrolledCourse;
  // List<WishlistModel>? wishlist;
  // List<Review>? reviews;

  UserModel({
    this.id,
    this.avatar,
    this.fullname,
    this.email,
    this.password,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
