import 'package:json_annotation/json_annotation.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
class LoginResponseDto {
  final bool? success;
  final String? message;
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @JsonKey(name: 'token_type')
  final String? tokenType;

  LoginResponseDto({
    this.success,
    this.message,
    this.accessToken,
    this.tokenType,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseDtoToJson(this);

  LoginResponse toEntity() {
    return LoginResponse(
      success: success ?? false,
      message: message ?? '',
      accessToken: accessToken ?? '',
      tokenType: tokenType ?? '',
    );
  }
}

@JsonSerializable()
class UserResponseDto {
  final AuthUserDto? data;

  UserResponseDto({
    this.data,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseDtoToJson(this);

  UserResponse toEntity() {
    return UserResponse(
      data: data?.toEntity() ?? AuthUser.empty(),
    );
  }
}

@JsonSerializable()
class AuthUserDto {
  final int? id;
  final String? name;
  final String? email;
  final bool? isSuperAdmin;
  final bool? isAdmin;
  final bool? isAdminMasjid;
  final bool? isUstadz;
  final bool? isUser;
  final List<UserRoleDto>? roles;
  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'contact_person')
  final String? contactPerson;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  @JsonKey(name: 'province_id')
  final String? provinceId;
  final String? description;
  @JsonKey(name: 'tiktok_link')
  final String? tiktokLink;
  @JsonKey(name: 'youtube_link')
  final String? youtubeLink;
  @JsonKey(name: 'facebook_link')
  final String? facebookLink;
  @JsonKey(name: 'instagram_link')
  final String? instagramLink;
  final ProvinceDto? province;
  @JsonKey(name: 'city_id')
  final String? cityId;
  final CityDto? city;
  final String? picture;
  @JsonKey(name: 'picture_url')
  final String? pictureUrl;
  @JsonKey(name: 'subscribers_count')
  final int? subscribersCount;
  @JsonKey(name: 'kajian_count')
  final int? kajianCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'updated_by')
  final String? updatedBy;
  @JsonKey(name: 'deleted_by')
  final String? deletedBy;

  AuthUserDto({
    this.id,
    this.name,
    this.email,
    this.isSuperAdmin,
    this.isAdmin,
    this.isAdminMasjid,
    this.isUstadz,
    this.isUser,
    this.roles,
    this.placeOfBirth,
    this.dateOfBirth,
    this.contactPerson,
    this.emailVerifiedAt,
    this.provinceId,
    this.description,
    this.tiktokLink,
    this.youtubeLink,
    this.facebookLink,
    this.instagramLink,
    this.province,
    this.cityId,
    this.city,
    this.picture,
    this.pictureUrl,
    this.subscribersCount,
    this.kajianCount,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthUserDtoToJson(this);

  AuthUser toEntity() {
    return AuthUser(
      id: id ?? 0,
      name: name ?? '',
      email: email ?? '',
      isSuperAdmin: isSuperAdmin ?? false,
      isAdmin: isAdmin ?? false,
      isAdminMasjid: isAdminMasjid ?? false,
      isUstadz: isUstadz ?? false,
      isUser: isUser ?? false,
      roles: roles?.map((role) => role.toEntity()).toList() ?? [],
      placeOfBirth: placeOfBirth,
      dateOfBirth: dateOfBirth,
      contactPerson: contactPerson,
      emailVerifiedAt: emailVerifiedAt,
      provinceId: provinceId,
      description: description,
      tiktokLink: tiktokLink,
      youtubeLink: youtubeLink,
      facebookLink: facebookLink,
      instagramLink: instagramLink,
      province: province?.toEntity(),
      cityId: cityId,
      city: city?.toEntity(),
      picture: picture,
      pictureUrl: pictureUrl,
      subscribersCount: subscribersCount,
      kajianCount: kajianCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
      deletedBy: deletedBy,
    );
  }
}

@JsonSerializable()
class UserRoleDto {
  @JsonKey(name: 'role_id')
  final int? roleId;
  final String? name;

  UserRoleDto({
    this.roleId,
    this.name,
  });

  factory UserRoleDto.fromJson(Map<String, dynamic> json) =>
      _$UserRoleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoleDtoToJson(this);

  UserRole toEntity() {
    return UserRole(
      roleId: roleId ?? 0,
      name: name ?? '',
    );
  }
}

@JsonSerializable()
class ProvinceDto {
  final int? id;
  final String? name;

  ProvinceDto({
    this.id,
    this.name,
  });

  factory ProvinceDto.fromJson(Map<String, dynamic> json) =>
      _$ProvinceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProvinceDtoToJson(this);

  Province toEntity() {
    return Province(
      id: id ?? 0,
      name: name ?? '',
    );
  }
}

@JsonSerializable()
class CityDto {
  final int? id;
  final String? name;
  @JsonKey(name: 'province_id')
  final String? provinceId;

  CityDto({
    this.id,
    this.name,
    this.provinceId,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) =>
      _$CityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CityDtoToJson(this);

  City toEntity() {
    return City(
      id: id ?? 0,
      name: name ?? '',
      provinceId: provinceId ?? '',
    );
  }
}

@JsonSerializable()
class LogoutResponseDto {
  final bool? success;
  final String? message;

  LogoutResponseDto({
    this.success,
    this.message,
  });

  factory LogoutResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutResponseDtoToJson(this);

  LogoutResponse toEntity() {
    return LogoutResponse(
      success: success ?? false,
      message: message ?? '',
    );
  }
}
