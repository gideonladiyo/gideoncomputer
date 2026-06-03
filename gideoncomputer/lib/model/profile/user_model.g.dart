// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    UserModel(
        id: json['id'] as String?,
        avatar: json['profile_image'] as String?,
        fullname: json['fullname'] as String?,
        email: json['email'] as String?,
        password: json['password'] as String?,
        role: json['role'] as String?,
      )
      ..enrolledCourse = (json['enrolled_course'] as List<dynamic>?)
          ?.map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'profile_image': instance.avatar,
  'fullname': instance.fullname,
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
  'enrolled_course': instance.enrolledCourse,
};
