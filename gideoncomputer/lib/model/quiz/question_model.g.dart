// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: json['id'] as String?,
      assessmentId: json['assessment_id'] as String?,
      questionText: json['question_text'] as String?,
      questionType: json['question_type'] as String?,
      options: (json['question_options'] as List<dynamic>?)
          ?.map((e) => QuestionOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessment_id': instance.assessmentId,
      'question_text': instance.questionText,
      'question_type': instance.questionType,
      'question_options': instance.options,
    };
