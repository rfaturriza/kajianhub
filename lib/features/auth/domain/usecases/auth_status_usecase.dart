import 'package:injectable/injectable.dart';
import 'package:quranku/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetStoredTokenUseCase {
  final AuthRepository repository;

  GetStoredTokenUseCase(this.repository);

  Future<String?> call() async {
    return await repository.getStoredToken();
  }
}

@injectable
class IsLoggedInUseCase {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isLoggedIn();
  }
}
