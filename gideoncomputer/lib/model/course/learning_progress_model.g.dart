// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LearningProgressModel _$LearningProgressModelFromJson(
  Map<String, dynamic> json,
) => LearningProgressModel(
  id: json['id'] as String?,
  enrollmentId: json['enrollment_id'] as String?,
  materialId: json['material_id'] as String?,
  isCompleted: json['is_completed'] as bool?,
  completedAt: json['completed_at'] as String?,
  createdAt: json['created_at'] as String?,
  material: json['materials'] == null
      ? null
      : Materials.fromJson(json['materials'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LearningProgressModelToJson(
  LearningProgressModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'enrollment_id': instance.enrollmentId,
  'material_id': instance.materialId,
  'is_completed': instance.isCompleted,
  'completed_at': instance.completedAt,
  'created_at': instance.createdAt,
  'materials': instance.material,
};
