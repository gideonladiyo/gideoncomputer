import 'package:json_annotation/json_annotation.dart';
import 'package:gideoncomputer/model/materials/materials_model.dart';
part 'reports_model.g.dart';

@JsonSerializable()
class ReportsModel {
  String? id;
  @JsonKey(name: 'is_completed')
  bool? isCompleted;
  // Field langsung dari kolom DB — tidak perlu join
  @JsonKey(name: 'material_id')
  String? materialId;
  // Nested join (opsional, bisa null kalau query tidak include join)
  Materials? material;

  ReportsModel({this.id, this.isCompleted, this.materialId, this.material});

  factory ReportsModel.fromJson(Map<String, dynamic> json) =>
      _$ReportsModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReportsModelToJson(this);

  /// ID material — pakai materialId langsung, fallback ke nested material.id
  String? get resolvedMaterialId => materialId ?? material?.id;
}
