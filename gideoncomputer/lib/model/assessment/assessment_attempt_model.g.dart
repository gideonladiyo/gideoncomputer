// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentAttemptModel _$AssessmentAttemptModelFromJson(
  Map<String, dynamic> json,
) => AssessmentAttemptModel(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  assessmentId: json['assessment_id'] as String?,
  score: (json['score'] as num?)?.toInt(),
  isPassed: json['is_passed'] as bool?,
  startedAt: json['started_at'] as String?,
  submittedAt: json['submitted_at'] as String?,
  assessment: json['assessment'] == null
      ? null
      : AssessmentModel.fromJson(json['assessment'] as Map<String, dynamic>),
  answers: (json['answers'] as List<dynamic>?)
      ?.map((e) => AssessmentAnswerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AssessmentAttemptModelToJson(
  AssessmentAttemptModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'assessment_id': instance.assessmentId,
  'score': instance.score,
  'is_passed': instance.isPassed,
  'started_at': instance.startedAt,
  'submitted_at': instance.submittedAt,
  'assessment': instance.assessment,
  'answers': instance.answers,
};
