// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tools_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tools _$ToolsFromJson(Map<String, dynamic> json) => Tools(
  id: json['id'] as String,
  toolsName: json['tool_name'] as String?,
  toolsIcon: json['tool_icon'] as String?,
  url: json['tool_url'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ToolsToJson(Tools instance) => <String, dynamic>{
  'id': instance.id,
  'tool_name': instance.toolsName,
  'tool_icon': instance.toolsIcon,
  'tool_url': instance.url,
  'created_at': instance.createdAt,
};

CourseToolsModel _$CourseToolsModelFromJson(Map<String, dynamic> json) =>
    CourseToolsModel(
      id: json['id'] as String?,
      courseId: json['course_id'] as String?,
      toolId: json['tool_id'] as String?,
      createdAt: json['created_at'] as String?,
      tool: json['tools'] == null
          ? null
          : Tools.fromJson(json['tools'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseToolsModelToJson(CourseToolsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_id': instance.courseId,
      'tool_id': instance.toolId,
      'created_at': instance.createdAt,
      'tools': instance.tool,
    };
