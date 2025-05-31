import 'package:freezed_annotation/freezed_annotation.dart';

import 'kajian_schedules_response_model.codegen.dart';

part 'kajian_schedule_response_model.codegen.freezed.dart';

part 'kajian_schedule_response_model.codegen.g.dart';

@freezed
abstract class KajianScheduleResponseModel with _$KajianScheduleResponseModel {
  const factory KajianScheduleResponseModel({
    DataKajianScheduleModel? data,
  }) = _KajianScheduleResponseModel;

  factory KajianScheduleResponseModel.fromJson(Map<String, dynamic> json) =>
      _$KajianScheduleResponseModelFromJson(json);
}
