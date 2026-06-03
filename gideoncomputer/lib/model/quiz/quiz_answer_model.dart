import 'package:json_annotation/json_annotation.dart';
import 'question_model.dart';
import 'question_option_model.dart';
part 'quiz_answer_model.g.dart';

@JsonSerializable()
class QuizAnswerModel {
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

  QuizAnswerModel({
    this.id,
    this.attemptId,
    this.questionId,
    this.selectedOptionId,
    this.isCorrect,
    this.question,
    this.selectedOption,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAnswerModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuizAnswerModelToJson(this);
}
