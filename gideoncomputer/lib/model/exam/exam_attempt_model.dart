import 'package:json_annotation/json_annotation.dart';
import 'exam_model.dart';
import 'exam_answer_model.dart';
part 'exam_attempt_model.g.dart';

@JsonSerializable()
class ExamAttemptModel {
  String? id;
  @JsonKey(name: 'user_id')
  String? userId;
  @JsonKey(name: 'exam_id')
  String? examId;
  int? score;
  @JsonKey(name: 'is_passed')
  bool? isPassed;
  @JsonKey(name: 'started_at')
  String? startedAt;
  @JsonKey(name: 'submitted_at')
  String? submittedAt;
  ExamModel? exam;
  List<ExamAnswerModel>? answers;

  ExamAttemptModel({
    this.id,
    this.userId,
    this.examId,
    this.score,
    this.isPassed,
    this.startedAt,
    this.submittedAt,
    this.exam,
    this.answers,
  });

  factory ExamAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$ExamAttemptModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamAttemptModelToJson(this);
}
