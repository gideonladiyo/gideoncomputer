import 'package:json_annotation/json_annotation.dart';
import 'package:gideoncomputer/model/materials/materials_model.dart';
part 'learning_progress_model.g.dart';

@JsonSerializable()
class LearningProgressModel {
  String? id;
  @JsonKey(name: 'enrollment_id')
  String? enrollmentId;
  @JsonKey(name: 'material_id')
  String? materialId;
  @JsonKey(name: 'is_completed')
  bool? isCompleted;
  @JsonKey(name: 'completed_at')
  String? completedAt;
  @JsonKey(name: 'created_at')
  String? createdAt;
  // nested join opsional
  @JsonKey(name: 'materials')
  Materials? material;

  LearningProgressModel({
    this.id,
    this.enrollmentId,
    this.materialId,
    this.isCompleted,
    this.completedAt,
    this.createdAt,
    this.material,
  });

  String? get resolvedMaterialId => materialId ?? material?.id;

  factory LearningProgressModel.fromJson(Map<String, dynamic> json) =>
      _$LearningProgressModelFromJson(json);
  Map<String, dynamic> toJson() => _$LearningProgressModelToJson(this);
}
