// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrolled_course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnrolledCourseModel _$EnrolledCourseModelFromJson(Map<String, dynamic> json) =>
    EnrolledCourseModel(
      id: json['id'] as String?,
      course: json['courses'] == null
          ? null
          : CourseModel.fromJson(json['courses'] as Map<String, dynamic>),
      learningProgress: (json['learning_progress'] as List<dynamic>?)
          ?.map(
            (e) => LearningProgressModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$EnrolledCourseModelToJson(
  EnrolledCourseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'courses': instance.course?.toJson(),
  'learning_progress': instance.learningProgress
      ?.map((e) => e.toJson())
      .toList(),
};
