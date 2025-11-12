import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/usecases/usecase.dart';
import 'package:quranku/features/auth/domain/entities/auth_user.codegen.dart';
import 'package:quranku/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetMeUseCase implements UseCase<UserResponse, NoParams> {
  final AuthRepository repository;

  GetMeUseCase(this.repository);

  @override
  Future<Either<Failure, UserResponse>> call(NoParams params) async {
    return await repository.getMe();
  }
}
