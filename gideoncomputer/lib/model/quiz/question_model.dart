import 'package:json_annotation/json_annotation.dart';
import 'question_option_model.dart';
part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  String? id;
  @JsonKey(name: 'assessment_id')
  String? assessmentId;
  @JsonKey(name: 'question_text')
  String? questionText;
  @JsonKey(name: 'question_type')
  String? questionType;
  @JsonKey(name: 'question_options')
  List<QuestionOptionModel>? options;

  QuestionModel({
    this.id,
    this.assessmentId,
    this.questionText,
    this.questionType,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}
