import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/extension/string_ext.dart';
import '../../domain/entities/kajian_schedule.codegen.dart';

part 'kajian_schedules_response_model.codegen.freezed.dart';
part 'kajian_schedules_response_model.codegen.g.dart';

@freezed
abstract class KajianSchedulesResponseModel
    with _$KajianSchedulesResponseModel {
  const factory KajianSchedulesResponseModel({
    List<DataKajianScheduleModel>? data,
    LinksKajianScheduleModel? links,
    MetaKajianScheduleModel? meta,
  }) = _KajianSchedulesResponseModel;

  const KajianSchedulesResponseModel._();

  factory KajianSchedulesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$KajianSchedulesResponseModelFromJson(json);

  factory KajianSchedulesResponseModel.fromEntity(KajianSchedules entity) {
    return KajianSchedulesResponseModel(
      data: entity.data
          .map((e) => DataKajianScheduleModel.fromEntity(e))
          .toList(),
      links: LinksKajianScheduleModel.fromEntity(entity.links),
      meta: MetaKajianScheduleModel.fromEntity(entity.meta),
    );
  }

  KajianSchedules toEntity() {
    return KajianSchedules(
      data: data?.map((e) => e.toEntity()).toList() ?? [],
      links: links?.toEntity() ?? LinksKajianScheduleModel.empty().toEntity(),
      meta: meta?.toEntity() ?? MetaKajianScheduleModel.empty().toEntity(),
    );
  }
}

@freezed
abstract class DataKajianScheduleModel with _$DataKajianScheduleModel {
  const factory DataKajianScheduleModel({
    int? id,
    String? title,
    String? type,
    @JsonKey(name: 'type_label') String? typeLabel,
    String? book,
    @JsonKey(name: 'time_start') String? timeStart,
    @JsonKey(name: 'time_end') String? timeEnd,
    @JsonKey(name: 'jadwal_shalat') String? prayerSchedule,
    @JsonKey(name: 'location_id') String? locationId,
    StudyLocationModel? studyLocation,
    List<UstadzModel>? ustadz,
    List<KajianThemeModel>? themes,
    List<DailyScheduleModel>? dailySchedules,
    List<HistoryKajianModel>? histories,
    List<dynamic>? customSchedules,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'deleted_by') String? deletedBy,
  }) = _DataKajianScheduleModel;

  const DataKajianScheduleModel._();

  factory DataKajianScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DataKajianScheduleModelFromJson(json);

  factory DataKajianScheduleModel.fromEntity(DataKajianSchedule entity) {
    return DataKajianScheduleModel(
      id: entity.id,
      title: entity.title,
      type: entity.type,
      typeLabel: entity.typeLabel,
      book: entity.book,
      timeStart: entity.timeStart,
      timeEnd: entity.timeEnd,
      prayerSchedule: entity.prayerSchedule,
      locationId: entity.locationId,
      studyLocation: StudyLocationModel.fromEntity(entity.studyLocation),
      ustadz: entity.ustadz.map((e) => UstadzModel.fromEntity(e)).toList(),
      themes: entity.themes.map((e) => KajianThemeModel.fromEntity(e)).toList(),
      dailySchedules: entity.dailySchedules
          .map((e) => DailyScheduleModel.fromEntity(e))
          .toList(),
      histories: entity.histories
          .map((e) => HistoryKajianModel.fromEntity(e))
          .toList(),
      customSchedules: entity.customSchedules,
    );
  }

  DataKajianSchedule toEntity() {
    return DataKajianSchedule(
      id: id ?? 0,
      title: title ?? emptyString,
      type: type ?? emptyString,
      typeLabel: typeLabel ?? emptyString,
      book: book ?? emptyString,
      timeStart: () {
        if (timeStart == null) {
          return emptyString;
        }
        return timeStart!.substring(0, 5);
      }(),
      timeEnd: () {
        if (timeEnd == null) {
          return emptyString;
        }
        return timeEnd!.substring(0, 5);
      }(),
      prayerSchedule: prayerSchedule?.capitalize() ?? emptyString,
      locationId: locationId ?? emptyString,
      studyLocation:
          studyLocation?.toEntity() ?? StudyLocationModel.empty().toEntity(),
      ustadz: ustadz?.map((e) => e.toEntity()).toList() ?? [],
      themes: themes?.map((e) => e.toEntity()).toList() ?? [],
      dailySchedules: dailySchedules?.map((e) => e.toEntity()).toList() ?? [],
      histories: histories?.map((e) => e.toEntity()).toList() ?? [],
      customSchedules: customSchedules ?? [],
    );
  }
}

@freezed
abstract class HistoryKajianModel with _$HistoryKajianModel {
  const factory HistoryKajianModel({
    int? id,
    @JsonKey(name: 'kajian_id') String? kajianId,
    String? url,
    String? title,
    @JsonKey(name: 'published_at') String? publishedAt,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _HistoryKajianModel;

  const HistoryKajianModel._();

  factory HistoryKajianModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryKajianModelFromJson(json);

  factory HistoryKajianModel.empty() => const HistoryKajianModel(
        id: 0,
        kajianId: emptyString,
        url: emptyString,
        title: emptyString,
        publishedAt: emptyString,
        createdAt: emptyString,
        updatedAt: emptyString,
      );

  factory HistoryKajianModel.fromEntity(HistoryKajian entity) {
    return HistoryKajianModel(
      id: entity.id,
      kajianId: entity.kajianId,
      url: entity.url,
      title: entity.title,
      publishedAt: entity.publishedAt,
    );
  }

  HistoryKajian toEntity() {
    return HistoryKajian(
      id: id ?? 0,
      kajianId: kajianId ?? emptyString,
      url: url ?? emptyString,
      title: title ?? emptyString,
      publishedAt: publishedAt ?? emptyString,
    );
  }
}

@freezed
abstract class StudyLocationModel with _$StudyLocationModel {
  const factory StudyLocationModel({
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
  }) = _StudyLocationModel;

  const StudyLocationModel._();

  factory StudyLocationModel.fromJson(Map<String, dynamic> json) =>
      _$StudyLocationModelFromJson(json);

  factory StudyLocationModel.empty() => const StudyLocationModel(
        id: 0,
        name: emptyString,
        village: emptyString,
        address: emptyString,
        provinceId: emptyString,
        cityId: emptyString,
        googleMaps: emptyString,
        longitude: emptyString,
        latitude: emptyString,
        contactPerson: emptyString,
        picture: emptyString,
        pictureUrl: emptyString,
        province: ProvinceModel(id: 0, name: emptyString),
        city: CityModel(id: 0, name: emptyString, provinceId: emptyString),
      );

  factory StudyLocationModel.fromEntity(StudyLocation entity) {
    return StudyLocationModel(
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
      province: ProvinceModel.fromEntity(entity.province),
      city: CityModel.fromEntity(entity.city),
    );
  }

  StudyLocation toEntity() {
    return StudyLocation(
      id: id ?? 0,
      name: name ?? emptyString,
      village: village ?? emptyString,
      address: address ?? emptyString,
      provinceId: provinceId ?? emptyString,
      cityId: cityId ?? emptyString,
      googleMaps: googleMaps ?? emptyString,
      longitude: longitude ?? emptyString,
      latitude: latitude ?? emptyString,
      contactPerson: contactPerson ?? emptyString,
      picture: picture ?? emptyString,
      pictureUrl: pictureUrl ?? emptyString,
      province: province?.toEntity() ?? ProvinceModel.empty().toEntity(),
      city: city?.toEntity() ?? CityModel.empty().toEntity(),
    );
  }
}

@freezed
abstract class ProvinceModel with _$ProvinceModel {
  const factory ProvinceModel({
    int? id,
    String? name,
  }) = _ProvinceModel;

  const ProvinceModel._();

  factory ProvinceModel.fromJson(Map<String, dynamic> json) =>
      _$ProvinceModelFromJson(json);

  factory ProvinceModel.empty() => const ProvinceModel(
        id: 0,
        name: emptyString,
      );

  factory ProvinceModel.fromEntity(Province entity) {
    return ProvinceModel(
      id: entity.id,
      name: entity.name,
    );
  }

  Province toEntity() {
    return Province(
      id: id ?? 0,
      name: name ?? emptyString,
    );
  }
}

@freezed
abstract class CityModel with _$CityModel {
  const factory CityModel({
    int? id,
    String? name,
    @JsonKey(name: 'province_id') String? provinceId,
  }) = _CityModel;

  const CityModel._();

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);

  factory CityModel.empty() => const CityModel(
        id: 0,
        name: emptyString,
        provinceId: emptyString,
      );

  factory CityModel.fromEntity(City entity) {
    return CityModel(
      id: entity.id,
      name: entity.name,
      provinceId: entity.provinceId,
    );
  }

  City toEntity() {
    return City(
      id: id ?? 0,
      name: name ?? emptyString,
      provinceId: provinceId ?? emptyString,
    );
  }
}

@freezed
abstract class UstadzModel with _$UstadzModel {
  const factory UstadzModel({
    int? id,
    @JsonKey(name: 'ustadz_id') String? ustadzId,
    String? name,
    String? email,
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'contact_person') String? contactPerson,
  }) = _UstadzModel;

  const UstadzModel._();

  factory UstadzModel.fromJson(Map<String, dynamic> json) =>
      _$UstadzModelFromJson(json);

  factory UstadzModel.empty() => const UstadzModel(
        id: 0,
        ustadzId: emptyString,
        name: emptyString,
        email: emptyString,
        placeOfBirth: emptyString,
        dateOfBirth: emptyString,
        contactPerson: emptyString,
      );

  factory UstadzModel.fromEntity(Ustadz entity) {
    return UstadzModel(
      id: entity.id,
      ustadzId: entity.ustadzId,
      name: entity.name,
      email: entity.email,
      placeOfBirth: entity.placeOfBirth,
      dateOfBirth: entity.dateOfBirth,
      contactPerson: entity.contactPerson,
    );
  }

  Ustadz toEntity() {
    return Ustadz(
      id: id ?? 0,
      ustadzId: ustadzId ?? emptyString,
      name: name ?? emptyString,
      email: email ?? emptyString,
      placeOfBirth: placeOfBirth ?? emptyString,
      dateOfBirth: dateOfBirth ?? emptyString,
      contactPerson: contactPerson ?? emptyString,
    );
  }
}

@freezed
abstract class KajianThemeModel with _$KajianThemeModel {
  const factory KajianThemeModel({
    int? id,
    @JsonKey(name: 'theme_id') String? themeId,
    String? theme,
  }) = _KajianThemeModel;

  const KajianThemeModel._();

  factory KajianThemeModel.fromJson(Map<String, dynamic> json) =>
      _$KajianThemeModelFromJson(json);

  factory KajianThemeModel.empty() => const KajianThemeModel(
        id: 0,
        themeId: emptyString,
        theme: emptyString,
      );

  factory KajianThemeModel.fromEntity(KajianTheme entity) {
    return KajianThemeModel(
      id: entity.id,
      themeId: entity.themeId,
      theme: entity.theme,
    );
  }

  KajianTheme toEntity() {
    return KajianTheme(
      id: id ?? 0,
      themeId: themeId ?? emptyString,
      theme: theme ?? emptyString,
    );
  }
}

@freezed
abstract class DailyScheduleModel with _$DailyScheduleModel {
  const factory DailyScheduleModel({
    int? id,
    @JsonKey(name: 'day_id') String? dayId,
    @JsonKey(name: 'day_label') String? dayLabel,
  }) = _DailyScheduleModel;

  const DailyScheduleModel._();

  factory DailyScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DailyScheduleModelFromJson(json);

  factory DailyScheduleModel.empty() => const DailyScheduleModel(
        id: 0,
        dayId: emptyString,
        dayLabel: emptyString,
      );

  factory DailyScheduleModel.fromEntity(DailySchedule entity) {
    return DailyScheduleModel(
      id: entity.id,
      dayId: entity.dayId,
      dayLabel: entity.dayLabel,
    );
  }

  DailySchedule toEntity() {
    return DailySchedule(
      id: id ?? 0,
      dayId: dayId ?? emptyString,
      dayLabel: dayLabel ?? emptyString,
    );
  }
}

@freezed
abstract class LinksKajianScheduleModel with _$LinksKajianScheduleModel {
  const factory LinksKajianScheduleModel({
    String? first,
    String? last,
    String? prev,
    String? next,
  }) = _LinksKajianScheduleModel;

  const LinksKajianScheduleModel._();

  factory LinksKajianScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$LinksKajianScheduleModelFromJson(json);

  factory LinksKajianScheduleModel.empty() => const LinksKajianScheduleModel(
        first: emptyString,
        last: emptyString,
        prev: emptyString,
        next: emptyString,
      );

  factory LinksKajianScheduleModel.fromEntity(LinksKajianSchedule entity) {
    return LinksKajianScheduleModel(
      first: entity.first,
      last: entity.last,
      prev: entity.prev,
      next: entity.next,
    );
  }

  LinksKajianSchedule toEntity() {
    return LinksKajianSchedule(
      first: first ?? emptyString,
      last: last ?? emptyString,
      prev: prev ?? emptyString,
      next: next ?? emptyString,
    );
  }
}

@freezed
abstract class MetaKajianScheduleModel with _$MetaKajianScheduleModel {
  const factory MetaKajianScheduleModel({
    @JsonKey(name: 'current_page') int? currentPage,
    int? from,
    @JsonKey(name: 'last_page') int? lastPage,
    List<LinksMetaModel>? links,
    String? path,
    @JsonKey(name: 'per_page') int? perPage,
    int? to,
    int? total,
  }) = _MetaKajianScheduleModel;

  const MetaKajianScheduleModel._();

  factory MetaKajianScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$MetaKajianScheduleModelFromJson(json);

  factory MetaKajianScheduleModel.empty() => const MetaKajianScheduleModel(
        currentPage: 0,
        from: 0,
        lastPage: 0,
        links: [],
        path: emptyString,
        perPage: 0,
        to: 0,
        total: 0,
      );

  factory MetaKajianScheduleModel.fromEntity(MetaKajianSchedule entity) {
    return MetaKajianScheduleModel(
      currentPage: entity.currentPage,
      from: entity.from,
      lastPage: entity.lastPage,
      links: entity.links?.map((e) => LinksMetaModel.fromEntity(e)).toList(),
      path: entity.path,
      perPage: entity.perPage,
      to: entity.to,
      total: entity.total,
    );
  }

  MetaKajianSchedule toEntity() {
    return MetaKajianSchedule(
      currentPage: currentPage ?? 0,
      from: from ?? 0,
      lastPage: lastPage ?? 0,
      links: links?.map((e) => e.toEntity()).toList() ?? [],
      path: path ?? emptyString,
      perPage: perPage ?? 0,
      to: to ?? 0,
      total: total ?? 0,
    );
  }
}

@freezed
abstract class LinksMetaModel with _$LinksMetaModel {
  const factory LinksMetaModel({
    String? url,
    String? label,
    bool? active,
  }) = _LinksMetaModel;

  const LinksMetaModel._();

  factory LinksMetaModel.fromJson(Map<String, dynamic> json) =>
      _$LinksMetaModelFromJson(json);

  factory LinksMetaModel.empty() => const LinksMetaModel(
        url: emptyString,
        label: emptyString,
        active: false,
      );

  factory LinksMetaModel.fromEntity(LinksMeta entity) {
    return LinksMetaModel(
      url: entity.url,
      label: entity.label,
      active: entity.active,
    );
  }

  LinksMeta toEntity() {
    return LinksMeta(
      url: url ?? emptyString,
      label: label ?? emptyString,
      active: active ?? false,
    );
  }
}
