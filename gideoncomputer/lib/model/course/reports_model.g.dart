// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportsModel _$ReportsModelFromJson(Map<String, dynamic> json) => ReportsModel(
  id: json['id'] as String?,
  isCompleted: json['is_completed'] as bool?,
  materialId: json['material_id'] as String?,
  material: json['material'] == null
      ? null
      : Materials.fromJson(json['material'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReportsModelToJson(ReportsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_completed': instance.isCompleted,
      'material_id': instance.materialId,
      'material': instance.material,
    };
