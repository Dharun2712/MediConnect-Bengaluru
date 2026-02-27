# Map Location & Live Tracking Update

## Changes Implemented

### 1. Map Center Location Update
**Changed from**: Bengaluru (12.9716, 77.5946)  
**Changed to**: Apollo Hospital Karur (10.9604394, 78.0644706)

- Updated `initialCameraPosition` to center on Apollo Hospital Karur
- Increased zoom level from 12 to 13 for better visibility
- Added camera animation on map load to ensure proper centering

**Address**: Apollo Speciality Hospitals, 163 A-E, Allwyn Nagar, Kovai Main Rd, Karur, Tamil Nadu 639002

### 2. Live Ambulance Tracking with Distance & ETA

#### Added Distance Calculation
- Implemented Haversine formula to calculate accurate distance between ambulance and hospital
- Accounts for Earth's curvature for precise measurements
- Distance displayed in kilometers with 1 decimal precision

#### Added ETA Calculation
- Calculates estimated time of arrival based on average ambulance speed (40 km/h in city traffic)
- Smart formatting:
  - `< 2 min` for very short distances
  - `X min` for trips under 1 hour
  - `X hr Y min` for longer trips

#### Updated Ambulance Marker Display
**Before**: `Driver: [Name] - En route`  
**After**: `Distance: X.X km | ETA: Y min`

Real-time updates occur automatically via Socket.IO `driver_location_update` events.

## Technical Details

### New Functions Added

```dart
// Calculate distance using Haversine formula
double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degreesToRadians(lat2 - lat1);
  final dLng = _degreesToRadians(lng2 - lng1);
  
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
      sin(dLng / 2) * sin(dLng / 2);
  
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

// Calculate ETA based on average ambulance speed
String _calculateETA(double distanceKm) {
  const avgSpeedKmh = 40.0;
  final timeHours = distanceKm / avgSpeedKmh;
  final timeMinutes = (timeHours * 60).round();
  
  if (timeMinutes < 2) return '< 2 min';
  else if (timeMinutes < 60) return '$timeMinutes min';
  else {
    final hours = timeMinutes ~/ 60;
    final minutes = timeMinutes % 60;
    return minutes > 0 ? '$hours hr $minutes min' : '$hours hr';
  }
}
```

### Updated Imports
Added required math functions:
```dart
import 'dart:math' show atan2, cos, pi, sin, sqrt;
```

## File Modified
- `lib/pages/admin_dashboard_enhanced.dart`

## How It Works

1. **Map Initialization**: Map now centers on Apollo Hospital Karur automatically on load
2. **Ambulance Tracking**: When admin accepts an admission:
   - Driver accepts the request and starts moving
   - Driver's location updates in real-time via Socket.IO
   - Distance from ambulance to hospital is calculated using Haversine formula
   - ETA is computed based on 40 km/h average speed
   - Marker info window updates automatically showing: `Distance: X.X km | ETA: Y min`
3. **Route Visualization**: Blue polyline shows route from ambulance → patient → hospital

## Testing

To test the live tracking:
1. Log in as Hospital Admin
2. Wait for an SOS request to appear
3. Accept the admission
4. Watch the map as the ambulance marker updates with real-time distance and ETA
5. Blue route line will show the path: Ambulance → Patient → Apollo Hospital Karur

## Next Steps

To rebuild the APK with these changes:
```powershell
flutter clean
flutter build apk --release
```

The APK will be available at: `build\app\outputs\flutter-apk\app-release.apk`

---

**Date**: November 19, 2025  
**Version**: 1.1.0  
**Feature**: Apollo Hospital Karur location + Live ambulance tracking with distance/ETA
