import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';

part 'prayer_model.codegen.freezed.dart';
part 'prayer_model.codegen.g.dart';

@freezed
abstract class PrayerModel with _$PrayerModel {
  const factory PrayerModel({
    required int id,
    required String title,
    required String description,
    required String text,
    @JsonKey(name: 'arabic_text') required String arabicText,
    @JsonKey(name: 'audio_file') String? audioFile,
    @JsonKey(name: 'category_id') int? categoryId,
    @JsonKey(name: 'is_public_api') @Default(false) bool isPublicApi,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _PrayerModel;

  factory PrayerModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerModelFromJson(json);

  const PrayerModel._();

  Prayer toEntity() {
    return Prayer(
      id: id,
      title: title,
      description: description,
      text: text,
      arabicText: arabicText,
      audioFile: audioFile,
      categoryId: categoryId,
      isPublicApi: isPublicApi,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
