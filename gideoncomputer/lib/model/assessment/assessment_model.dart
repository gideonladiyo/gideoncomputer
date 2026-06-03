import 'package:json_annotation/json_annotation.dart';
import '../quiz/question_model.dart';
part 'assessment_model.g.dart';

@JsonSerializable()
class AssessmentModel {
  String? id;
  @JsonKey(name: 'assessment_type')
  String? assessmentType; // 'quiz' | 'exam'
  @JsonKey(name: 'section_id')
  String? sectionId;
  @JsonKey(name: 'course_id')
  String? courseId;
  @JsonKey(name: 'assessment_name')
  String? assessmentName;
  @JsonKey(name: 'passing_score')
  int? passingScore;
  @JsonKey(name: 'created_at')
  String? createdAt;
  List<QuestionModel>? questions;

  AssessmentModel({
    this.id,
    this.assessmentType,
    this.sectionId,
    this.courseId,
    this.assessmentName,
    this.passingScore,
    this.createdAt,
    this.questions,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentModelToJson(this);
}
