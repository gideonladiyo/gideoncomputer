// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateModel _$CertificateModelFromJson(Map<String, dynamic> json) =>
    CertificateModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      courseId: json['course_id'] as String?,
      examAttemptId: json['exam_attempt_id'] as String?,
      certificateNumber: json['certificate_number'] as String?,
      issuedAt: json['issued_at'] as String?,
      course: json['course'] == null
          ? null
          : CourseModel.fromJson(json['course'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CertificateModelToJson(CertificateModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'course_id': instance.courseId,
      'exam_attempt_id': instance.examAttemptId,
      'certificate_number': instance.certificateNumber,
      'issued_at': instance.issuedAt,
      'course': instance.course,
    };
