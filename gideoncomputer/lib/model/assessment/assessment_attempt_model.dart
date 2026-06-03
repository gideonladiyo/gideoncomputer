import 'package:json_annotation/json_annotation.dart';
import 'assessment_model.dart';
import 'assessment_answer_model.dart';
part 'assessment_attempt_model.g.dart';

@JsonSerializable()
class AssessmentAttemptModel {
  String? id;
  @JsonKey(name: 'user_id')
  String? userId;
  @JsonKey(name: 'assessment_id')
  String? assessmentId;
  int? score;
  @JsonKey(name: 'is_passed')
  bool? isPassed;
  @JsonKey(name: 'started_at')
  String? startedAt;
  @JsonKey(name: 'submitted_at')
  String? submittedAt;
  AssessmentModel? assessment;
  List<AssessmentAnswerModel>? answers;

  AssessmentAttemptModel({
    this.id,
    this.userId,
    this.assessmentId,
    this.score,
    this.isPassed,
    this.startedAt,
    this.submittedAt,
    this.assessment,
    this.answers,
  });

  factory AssessmentAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentAttemptModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentAttemptModelToJson(this);
}
