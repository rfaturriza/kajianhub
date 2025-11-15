import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/network/dio_config.dart';
import 'package:quranku/features/pray/data/models/prayer_model.codegen.dart';
import 'package:quranku/features/pray/data/models/prayers_response_model.codegen.dart';

abstract class PrayRemoteDataSource {
  Future<PrayersResponseModel> getPrayers({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'asc',
  });

  Future<PrayerModel> getPrayerDetail(int id);
}

@LazySingleton(as: PrayRemoteDataSource)
class PrayRemoteDataSourceImpl implements PrayRemoteDataSource {
  final Dio _dio;
  PrayRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(
          NetworkConfig.baseUrlKajianHub,
        );

  @override
  Future<PrayersResponseModel> getPrayers({
    String? query,
    int page = 1,
    int limit = 12,
    String orderBy = 'id',
    String sortBy = 'asc',
  }) async {
    try {
      final response = await _dio.get(
        'kajian/prayers',
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          'type': 'pagination',
          'page': page,
          'limit': limit,
          'order_by': orderBy,
          'sort_by': sortBy,
          'relations': '',
        },
      );
      return PrayersResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch prayers: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching prayers');
    }
  }

  @override
  Future<PrayerModel> getPrayerDetail(int id) async {
    try {
      final response = await _dio.get(
        'kajian/prayers/$id',
      );
      return PrayerModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to fetch prayer detail: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error occurred while fetching prayer detail');
    }
  }
}
