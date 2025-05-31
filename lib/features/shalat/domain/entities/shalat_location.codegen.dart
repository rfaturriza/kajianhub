import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/shalat/data/models/shalat_location_model.codegen.dart';

part 'shalat_location.codegen.freezed.dart';

@freezed
abstract class ShalatLocation with _$ShalatLocation {
  const factory ShalatLocation({
    String? id,
    String? location,
  }) = _ShalatLocation;

  const ShalatLocation._();
  ShalatLocationModel toModel() => ShalatLocationModel(
        id: id,
        location: location,
      );
}
