import 'package:json_annotation/json_annotation.dart';
import 'quiz_model.dart';
import 'quiz_answer_model.dart';
part 'quiz_attempt_model.g.dart';

@JsonSerializable()
class QuizAttemptModel {
  String? id;
  @JsonKey(name: 'user_id')
  String? userId;
  @JsonKey(name: 'quiz_id')
  String? quizId;
  int? score;
  @JsonKey(name: 'is_passed')
  bool? isPassed;
  @JsonKey(name: 'started_at')
  String? startedAt;
  @JsonKey(name: 'submitted_at')
  String? submittedAt;
  QuizModel? quiz;
  List<QuizAnswerModel>? answers;

  QuizAttemptModel({
    this.id,
    this.userId,
    this.quizId,
    this.score,
    this.isPassed,
    this.startedAt,
    this.submittedAt,
    this.quiz,
    this.answers,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuizAttemptModelToJson(this);
}
