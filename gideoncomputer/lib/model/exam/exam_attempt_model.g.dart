// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamAttemptModel _$ExamAttemptModelFromJson(Map<String, dynamic> json) =>
    ExamAttemptModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      examId: json['exam_id'] as String?,
      score: (json['score'] as num?)?.toInt(),
      isPassed: json['is_passed'] as bool?,
      startedAt: json['started_at'] as String?,
      submittedAt: json['submitted_at'] as String?,
      exam: json['exam'] == null
          ? null
          : ExamModel.fromJson(json['exam'] as Map<String, dynamic>),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => ExamAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ExamAttemptModelToJson(ExamAttemptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'exam_id': instance.examId,
      'score': instance.score,
      'is_passed': instance.isPassed,
      'started_at': instance.startedAt,
      'submitted_at': instance.submittedAt,
      'exam': instance.exam,
      'answers': instance.answers,
    };
