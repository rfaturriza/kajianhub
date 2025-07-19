import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/kajian/data/models/ustadz_response_model.codegen.dart';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/network/dio_config.dart';
import '../../models/ustadz_query_model.codegen.dart';

abstract class UstadzRemoteDataSource {
  Future<Either<ServerException, UstadzResponseModel>> getUstadz({
    required UstadzQueryModel queries,
  });
}

@LazySingleton(as: UstadzRemoteDataSource)
class UstadzRemoteDataSourceImpl implements UstadzRemoteDataSource {
  final Dio _dio;
  UstadzRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(
          NetworkConfig.baseUrlKajianHub,
        );

  @override
  Future<Either<ServerException, UstadzResponseModel>> getUstadz({
    required UstadzQueryModel queries,
  }) async {
    const endpoint = 'kajian/ustadz';
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queries.toJson(),
      );

      final data = response.data;
      return right(UstadzResponseModel.fromJson(data));
    } catch (e) {
      return left(ServerException(e as Exception));
    }
  }
}
