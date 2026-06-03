// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamAnswerModel _$ExamAnswerModelFromJson(Map<String, dynamic> json) =>
    ExamAnswerModel(
      id: json['id'] as String?,
      attemptId: json['attempt_id'] as String?,
      questionId: json['question_id'] as String?,
      selectedOptionId: json['selected_option_id'] as String?,
      isCorrect: json['is_correct'] as bool?,
      question: json['question'] == null
          ? null
          : QuestionModel.fromJson(json['question'] as Map<String, dynamic>),
      selectedOption: json['selected_option'] == null
          ? null
          : QuestionOptionModel.fromJson(
              json['selected_option'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ExamAnswerModelToJson(ExamAnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attempt_id': instance.attemptId,
      'question_id': instance.questionId,
      'selected_option_id': instance.selectedOptionId,
      'is_correct': instance.isCorrect,
      'question': instance.question,
      'selected_option': instance.selectedOption,
    };
