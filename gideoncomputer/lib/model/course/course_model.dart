import 'package:json_annotation/json_annotation.dart';

import '../category/category_model.dart';
import '../review/review_model.dart';
import '../section/section_model.dart';
import '../tools/tools_model.dart';
part 'course_model.g.dart';

@JsonSerializable()
class CourseModel {
  String? id;
  @JsonKey(name: 'course_name')
  String? courseName;
  @JsonKey(name: 'course_image')
  String? courseImage;
  @JsonKey(name: 'categories')
  CategoryModel? category;
  String? description;
  List<Section>? sections;
  List<Review>? reviews;
  // course_tools join → tools (nested)
  @JsonKey(name: 'course_tools')
  List<CourseToolsModel>? courseTools;
  @JsonKey(name: 'deleted_at')
  String? deletedAt;

  /// True jika course sudah di-soft delete oleh admin
  bool get isDeleted => deletedAt != null;

  CourseModel({
    this.id,
    this.courseName,
    this.courseImage,
    this.category,
    this.description,
    this.sections,
    this.reviews,
    this.courseTools,
    this.deletedAt,
  });

  // Helper: ambil list Tools dari join
  List<Tools> get tools =>
      courseTools?.map((ct) => ct.tool).whereType<Tools>().toList() ?? [];

  factory CourseModel.fromJson(Map<String, dynamic> json) =>
      _$CourseModelFromJson(json);
  Map<String, dynamic> toJson() => _$CourseModelToJson(this);
}
