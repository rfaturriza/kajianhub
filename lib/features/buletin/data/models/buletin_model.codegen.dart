import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/features/buletin/data/models/user_model.codegen.dart';

part 'buletin_model.codegen.freezed.dart';
part 'buletin_model.codegen.g.dart';

@freezed
abstract class BuletinModel with _$BuletinModel {
  const factory BuletinModel({
    int? id,
    String? title,
    String? content,
    String? picture,
    @JsonKey(name: 'picture_url') String? pictureUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
    @JsonKey(name: 'created_by') String? createdBy,
    @JsonKey(name: 'updated_by') String? updatedBy,
    @JsonKey(name: 'deleted_by') String? deletedBy,
    @JsonKey(name: 'createdBy') UserModel? createdByUser,
  }) = _BuletinModel;

  const BuletinModel._();

  factory BuletinModel.fromJson(Map<String, dynamic> json) =>
      _$BuletinModelFromJson(json);

  Buletin toEntity() {
    return Buletin(
      id: id ?? 0,
      title: title ?? '',
      content: content ?? '',
      picture: picture,
      pictureUrl: pictureUrl,
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt ?? '') ?? DateTime.now(),
      deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
      createdBy: createdBy ?? '',
      updatedBy: updatedBy,
      deletedBy: deletedBy,
      createdByUser: createdByUser?.toEntity(),
    );
  }
}
