import 'package:json_annotation/json_annotation.dart';
import '../course/course_model.dart';
part 'certificate_model.g.dart';

@JsonSerializable()
class CertificateModel {
  String? id;
  @JsonKey(name: 'user_id')
  String? userId;
  @JsonKey(name: 'course_id')
  String? courseId;
  @JsonKey(name: 'exam_attempt_id')
  String? examAttemptId;
  @JsonKey(name: 'certificate_number')
  String? certificateNumber;
  @JsonKey(name: 'issued_at')
  String? issuedAt;
  CourseModel? course;

  CertificateModel({
    this.id,
    this.userId,
    this.courseId,
    this.examAttemptId,
    this.certificateNumber,
    this.issuedAt,
    this.course,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) =>
      _$CertificateModelFromJson(json);
  Map<String, dynamic> toJson() => _$CertificateModelToJson(this);
}
