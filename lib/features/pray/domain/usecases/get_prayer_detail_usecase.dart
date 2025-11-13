import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/failures.dart';
import 'package:quranku/core/usecases/usecase.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';
import 'package:quranku/features/pray/domain/repositories/pray_repository.dart';

@injectable
class GetPrayerDetailUsecase extends UseCase<Prayer, GetPrayerDetailParams> {
  final PrayRepository repository;

  GetPrayerDetailUsecase(this.repository);

  @override
  Future<Either<Failure, Prayer>> call(GetPrayerDetailParams params) async {
    return await repository.getPrayerDetail(params.id);
  }
}

class GetPrayerDetailParams extends Equatable {
  final int id;

  const GetPrayerDetailParams({required this.id});

  @override
  List<Object> get props => [id];
}
