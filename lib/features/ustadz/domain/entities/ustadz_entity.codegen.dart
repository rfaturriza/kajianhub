import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';

part 'ustadz_entity.codegen.freezed.dart';

@freezed
abstract class UstadzEntityPagination with _$UstadzEntityPagination {
  const factory UstadzEntityPagination({
    List<UstadzEntity>? data,
    LinksKajianSchedule? links,
    MetaKajianHub? meta,
  }) = _UstadzEntityPagination;
}

@freezed
abstract class UstadzEntity with _$UstadzEntity {
  const factory UstadzEntity({
    required int id,
    required String name,
    required String email,
    String? placeOfBirth,
    String? dateOfBirth,
    String? contactPerson,
    String? pictureUrl,
    String? subscribersCount,
    String? kajianCount,
  }) = _UstadzEntity;
}

@freezed
abstract class UstadzListEntity with _$UstadzListEntity {
  const factory UstadzListEntity({
    List<UstadzEntity>? data,
    MetaKajianHub? meta,
  }) = _UstadzListEntity;
}