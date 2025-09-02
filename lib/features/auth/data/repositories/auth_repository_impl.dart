import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/exceptions.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/features/auth/data/dataSources/local/auth_local_data_source.dart';
import 'package:quranku/features/auth/data/dataSources/remote/auth_remote_data_source.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';
import 'package:quranku/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save token after successful login
      if (result.accessToken != null) {
        await localDataSource.saveToken(result.accessToken!);
      }

      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LogoutResponse>> logout() async {
    try {
      final token = await localDataSource.getStoredToken();
      if (token == null) {
        return const Left(GeneralFailure(message: 'No token found'));
      }

      final result = await remoteDataSource.logout(token);

      // Delete token after successful logout
      await localDataSource.deleteToken();

      return Right(result.toEntity());
    } on ServerException catch (e) {
      // Delete token even if logout fails on server
      await localDataSource.deleteToken();
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Delete token even if logout fails
      await localDataSource.deleteToken();
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserResponse>> getMe() async {
    try {
      final token = await localDataSource.getStoredToken();
      if (token == null) {
        return const Left(GeneralFailure(message: 'No token found'));
      }

      final result = await remoteDataSource.getMe(token);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<String?> getStoredToken() async {
    return await localDataSource.getStoredToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await localDataSource.saveToken(token);
  }

  @override
  Future<void> deleteToken() async {
    await localDataSource.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }
}
