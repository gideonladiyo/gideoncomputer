// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamModel _$ExamModelFromJson(Map<String, dynamic> json) => ExamModel(
  id: json['id'] as String?,
  courseId: json['course_id'] as String?,
  examName: json['exam_name'] as String?,
  passingScore: (json['passing_score'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  questions: (json['questions'] as List<dynamic>?)
      ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ExamModelToJson(ExamModel instance) => <String, dynamic>{
  'id': instance.id,
  'course_id': instance.courseId,
  'exam_name': instance.examName,
  'passing_score': instance.passingScore,
  'created_at': instance.createdAt,
  'questions': instance.questions,
};
