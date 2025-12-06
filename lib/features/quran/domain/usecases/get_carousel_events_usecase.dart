import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/carousel_event.codegen.dart';
import '../repositories/carousel_repository.dart';

@injectable
class GetCarouselEventsUseCase {
  final CarouselRepository _repository;

  GetCarouselEventsUseCase(this._repository);

  Future<Either<Failure, List<CarouselEvent>>> call() async {
    return await _repository.getCarouselEvents();
  }
}
