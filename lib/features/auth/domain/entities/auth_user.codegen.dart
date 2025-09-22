import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.codegen.freezed.dart';

@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required int id,
    required String name,
    required String email,
    required bool isSuperAdmin,
    required bool isAdmin,
    required bool isAdminMasjid,
    required bool isUstadz,
    required bool isUser,
    required List<UserRole> roles,
    String? placeOfBirth,
    String? dateOfBirth,
    String? contactPerson,
    String? emailVerifiedAt,
    String? provinceId,
    String? description,
    String? tiktokLink,
    String? youtubeLink,
    String? facebookLink,
    String? instagramLink,
    Province? province,
    String? cityId,
    City? city,
    String? picture,
    String? pictureUrl,
    int? subscribersCount,
    int? kajianCount,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    String? createdBy,
    String? updatedBy,
    String? deletedBy,
  }) = _AuthUser;

  const AuthUser._();

  static AuthUser empty() {
    return const AuthUser(
      id: 0,
      name: '',
      email: '',
      isSuperAdmin: false,
      isAdmin: false,
      isAdminMasjid: false,
      isUstadz: false,
      isUser: false,
      roles: [],
    );
  }
}

@freezed
abstract class UserRole with _$UserRole {
  const factory UserRole({
    required int roleId,
    required String name,
  }) = _UserRole;
}

@freezed
abstract class Province with _$Province {
  const factory Province({
    required int id,
    required String name,
  }) = _Province;
}

@freezed
abstract class City with _$City {
  const factory City({
    required int id,
    required String name,
    required String provinceId,
  }) = _City;
}

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required bool success,
    required String message,
    required String accessToken,
    required String tokenType,
  }) = _LoginResponse;
}

@freezed
abstract class UserResponse with _$UserResponse {
  const factory UserResponse({
    required AuthUser data,
  }) = _UserResponse;
}

@freezed
abstract class LogoutResponse with _$LogoutResponse {
  const factory LogoutResponse({
    required bool success,
    required String message,
  }) = _LogoutResponse;
}
