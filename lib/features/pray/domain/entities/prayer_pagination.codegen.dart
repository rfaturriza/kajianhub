import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_pagination.codegen.freezed.dart';

@freezed
abstract class PrayerPaginationLinks with _$PrayerPaginationLinks {
  const factory PrayerPaginationLinks({
    String? first,
    String? last,
    String? prev,
    String? next,
  }) = _PrayerPaginationLinks;
}

@freezed
abstract class PrayerPaginationMeta with _$PrayerPaginationMeta {
  const factory PrayerPaginationMeta({
    required int currentPage,
    required int from,
    required int lastPage,
    required String path,
    required int perPage,
    required int to,
    required int total,
  }) = _PrayerPaginationMeta;
}
