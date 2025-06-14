import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quranku/features/shalat/domain/entities/geolocation.codegen.dart';
import 'package:quranku/features/shalat/domain/entities/schedule.codegen.dart';
import 'package:quranku/features/shalat/presentation/helper/location_helper.dart';

void main() {
  test('test prayer time', () {
    final coordinate = Coordinates(
      -6.3173563,
      106.7447118,
      validate: true,
    );
    for (var element in CalculationMethod.values) {
      final params = element.getParameters();
      for (var madhab in Madhab.values) {
        params.madhab = madhab;
        params.adjustments = PrayerAdjustments(
          fajr: 0,
          dhuhr: 0,
          asr: 0,
          maghrib: 20,
          isha: 0,
        );
        final prayerTimes = PrayerTimes.today(coordinate, params);
        debugPrint('Calculation Method: ${element.name}');
        debugPrint('Madhab: ${params.madhab.name}');
        debugPrint('Fajr: ${prayerTimes.fajr}');
        debugPrint('Dhuhr: ${prayerTimes.dhuhr}');
        debugPrint('Asr: ${prayerTimes.asr}');
        debugPrint('Maghrib: ${prayerTimes.maghrib}');
        debugPrint('Isha: ${prayerTimes.isha}');
        debugPrint('Sunrise: ${prayerTimes.sunrise}');
        debugPrint('');
      }
    }
  });
  
  group('LocationHelper', () {
    test('should calculate distance between two coordinates correctly', () {
      // Jakarta coordinates
      const double lat1 = -6.2088;
      const double lon1 = 106.8456;
      
      // Bandung coordinates
      const double lat2 = -6.9175;
      const double lon2 = 107.6191;
      
      // Expected distance between Jakarta and Bandung is approximately 116.24 km
      final double distance = LocationHelper.calculateDistance(lat1, lon1, lat2, lon2);
      
      // Allow for some margin of error in the calculation
      expect(distance, closeTo(116.24, 5.0));
    });
    
    test('should detect significant location changes', () {
      // Create two locations with significant distance
      final location1 = GeoLocation(
        coordinate: Coordinate(lat: -6.2088, lon: 106.8456),
        country: 'Indonesia',
        regions: List.from(['Jakarta']),
      );
      
      final location2 = GeoLocation(
        coordinate: Coordinate(lat: -6.9175, lon: 107.6191),
        country: 'Indonesia',
      );
      
      // Should detect as significantly different
      expect(LocationHelper.isLocationSignificantlyDifferent(location1, location2), true);
      
      // Create two locations with minimal distance
      final location3 = GeoLocation(
        coordinate: Coordinate(lat: -6.2088, lon: 106.8456),
        country: 'Indonesia',
      );
      
      final location4 = GeoLocation(
        coordinate: Coordinate(lat: -6.2090, lon: 106.8458),
        country: 'Indonesia',
      );
      
      // Should not detect as significantly different
      expect(LocationHelper.isLocationSignificantlyDifferent(location3, location4), false);
      
      // Test with null locations
      expect(LocationHelper.isLocationSignificantlyDifferent(null, location2), true);
      expect(LocationHelper.isLocationSignificantlyDifferent(location1, null), true);
      
      // Test with null coordinates
      final locationWithNullCoordinate = GeoLocation(
        coordinate: null,
        country: 'Indonesia',
      );
      
      expect(LocationHelper.isLocationSignificantlyDifferent(locationWithNullCoordinate, location2), true);
    });
  });
}
