import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/network/dio_config.dart';
import '../../models/carousel_events_response_model.codegen.dart';

abstract class CarouselRemoteDataSource {
  Future<CarouselEventsResponseModel> getCarouselEvents();
}

@LazySingleton(as: CarouselRemoteDataSource)
class CarouselRemoteDataSourceImpl implements CarouselRemoteDataSource {
  final Dio _dio;

  CarouselRemoteDataSourceImpl()
      : _dio = NetworkConfig.getDioCustom(
          NetworkConfig.baseUrlKajianHub,
        );

  @override
  Future<CarouselEventsResponseModel> getCarouselEvents() async {
    try {
      final response = await _dio.get('/settings/carousel-events');
      return CarouselEventsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch carousel events: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
