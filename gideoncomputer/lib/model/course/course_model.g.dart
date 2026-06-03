// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseModel _$CourseModelFromJson(Map<String, dynamic> json) => CourseModel(
  id: json['id'] as String?,
  courseName: json['course_name'] as String?,
  courseImage: json['course_image'] as String?,
  category: json['categories'] == null
      ? null
      : CategoryModel.fromJson(json['categories'] as Map<String, dynamic>),
  description: json['description'] as String?,
  sections: (json['sections'] as List<dynamic>?)
      ?.map((e) => Section.fromJson(e as Map<String, dynamic>))
      .toList(),
  reviews: (json['reviews'] as List<dynamic>?)
      ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
      .toList(),
  courseTools: (json['course_tools'] as List<dynamic>?)
      ?.map((e) => CourseToolsModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deletedAt: json['deleted_at'] as String?,
);

Map<String, dynamic> _$CourseModelToJson(CourseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_name': instance.courseName,
      'course_image': instance.courseImage,
      'categories': instance.category,
      'description': instance.description,
      'sections': instance.sections,
      'reviews': instance.reviews,
      'course_tools': instance.courseTools,
      'deleted_at': instance.deletedAt,
    };
