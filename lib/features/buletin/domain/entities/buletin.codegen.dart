import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/buletin/domain/entities/user.codegen.dart';

part 'buletin.codegen.freezed.dart';

@freezed
abstract class Buletin with _$Buletin {
  const factory Buletin({
    required int id,
    required String title,
    required String content,
    String? picture,
    String? pictureUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    required String createdBy,
    String? updatedBy,
    String? deletedBy,
    User? createdByUser,
  }) = _Buletin;
}
