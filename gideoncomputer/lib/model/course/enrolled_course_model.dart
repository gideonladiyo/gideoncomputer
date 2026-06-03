import 'package:json_annotation/json_annotation.dart';

import '../../model/course/course_model.dart';
import '../../model/course/learning_progress_model.dart';

part 'enrolled_course_model.g.dart';

@JsonSerializable(explicitToJson: true)
class EnrolledCourseModel {
  String? id;

  @JsonKey(name: 'courses')
  CourseModel? course;

  @JsonKey(name: 'learning_progress')
  List<LearningProgressModel>? learningProgress;

  EnrolledCourseModel({
    this.id,
    this.course,
    this.learningProgress,
  });

  factory EnrolledCourseModel.fromJson(Map<String, dynamic> json) =>
      _$EnrolledCourseModelFromJson(json);

  Map<String, dynamic> toJson() => _$EnrolledCourseModelToJson(this);
}
