import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../error/failures.dart';
import '../../features/shalat/domain/entities/geolocation.codegen.dart';
import '../../features/shalat/domain/entities/schedule.codegen.dart';
import '../../generated/locale_keys.g.dart';
import 'location_permission_service.dart';

@injectable
class LocationService {
  /// Gets current location with proper prominent disclosure
  Future<Either<Failure, GeoLocation?>> getCurrentLocation({
    required BuildContext context,
    Locale? locale,
  }) async {
    try {
      final result = await _determinePosition(
        context: context,
        locale: locale ?? const Locale('en'),
      );
      return Right(result);
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  Future<GeoLocation> _determinePosition({
    required BuildContext context,
    required Locale locale,
  }) async {
    // Check location services
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(LocaleKeys.errorLocationDisabled.tr());
    }

    // Request permission with prominent disclosure (check context mount first)
    if (!context.mounted) {
      return Future.error(LocaleKeys.errorLocationDenied.tr());
    }

    final permission =
        await LocationPermissionService.requestLocationPermission(context);

    if (permission == LocationPermission.denied) {
      return Future.error(LocaleKeys.errorLocationDenied.tr());
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(LocaleKeys.errorLocationPermanentDenied.tr());
    }

    // Get position
    final resultLocator = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      resultLocator.latitude,
      resultLocator.longitude,
    );

    return GeoLocation(
      cities: placemarks.map((e) => e.administrativeArea).toList(),
      regions: placemarks.map((e) => e.subAdministrativeArea).toList(),
      country: placemarks.first.country,
      coordinate: Coordinate(
          lat: resultLocator.latitude,
          lon: resultLocator.longitude,
          latitude: resultLocator.latitude.toString(),
          longitude: resultLocator.longitude.toString()),
      url:
          "https://www.google.com/maps/search/?api=1&query=${resultLocator.latitude},${resultLocator.longitude}",
    );
  }
}
