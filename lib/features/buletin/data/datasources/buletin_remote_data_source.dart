import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/error/exceptions.dart';
import 'package:quranku/features/buletin/data/models/buletin_model.codegen.dart';
import 'package:quranku/features/buletin/data/models/buletin_response_model.codegen.dart';

import '../../../../core/network/dio_config.dart';

abstract class BuletinRemoteDataSource {
  Future<Either<ServerException, BuletinResponseModel>> getBuletins({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'desc',
  });

  Future<Either<ServerException, BuletinModel>> getBuletinDetail(int id);
}

@LazySingleton(as: BuletinRemoteDataSource)
class BuletinRemoteDataSourceImpl implements BuletinRemoteDataSource {
  final Dio _dio;

  BuletinRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(
          NetworkConfig.baseUrlKajianHub,
        );

  @override
  Future<Either<ServerException, BuletinResponseModel>> getBuletins({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '/kajian/buletin',
        queryParameters: {
          'q': query ?? '',
          'type': 'pagination',
          'page': page,
          'limit': limit,
          'order_by': orderBy,
          'sort_by': sortBy,
          'relations': 'createdBy',
        },
      );

      return Right(BuletinResponseModel.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ServerException(e));
    } on Exception catch (e) {
      return Left(ServerException(e));
    }
  }

  @override
  Future<Either<ServerException, BuletinModel>> getBuletinDetail(int id) async {
    try {
      final response = await _dio.get(
        '/kajian/buletin/$id',
        queryParameters: {
          'relations': 'createdBy',
        },
      );

      return Right(BuletinModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerException(e));
    } on Exception catch (e) {
      return Left(ServerException(e));
    }
  }
}
