import 'package:equatable/equatable.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';

class StudyLocationsEntity extends Equatable {
  final List<StudyLocationEntity>? data;
  final LinksKajianSchedule? links;
  final MetaKajianSchedule? meta;

  const StudyLocationsEntity({
    this.data,
    this.links,
    this.meta,
  });

  @override
  List<Object?> get props => [data, links, meta];
}

class StudyLocationEntity extends Equatable {
  final int? id;
  final String? name;
  final String? village;
  final String? address;
  final String? provinceId;
  final String? cityId;
  final String? googleMaps;
  final String? longitude;
  final String? latitude;
  final String? contactPerson;
  final String? picture;
  final String? pictureUrl;
  final Province? province;
  final City? city;
  final String? createdAt;
  final String? updatedAt;
  final String? description;
  final String? distanceInKm;
  final String? youtubeChannelLink;
  final String? instagramLink;
  final String? kajianCount;
  final String? subscribersCount;

  const StudyLocationEntity({
    this.id,
    this.name,
    this.village,
    this.address,
    this.provinceId,
    this.cityId,
    this.googleMaps,
    this.longitude,
    this.latitude,
    this.contactPerson,
    this.picture,
    this.pictureUrl,
    this.province,
    this.city,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.distanceInKm,
    this.youtubeChannelLink,
    this.instagramLink,
    this.kajianCount,
    this.subscribersCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        village,
        address,
        provinceId,
        cityId,
        googleMaps,
        longitude,
        latitude,
        contactPerson,
        picture,
        pictureUrl,
        createdAt,
        updatedAt,
        province,
        city,
        description,
        distanceInKm,
        youtubeChannelLink,
        instagramLink,
        kajianCount,
        subscribersCount,
      ];
}
