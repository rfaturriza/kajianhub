import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer.codegen.freezed.dart';

@freezed
abstract class Prayer with _$Prayer {
  const factory Prayer({
    required int id,
    required String title,
    required String description,
    required String text,
    required String arabicText,
    String? audioFile,
    int? categoryId,
    @Default(false) bool isPublicApi,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Prayer;
}
