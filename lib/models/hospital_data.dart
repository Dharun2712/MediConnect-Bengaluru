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

/// Reference point: Saveetha Engineering College, Chennai
const LatLng konguEngineeringCollege = LatLng(13.0285647, 80.0142324);

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

/// All 8 hospitals near Saveetha Engineering College, Chennai
/// Sorted by distance (nearest first)
List<HospitalData> getAllHospitals() {
  return [
    // 1. Saveetha Medical Center — 1.07 km
    HospitalData(
      id: 'saveetha_medical_center',
      name: 'Saveetha Medical Center',
      location: const LatLng(13.0239381, 80.0055357),
      rating: 4.6,
      bedCount: 200,
      icuCount: 25,
      doctorCount: 80,
      distanceFromReference: 1.07,
    ),
    // 2. Aachi Hospital — 1.46 km
    HospitalData(
      id: 'aachi_hospital',
      name: 'Aachi Hospital',
      location: const LatLng(13.0405157, 80.0077017),
      rating: 4.3,
      bedCount: 100,
      icuCount: 12,
      doctorCount: 35,
      distanceFromReference: 1.46,
    ),
    // 3. Shifa Medicals & SP Clinic Emergency 24hrs & Lab — 1.78 km
    HospitalData(
      id: 'shifa_medicals',
      name: 'Shifa Medicals & SP Clinic',
      location: const LatLng(13.0381752, 80.0286376),
      rating: 4.2,
      bedCount: 60,
      icuCount: 8,
      doctorCount: 20,
      distanceFromReference: 1.78,
    ),
    // 4. Panimalar Medical College Hospital — 2.61 km
    HospitalData(
      id: 'panimalar_medical_college',
      name: 'Panimalar Medical College Hospital',
      location: const LatLng(13.0437301, 80.0347024),
      rating: 4.5,
      bedCount: 300,
      icuCount: 30,
      doctorCount: 100,
      distanceFromReference: 2.61,
    ),
    // 5. Hopewell Hospital — 2.99 km
    HospitalData(
      id: 'hopewell_hospital',
      name: 'Hopewell Hospital',
      location: const LatLng(13.0318194, 79.9874457),
      rating: 4.4,
      bedCount: 120,
      icuCount: 15,
      doctorCount: 45,
      distanceFromReference: 2.99,
    ),
    // 6. Pettai 24 Hours Hospital — 2.61 km
    HospitalData(
      id: 'pettai_24hrs_hospital',
      name: 'Pettai 24 Hours Hospital',
      location: const LatLng(13.0437301, 80.0347024),
      rating: 4.1,
      bedCount: 80,
      icuCount: 10,
      doctorCount: 25,
      distanceFromReference: 2.61,
    ),
    // 7. Gandhi Hospital — 6.15 km
    HospitalData(
      id: 'gandhi_hospital',
      name: 'Gandhi Hospital',
      location: const LatLng(13.0033869, 79.961439),
      rating: 4.5,
      bedCount: 250,
      icuCount: 30,
      doctorCount: 90,
      distanceFromReference: 6.15,
    ),
    // 8. Be Well Hospitals Poonamallee — 11.06 km
    HospitalData(
      id: 'be_well_hospitals',
      name: 'Be Well Hospitals Poonamallee',
      location: const LatLng(13.0288357, 80.1137108),
      rating: 4.7,
      bedCount: 180,
      icuCount: 22,
      doctorCount: 65,
      distanceFromReference: 11.06,
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
