import 'package:dartz/dartz.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, LogoutResponse>> logout();

  Future<Either<Failure, UserResponse>> getMe();

  Future<String?> getStoredToken();

  Future<void> saveToken(String token);

  Future<void> deleteToken();

  Future<bool> isLoggedIn();
}
