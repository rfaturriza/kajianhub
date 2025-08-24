import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/kajian/data/models/kajian_schedules_response_model.codegen.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

part 'ustadz_response_model.codegen.freezed.dart';
part 'ustadz_response_model.codegen.g.dart';

@freezed
abstract class UstadzResponseModel with _$UstadzResponseModel {
  const factory UstadzResponseModel({
    List<DataUstadzModel>? data,
    LinksKajianHubModel? links,
    MetaKajianHubModel? meta,
  }) = _UstadzResponseModel;

  factory UstadzResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UstadzResponseModelFromJson(json);

  const UstadzResponseModel._();

  UstadzListEntity toUstadzListEntity() {
    return UstadzListEntity(
      data: data?.map((e) => e.toEntity()).toList() ?? [],
      meta: meta?.toEntity(),
    );
  }
}

@freezed
abstract class DataUstadzModel with _$DataUstadzModel {
  const factory DataUstadzModel({
    int? id,
    @JsonKey(name: 'ustadz_id') String? ustadzId,
    String? name,
    String? email,
    bool? isAdmin,
    bool? isAdminMasjid,
    bool? isUstadz,
    List<UstadzRolesModel>? roles,
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'contact_person') String? contactPerson,
    @JsonKey(name: 'email_verified_at') String? emailVerifiedAt,
    @JsonKey(name: 'province_id') String? provinceId,
    @JsonKey(name: 'city_id') String? cityId,
    String? picture,
    @JsonKey(name: 'picture_url') String? pictureUrl,
    @JsonKey(name: 'subscribers_count') String? subscribersCount,
    @JsonKey(name: 'kajian_count') String? kajianCount,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'deleted_by') String? deletedBy,
  }) = _DataUstadzModel;

  const DataUstadzModel._();

  factory DataUstadzModel.fromJson(Map<String, dynamic> json) =>
      _$DataUstadzModelFromJson(json);

  UstadzEntity toEntity() {
    return UstadzEntity(
      id: id ?? 0,
      name: name ?? '',
      email: email ?? '',
      placeOfBirth: placeOfBirth,
      dateOfBirth: dateOfBirth,
      contactPerson: contactPerson,
      pictureUrl: pictureUrl,
      subscribersCount: subscribersCount,
      kajianCount: kajianCount,
    );
  }

  factory DataUstadzModel.fromEntity(UstadzEntity entity) {
    return DataUstadzModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      placeOfBirth: entity.placeOfBirth,
      dateOfBirth: entity.dateOfBirth,
      contactPerson: entity.contactPerson,
      pictureUrl: entity.pictureUrl,
      subscribersCount: entity.subscribersCount,
      kajianCount: entity.kajianCount,
    );
  }
}

@freezed
abstract class UstadzRolesModel with _$UstadzRolesModel {
  const factory UstadzRolesModel({
    int? id,
    @JsonKey(name: 'user_id') String? userId,
    @JsonKey(name: 'role_id') String? roleId,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _UstadzRolesModel;

  factory UstadzRolesModel.fromJson(Map<String, dynamic> json) =>
      _$UstadzRolesModelFromJson(json);
}
