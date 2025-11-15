import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/buletin/domain/entities/user.codegen.dart';

part 'user_model.codegen.freezed.dart';
part 'user_model.codegen.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    int? id,
    String? name,
    String? email,
    @JsonKey(name: 'isSuperAdmin') bool? isSuperAdmin,
    @JsonKey(name: 'isOrganiser') bool? isOrganiser,
    @JsonKey(name: 'isAdmin') bool? isAdmin,
    @JsonKey(name: 'isAdminMasjid') bool? isAdminMasjid,
    @JsonKey(name: 'isUstadz') bool? isUstadz,
    @JsonKey(name: 'isUser') bool? isUser,
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'date_of_birth') String? dateOfBirth,
    @JsonKey(name: 'contact_person') String? contactPerson,
    String? description,
    String? picture,
    @JsonKey(name: 'picture_url') String? pictureUrl,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'deleted_at') String? deletedAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  User toEntity() {
    return User(
      id: id ?? 0,
      name: name ?? '',
      email: email ?? '',
      isSuperAdmin: isSuperAdmin ?? false,
      isOrganiser: isOrganiser ?? false,
      isAdmin: isAdmin ?? false,
      isAdminMasjid: isAdminMasjid ?? false,
      isUstadz: isUstadz ?? false,
      isUser: isUser ?? false,
      placeOfBirth: placeOfBirth,
      dateOfBirth: dateOfBirth != null ? DateTime.tryParse(dateOfBirth!) : null,
      contactPerson: contactPerson,
      description: description,
      picture: picture,
      pictureUrl: pictureUrl,
      createdAt: DateTime.tryParse(createdAt ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAt ?? '') ?? DateTime.now(),
      deletedAt: deletedAt != null ? DateTime.tryParse(deletedAt!) : null,
    );
  }
}
