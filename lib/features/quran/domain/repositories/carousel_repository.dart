import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/carousel_event.codegen.dart';

abstract class CarouselRepository {
  Future<Either<Failure, List<CarouselEvent>>> getCarouselEvents();
}
