import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/core/network/dio_config.dart';
import '../../domain/entities/carousel_event.codegen.dart';

part 'carousel_events_response_model.codegen.freezed.dart';
part 'carousel_events_response_model.codegen.g.dart';

@freezed
abstract class CarouselEventsResponseModel with _$CarouselEventsResponseModel {
  const factory CarouselEventsResponseModel({
    List<CarouselEventModel>? data,
  }) = _CarouselEventsResponseModel;

  factory CarouselEventsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CarouselEventsResponseModelFromJson(json);
}

@freezed
abstract class CarouselEventModel with _$CarouselEventModel {
  const factory CarouselEventModel({
    int? id,
    String? title,
    String? description,
    String? image,
    String? link,
    @JsonKey(name: 'event_date') String? eventDate,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _CarouselEventModel;

  factory CarouselEventModel.fromJson(Map<String, dynamic> json) =>
      _$CarouselEventModelFromJson(json);
}

extension CarouselEventModelX on CarouselEventModel {
  CarouselEvent toEntity() {
    return CarouselEvent(
      id: id,
      title: title,
      description: description,
      eventDate: () {
        if (eventDate == null) {
          return null;
        }
        return DateTime.parse(eventDate!);
      }(),
      link: link,
      imageUrl: () {
        if (imageUrl == null) {
          final url = '${NetworkConfig.baseImageUrl}carousel-events/$image';
          return url;
        }
        return imageUrl!;
      }(),
      createdAt: () {
        if (createdAt == null) {
          return null;
        }
        return DateTime.parse(createdAt!);
      }(),
      updatedAt: () {
        if (updatedAt == null) {
          return null;
        }
        return DateTime.parse(updatedAt!);
      }(),
    );
  }
}
