import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/quran/data/models/carousel_events_response_model.codegen.dart';
import '../../../../core/error/failures.dart';
import '../dataSources/remote/carousel_remote_data_source.dart';
import '../../domain/entities/carousel_event.codegen.dart';
import '../../domain/repositories/carousel_repository.dart';

@LazySingleton(as: CarouselRepository)
class CarouselRepositoryImpl implements CarouselRepository {
  final CarouselRemoteDataSource _remoteDataSource;

  CarouselRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<CarouselEvent>>> getCarouselEvents() async {
    try {
      final response = await _remoteDataSource.getCarouselEvents();
      final events =
          response.data?.map((model) => model.toEntity()).toList() ?? [];
      return Right(events);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
