// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentModel _$AssessmentModelFromJson(Map<String, dynamic> json) =>
    AssessmentModel(
      id: json['id'] as String?,
      assessmentType: json['assessment_type'] as String?,
      sectionId: json['section_id'] as String?,
      courseId: json['course_id'] as String?,
      assessmentName: json['assessment_name'] as String?,
      passingScore: (json['passing_score'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssessmentModelToJson(AssessmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessment_type': instance.assessmentType,
      'section_id': instance.sectionId,
      'course_id': instance.courseId,
      'assessment_name': instance.assessmentName,
      'passing_score': instance.passingScore,
      'created_at': instance.createdAt,
      'questions': instance.questions,
    };
