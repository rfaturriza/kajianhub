import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/surah.codegen.dart';
import '../repositories/quran_repository.dart';

@injectable
class GetListSurahUseCase implements UseCase<List<Surah>?, NoParams> {
  final QuranRepository repository;

  GetListSurahUseCase(this.repository);

  @override
  Future<Either<Failure, List<Surah>?>> call(NoParams params) async {
    // Always try cache first
    final resultCache = await repository.getCacheAllSurah();

    if (resultCache.isRight() && resultCache.asRight()?.isNotEmpty == true) {
      // If cache has data, return it immediately and optionally update in background
      _updateCacheInBackground();
      return resultCache;
    }

    // If no cache, try API
    final resultApi = await repository.getListOfSurah();

    if (resultApi.isRight() && resultApi.asRight() != null) {
      await repository.setCacheAllSurah(resultApi.asRight()!);
      return resultApi;
    }

    // If API fails but cache has some data (even if empty list was cached), return cache
    if (resultCache.isRight()) {
      return resultCache;
    }

    // Return API error if both cache and API failed
    return resultApi;
  }

  void _updateCacheInBackground() async {
    try {
      final resultApi = await repository.getListOfSurah();
      if (resultApi.isRight() && resultApi.asRight() != null) {
        await repository.setCacheAllSurah(resultApi.asRight()!);
      }
    } catch (e) {
      // Silently fail background update
    }
  }
}
