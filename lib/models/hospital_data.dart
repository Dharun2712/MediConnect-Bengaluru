import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

/// Hospital data model with location and details
class HospitalData {
  final String id;
  final String name;
  final LatLng location;
  final double rating;
  final int bedCount;
  final int icuCount;
  final int doctorCount;
  final double distanceFromReference;

  HospitalData({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.bedCount,
    required this.icuCount,
    required this.doctorCount,
    required this.distanceFromReference,
  });

  /// Get color based on distance from reference point
  /// Green: < 2km, Yellow: 2-3km, Orange: 3-4km, Red: > 4km
  double get markerHue {
    if (distanceFromReference < 2.0) {
      return 120.0; // Green
    } else if (distanceFromReference < 3.0) {
      return 60.0; // Yellow
    } else if (distanceFromReference < 4.0) {
      return 30.0; // Orange
    } else {
      return 0.0; // Red
    }
  }

  String get distanceCategory {
    if (distanceFromReference < 2.0) {
      return 'Very Close';
    } else if (distanceFromReference < 3.0) {
      return 'Close';
    } else if (distanceFromReference < 4.0) {
      return 'Moderate';
    } else {
      return 'Far';
    }
  }
}

/// Reference point: Sree Sakthi Engineering College, Coimbatore
const LatLng konguEngineeringCollege = LatLng(11.2219, 76.9482);

/// Calculate distance between two lat/lng points using Haversine formula (in km)
double calculateDistance(LatLng point1, LatLng point2) {
  const double earthRadius = 6371; // km
  final double lat1Rad = point1.latitude * pi / 180;
  final double lat2Rad = point2.latitude * pi / 180;
  final double dLat = (point2.latitude - point1.latitude) * pi / 180;
  final double dLng = (point2.longitude - point1.longitude) * pi / 180;
  final double a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1Rad) * cos(lat2Rad) * sin(dLng / 2) * sin(dLng / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

/// All 8 hospitals near Sree Sakthi Engineering College, Coimbatore
/// Updated with latest hospital data
/// Sorted by distance (nearest first)
List<HospitalData> getAllHospitals() {
  return [
    // 1. Sowmiya Hospital — 2.35 km
    HospitalData(
      id: 'sowmiya_hospital',
      name: 'Sowmiya Hospital',
      location: const LatLng(11.237326, 76.9334645),
      rating: 4.5,
      bedCount: 120,
      icuCount: 15,
      doctorCount: 40,
      distanceFromReference: 2.35,
    ),
    // 2. Subbu Hospital — 2.53 km
    HospitalData(
      id: 'subbu_hospital',
      name: 'Subbu Hospital',
      location: const LatLng(11.2433146, 76.9562011),
      rating: 4.3,
      bedCount: 80,
      icuCount: 10,
      doctorCount: 30,
      distanceFromReference: 2.53,
    ),
    // 3. Savidha Hospitals Private Limited — 2.78 km
    HospitalData(
      id: 'savidha_hospitals',
      name: 'Savidha Hospitals Private Limited',
      location: const LatLng(11.2374497, 76.92818),
      rating: 4.4,
      bedCount: 100,
      icuCount: 12,
      doctorCount: 35,
      distanceFromReference: 2.78,
    ),
    // 4. GH Hospital — 5.87 km
    HospitalData(
      id: 'gh_hospital',
      name: 'GH Hospital',
      location: const LatLng(11.1696487, 76.956832),
      rating: 4.6,
      bedCount: 200,
      icuCount: 25,
      doctorCount: 70,
      distanceFromReference: 5.87,
    ),
    // 5. Sri Raj Hospital — 7.23 km
    HospitalData(
      id: 'sri_raj_hospital',
      name: 'Sri Raj Hospital',
      location: const LatLng(11.1631187, 76.9197141),
      rating: 4.2,
      bedCount: 90,
      icuCount: 10,
      doctorCount: 32,
      distanceFromReference: 7.23,
    ),
    // 6. K R Hospital — 8.35 km
    HospitalData(
      id: 'kr_hospital',
      name: 'K R Hospital',
      location: const LatLng(11.1481273, 76.9336793),
      rating: 4.3,
      bedCount: 110,
      icuCount: 14,
      doctorCount: 38,
      distanceFromReference: 8.35,
    ),
    // 7. Sakthi Hospitals — 12.24 km
    HospitalData(
      id: 'sakthi_hospitals',
      name: 'Sakthi Hospitals',
      location: const LatLng(11.2995436, 76.8685783),
      rating: 4.7,
      bedCount: 180,
      icuCount: 22,
      doctorCount: 65,
      distanceFromReference: 12.24,
    ),
    // 8. KPS Hospitals (P) LTD — 12.24 km
    HospitalData(
      id: 'kps_hospitals',
      name: 'KPS Hospitals (P) LTD',
      location: const LatLng(11.2995436, 76.8685783),
      rating: 4.7,
      bedCount: 180,
      icuCount: 22,
      doctorCount: 65,
      distanceFromReference: 12.24,
    ),
  ];
}

/// Get hospitals sorted by distance
List<HospitalData> getHospitalsSortedByDistance() {
  return getAllHospitals();
}

/// Get marker for hospital
Marker createHospitalMarker(HospitalData hospital) {
  return Marker(
    markerId: MarkerId(hospital.id),
    position: hospital.location,
    icon: BitmapDescriptor.defaultMarkerWithHue(hospital.markerHue),
    infoWindow: InfoWindow(
      title: '🏥 ${hospital.name}',
      snippet:
          '${hospital.distanceFromReference.toStringAsFixed(2)}km • ⭐${hospital.rating} • 🛏️${hospital.bedCount} beds • 🏥${hospital.icuCount} ICU • 👨‍⚕️${hospital.doctorCount} doctors',
    ),
    anchor: const Offset(0.5, 0.5),
  );
}
