// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionOptionModel _$QuestionOptionModelFromJson(Map<String, dynamic> json) =>
    QuestionOptionModel(
      id: json['id'] as String?,
      questionId: json['question_id'] as String?,
      optionText: json['option_text'] as String?,
      isCorrect: json['is_correct'] as bool?,
    );

Map<String, dynamic> _$QuestionOptionModelToJson(
  QuestionOptionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'question_id': instance.questionId,
  'option_text': instance.optionText,
  'is_correct': instance.isCorrect,
};
