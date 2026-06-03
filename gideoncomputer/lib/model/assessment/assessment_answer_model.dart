import 'package:json_annotation/json_annotation.dart';
import '../quiz/question_model.dart';
import '../quiz/question_option_model.dart';
part 'assessment_answer_model.g.dart';

@JsonSerializable()
class AssessmentAnswerModel {
  String? id;
  @JsonKey(name: 'attempt_id')
  String? attemptId;
  @JsonKey(name: 'question_id')
  String? questionId;
  @JsonKey(name: 'selected_option_id')
  String? selectedOptionId;
  @JsonKey(name: 'is_correct')
  bool? isCorrect;
  QuestionModel? question;
  @JsonKey(name: 'selected_option')
  QuestionOptionModel? selectedOption;

  AssessmentAnswerModel({
    this.id,
    this.attemptId,
    this.questionId,
    this.selectedOptionId,
    this.isCorrect,
    this.question,
    this.selectedOption,
  });

  factory AssessmentAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentAnswerModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentAnswerModelToJson(this);
}
