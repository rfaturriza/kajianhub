import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/usecases/usecase.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';
import 'package:quranku/features/auth/domain/repositories/auth_repository.dart';

@injectable
class LoginUseCase implements UseCase<LoginResponse, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponse>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}
