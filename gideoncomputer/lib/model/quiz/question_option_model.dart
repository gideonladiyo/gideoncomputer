import 'package:json_annotation/json_annotation.dart';
part 'question_option_model.g.dart';

@JsonSerializable()
class QuestionOptionModel {
  String? id;
  @JsonKey(name: 'question_id')
  String? questionId;
  @JsonKey(name: 'option_text')
  String? optionText;
  @JsonKey(name: 'is_correct')
  bool? isCorrect;

  QuestionOptionModel({
    this.id,
    this.questionId,
    this.optionText,
    this.isCorrect,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionOptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionOptionModelToJson(this);
}
