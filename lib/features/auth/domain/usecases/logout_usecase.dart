import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/usecases/usecase.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';
import 'package:quranku/features/auth/domain/repositories/auth_repository.dart';

@injectable
class LogoutUseCase implements UseCase<LogoutResponse, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, LogoutResponse>> call(NoParams params) async {
    return await repository.logout();
  }
}
