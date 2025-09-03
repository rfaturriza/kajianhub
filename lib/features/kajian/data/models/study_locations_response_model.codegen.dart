import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/study_location_entity.dart';
import 'kajian_schedules_response_model.codegen.dart';

part 'study_locations_response_model.codegen.freezed.dart';
part 'study_locations_response_model.codegen.g.dart';

@freezed
abstract class StudyLocationResponseModel with _$StudyLocationResponseModel {
  const factory StudyLocationResponseModel({
    List<DataStudyLocationModel>? data,
    LinksKajianHubModel? links,
    MetaKajianHubModel? meta,
  }) = _StudyLocationResponseModel;

  factory StudyLocationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$StudyLocationResponseModelFromJson(json);

  const StudyLocationResponseModel._();

  StudyLocationsEntity toEntity() {
    return StudyLocationsEntity(
      data: data?.map((e) => e.toEntity()).toList() ?? [],
      links: links?.toEntity(),
      meta: meta?.toEntity(),
    );
  }
}

@freezed
abstract class DataStudyLocationModel with _$DataStudyLocationModel {
  const factory DataStudyLocationModel({
    int? id,
    String? name,
    String? village,
    String? address,
    @JsonKey(name: 'province_id') String? provinceId,
    @JsonKey(name: 'city_id') String? cityId,
    @JsonKey(name: 'google_maps') String? googleMaps,
    String? longitude,
    String? latitude,
    @JsonKey(name: 'contact_person') String? contactPerson,
    String? picture,
    @JsonKey(name: 'picture_url') String? pictureUrl,
    ProvinceModel? province,
    CityModel? city,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? description,
    @JsonKey(name: 'distance_in_km') double? distanceInKm,
    @JsonKey(name: 'youtube_channel_link') String? youtubeChannelLink,
    @JsonKey(name: 'instagram_link') String? instagramLink,
    @JsonKey(name: 'kajian_count') String? kajianCount,
    @JsonKey(name: 'subscribers_count') String? subscribersCount,
  }) = _DataStudyLocationModel;

  const DataStudyLocationModel._();

  factory DataStudyLocationModel.fromJson(Map<String, dynamic> json) =>
      _$DataStudyLocationModelFromJson(json);

  StudyLocationEntity toEntity() {
    return StudyLocationEntity(
      id: id,
      name: name,
      village: village,
      address: address,
      provinceId: provinceId,
      cityId: cityId,
      googleMaps: googleMaps,
      longitude: longitude,
      latitude: latitude,
      contactPerson: contactPerson,
      picture: picture,
      pictureUrl: pictureUrl,
      province: province?.toEntity(),
      city: city?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
      distanceInKm: distanceInKm.toString(),
      youtubeChannelLink: youtubeChannelLink,
      instagramLink: instagramLink,
      kajianCount: kajianCount,
      subscribersCount: subscribersCount,
    );
  }

  factory DataStudyLocationModel.fromEntity(StudyLocationEntity entity) {
    return DataStudyLocationModel(
      id: entity.id,
      name: entity.name,
      village: entity.village,
      address: entity.address,
      provinceId: entity.provinceId,
      cityId: entity.cityId,
      googleMaps: entity.googleMaps,
      longitude: entity.longitude,
      latitude: entity.latitude,
      contactPerson: entity.contactPerson,
      picture: entity.picture,
      pictureUrl: entity.pictureUrl,
      province: (entity.province != null)
          ? ProvinceModel.fromEntity(entity.province!)
          : null,
      city: (entity.city != null) ? CityModel.fromEntity(entity.city!) : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      description: entity.description,
      distanceInKm: entity.distanceInKm != null
          ? double.tryParse(entity.distanceInKm!)
          : null,
      youtubeChannelLink: entity.youtubeChannelLink,
      instagramLink: entity.instagramLink,
      kajianCount: entity.kajianCount,
      subscribersCount: entity.subscribersCount,
    );
  }
}
