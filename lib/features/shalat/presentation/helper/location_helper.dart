import 'dart:math';

import 'package:quranku/features/shalat/domain/entities/geolocation.codegen.dart';

/// Helper class for location-related operations
class LocationHelper {
  /// Threshold in kilometers for determining if a location change is significant
  static const double locationChangeThreshold = 5.0;

  /// Calculates the distance between two coordinates using the Haversine formula
  /// Returns the distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    // Convert degrees to radians
    final double lat1Rad = lat1 * (pi / 180);
    final double lon1Rad = lon1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double lon2Rad = lon2 * (pi / 180);
    
    // Haversine formula
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;
    
    return distance;
  }
  
  /// Determines if two locations are significantly different
  /// Returns true if the distance between them is greater than the threshold
  static bool isLocationSignificantlyDifferent(
    GeoLocation? location1,
    GeoLocation? location2,
  ) {
    // If either location is null, consider them different
    if (location1 == null || location2 == null) {
      return true;
    }
    
    // If coordinates are missing, consider them different
    if (location1.coordinate == null || location2.coordinate == null) {
      return true;
    }
    
    // Calculate distance between the two locations
    final double distance = calculateDistance(
      location1.coordinate?.lat ?? 0,
      location1.coordinate?.lon ?? 0, 
      location2.coordinate?.lat ?? 0,
      location2.coordinate?.lon ?? 0,
    );
    
    // Return true if the distance is greater than the threshold
    return distance > locationChangeThreshold;
  }
  
  /// Determines if a location has valid coordinates
  static bool hasValidCoordinates(GeoLocation? location) {
    if (location == null || location.coordinate == null) {
      return false;
    }
    
    final lat = location.coordinate?.lat ?? 0;
    final lon = location.coordinate?.lon ?? 0;
    
    // Check if coordinates are within valid ranges
    return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  }
}