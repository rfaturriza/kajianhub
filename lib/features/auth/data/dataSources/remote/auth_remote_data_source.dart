import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/network/dio_config.dart';
import 'package:quranku/features/auth/data/models/auth_dto.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  });

  Future<LogoutResponseDto> logout(String token);

  Future<UserResponseDto> getMe(String token);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(NetworkConfig.baseUrlKajianHub);

  @override
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final formData = FormData.fromMap({
        'email': email,
        'password': password,
      });

      final response = await _dio.post(
        'mobile/auth/login',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      return LoginResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LogoutResponseDto> logout(String token) async {
    try {
      final response = await _dio.post(
        'mobile/auth/logout',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return LogoutResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserResponseDto> getMe(String token) async {
    try {
      final response = await _dio.get(
        'mobile/auth/me',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return UserResponseDto.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
