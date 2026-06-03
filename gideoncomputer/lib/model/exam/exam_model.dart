import 'package:json_annotation/json_annotation.dart';
import '../quiz/question_model.dart';
part 'exam_model.g.dart';

@JsonSerializable()
class ExamModel {
  String? id;
  @JsonKey(name: 'course_id')
  String? courseId;
  @JsonKey(name: 'exam_name')
  String? examName;
  @JsonKey(name: 'passing_score')
  int? passingScore;
  @JsonKey(name: 'created_at')
  String? createdAt;
  List<QuestionModel>? questions;

  ExamModel({
    this.id,
    this.courseId,
    this.examName,
    this.passingScore,
    this.createdAt,
    this.questions,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamModelToJson(this);
}
