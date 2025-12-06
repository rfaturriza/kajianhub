import 'package:freezed_annotation/freezed_annotation.dart';

part 'carousel_event.codegen.freezed.dart';

@freezed
abstract class CarouselEvent with _$CarouselEvent {
  const factory CarouselEvent({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? eventDate,
    String? link,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CarouselEvent;
}
