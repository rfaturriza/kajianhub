import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/kajian/data/models/study_locations_response_model.codegen.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_config.dart';
import '../../models/study_location_query_model.codegen.dart';

abstract class StudyLocationRemoteDataSource {
  Future<Either<ServerException, StudyLocationResponseModel>>
      getStudyLocations({
    required StudyLocationQueryModel queries,
  });
}

@LazySingleton(as: StudyLocationRemoteDataSource)
class StudyLocationRemoteDataSourceImpl
    implements StudyLocationRemoteDataSource {
  final Dio _dio;
  StudyLocationRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(
          NetworkConfig.baseUrlKajianHub,
        );

  @override
  Future<Either<ServerException, StudyLocationResponseModel>>
      getStudyLocations({
    required StudyLocationQueryModel queries,
  }) async {
    const endpoint = 'kajian/study-locations';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queries.toJson(),
      );

      final data = response.data;
      return right(StudyLocationResponseModel.fromJson(data));
    } catch (e) {
      throw ServerException(e as Exception);
    }
  }
}
