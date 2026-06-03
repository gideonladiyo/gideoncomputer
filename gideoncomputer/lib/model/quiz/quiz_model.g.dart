// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) => QuizModel(
  id: json['id'] as String?,
  sectionId: json['section_id'] as String?,
  quizName: json['quiz_name'] as String?,
  passingScore: (json['passing_score'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  questions: (json['questions'] as List<dynamic>?)
      ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuizModelToJson(QuizModel instance) => <String, dynamic>{
  'id': instance.id,
  'section_id': instance.sectionId,
  'quiz_name': instance.quizName,
  'passing_score': instance.passingScore,
  'created_at': instance.createdAt,
  'questions': instance.questions,
};
