import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_location_query_model.codegen.freezed.dart';
part 'study_location_query_model.codegen.g.dart';

@freezed
abstract class StudyLocationQueryModel with _$StudyLocationQueryModel {
  const factory StudyLocationQueryModel({
    String? q,
    @Default('pagination') String type,
    @Default(1) int page,
    @Default(50) int limit,
    @Default('kajian_count') @JsonKey(name: 'order_by') String orderBy,
    @Default('desc') @JsonKey(name: 'sort_by') String sortBy,
    @Default('province,city') String relations,
    @Default(1) @JsonKey(name: 'is_custom_order') int isCustomOrder,
    double? latitude,
    double? longitude,
  }) = _StudyLocationQueryModel;

  factory StudyLocationQueryModel.fromJson(Map<String, dynamic> json) =>
      _$StudyLocationQueryModelFromJson(json);
}
