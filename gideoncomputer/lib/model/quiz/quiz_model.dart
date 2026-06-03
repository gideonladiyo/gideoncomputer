import 'package:json_annotation/json_annotation.dart';
import 'question_model.dart';
part 'quiz_model.g.dart';

@JsonSerializable()
class QuizModel {
  String? id;
  @JsonKey(name: 'section_id')
  String? sectionId;
  @JsonKey(name: 'quiz_name')
  String? quizName;
  @JsonKey(name: 'passing_score')
  int? passingScore;
  @JsonKey(name: 'created_at')
  String? createdAt;
  List<QuestionModel>? questions;

  QuizModel({
    this.id,
    this.sectionId,
    this.quizName,
    this.passingScore,
    this.createdAt,
    this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
  Map<String, dynamic> toJson() => _$QuizModelToJson(this);
}
