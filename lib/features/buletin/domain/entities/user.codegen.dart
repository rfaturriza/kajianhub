import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.codegen.freezed.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
    required bool isSuperAdmin,
    required bool isOrganiser,
    required bool isAdmin,
    required bool isAdminMasjid,
    required bool isUstadz,
    required bool isUser,
    String? placeOfBirth,
    DateTime? dateOfBirth,
    String? contactPerson,
    String? description,
    String? picture,
    String? pictureUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _User;
}
