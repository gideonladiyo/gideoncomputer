import 'package:json_annotation/json_annotation.dart';
part 'tools_model.g.dart';

@JsonSerializable()
class Tools {
  String id;
  @JsonKey(name: 'tool_name')
  String? toolsName;
  @JsonKey(name: 'tool_icon')
  String? toolsIcon;
  @JsonKey(name: 'tool_url')
  String? url;
  @JsonKey(name: 'created_at')
  String? createdAt;

  Tools({
    required this.id,
    this.toolsName,
    this.toolsIcon,
    this.url,
    this.createdAt,
  });

  factory Tools.fromJson(Map<String, dynamic> json) => _$ToolsFromJson(json);
  Map<String, dynamic> toJson() => _$ToolsToJson(this);
}

@JsonSerializable()
class CourseToolsModel {
  String? id;
  @JsonKey(name: 'course_id')
  String? courseId;
  @JsonKey(name: 'tool_id')
  String? toolId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'tools')
  Tools? tool;

  CourseToolsModel({
    this.id,
    this.courseId,
    this.toolId,
    this.createdAt,
    this.tool,
  });

  factory CourseToolsModel.fromJson(Map<String, dynamic> json) =>
      _$CourseToolsModelFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToolsModelToJson(this);
}
