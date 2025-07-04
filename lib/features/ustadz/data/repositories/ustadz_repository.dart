import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/ustadz/data/dataSources/remote/ustadz_remote_data_source.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/ustadz_repository.dart';
import '../models/ustadz_query_model.codegen.dart';

@LazySingleton(as: UstadzRepository)
class UstadzRepositoryImpl implements UstadzRepository {
  final UstadzRemoteDataSource remoteDataSource;

  UstadzRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UstadzListEntity>> getUstadz({
    UstadzQueryModel queries = const UstadzQueryModel(),
  }) async {
    final result = await remoteDataSource.getUstadz(
      queries: queries,
    );
    return result.fold(
      (exception) => left(const ServerFailure()),
      (ustadzResponse) {
        final ustadzList = ustadzResponse.data?.map((ustadz) {
              return UstadzEntity(
                id: ustadz.id ?? 0,
                name: ustadz.name ?? '',
                email: ustadz.email ?? '',
                placeOfBirth: ustadz.placeOfBirth,
                dateOfBirth: ustadz.dateOfBirth,
                contactPerson: ustadz.contactPerson,
                pictureUrl: ustadz.pictureUrl,
                subscribersCount: ustadz.subscribersCount,
                kajianCount: ustadz.kajianCount,
              );
            }).toList() ??
            [];

        return right(UstadzListEntity(
          data: ustadzList,
        ));
      },
    );
  }
}
