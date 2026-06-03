// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAttemptModel _$QuizAttemptModelFromJson(Map<String, dynamic> json) =>
    QuizAttemptModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      quizId: json['quiz_id'] as String?,
      score: (json['score'] as num?)?.toInt(),
      isPassed: json['is_passed'] as bool?,
      startedAt: json['started_at'] as String?,
      submittedAt: json['submitted_at'] as String?,
      quiz: json['quiz'] == null
          ? null
          : QuizModel.fromJson(json['quiz'] as Map<String, dynamic>),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => QuizAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$QuizAttemptModelToJson(QuizAttemptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'quiz_id': instance.quizId,
      'score': instance.score,
      'is_passed': instance.isPassed,
      'started_at': instance.startedAt,
      'submitted_at': instance.submittedAt,
      'quiz': instance.quiz,
      'answers': instance.answers,
    };
