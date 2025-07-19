import 'package:freezed_annotation/freezed_annotation.dart';

part 'ustadz_query_model.codegen.freezed.dart';
part 'ustadz_query_model.codegen.g.dart';

List<String>? _relationsFromJson(dynamic json) {
  if (json == null) return null;
  return List<String>.from(json);
}

String? _relationsToJson(List<String>? relations) {
  if (relations == null) return null;
  return relations.join(',');
}

@freezed
abstract class UstadzQueryModel with _$UstadzQueryModel {
  const factory UstadzQueryModel({
    int? page,
    String? q,
    String? type,
    @JsonKey(name: 'limit') int? limit,
    @JsonKey(name: 'order_by') String? orderBy,
    @JsonKey(name: 'sort_by') String? sortBy,
    @JsonKey(
      name: 'relations',
      toJson: _relationsToJson,
      fromJson: _relationsFromJson,
    )
    List<String>? relations,
  }) = _UstadzQueryModel;

  factory UstadzQueryModel.fromJson(Map<String, dynamic> json) =>
      _$UstadzQueryModelFromJson(json);
}
