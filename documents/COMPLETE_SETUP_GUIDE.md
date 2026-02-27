# 🚑 Smart Ambulance System - Complete Setup Guide

## Overview
Production-ready emergency response system with:
- **Auto accident detection** (sensor + ML-based severity classification)
- **Real-time location tracking** (driver → client → hospital)
- **Geospatial ambulance dispatch** (nearest available ambulance)
- **Hospital capacity management** (ICU, beds, doctors)
- **Multi-role authentication** (Client, Driver, Hospital Admin)

---

## 🔧 Backend Setup

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

**Dependencies:**
- Flask 2.2.5
- PyMongo 4.4.0
- bcrypt 4.0.1
- PyJWT 2.8.0
- flask-socketio 5.3.4
- flask-cors 4.0.0
- python-socketio 5.9.0
- geopy 2.4.0

### 2. MongoDB Configuration
Update `MONGO_URI` in `backend/app_extended.py` with your MongoDB Atlas connection string:
```python
MONGO_URI = "mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority"
```

**Database:** `smart_ambulance`
**Collections:**
- `users` - Authentication data
- `ambulance_drivers` - Driver locations & status (geospatial indexed)
- `hospitals` - Hospital locations & capacity (geospatial indexed)
- `patient_requests` - SOS requests with geospatial coordinates

### 3. Initialize Geospatial Indexes
```bash
cd backend
python -c "from models import init_indexes; init_indexes()"
```

### 4. Create Test Users
```bash
python create_users.py
```

**Test Credentials:**
- **Client:** `client@example.com` / `Client123`
- **Driver:** `drive123` / `drive@123`
- **Admin:** `1` / `123`

### 5. Run Backend Server
```bash
# Using app_extended.py (recommended - full features)
python app_extended.py

# Server runs on: http://127.0.0.1:5000
```

---

## 📱 Flutter Frontend Setup

### 1. Install Dependencies
```bash
flutter pub get
```

**Key Dependencies:**
- `geolocator: ^10.1.0` - GPS location services
- `google_maps_flutter: ^2.5.0` - Map visualization
- `sensors_plus: ^4.0.0` - Accelerometer/gyroscope for accident detection
- `socket_io_client: ^2.0.3+1` - Real-time WebSocket updates
- `permission_handler: ^11.0.1` - Location/sensor permissions
- `tflite_flutter: ^0.10.4` - ML inference (optional)

### 2. Configure Google Maps API Key

#### Get API Key:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**
3. Create credentials → API Key
4. Restrict key to Android/iOS apps

#### Add to Android:
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

#### Add to iOS:
Edit `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. Run Flutter App
```bash
# Run on Android emulator
flutter run

# Or build APK
flutter build apk --release
```

---

## 🎯 API Endpoints Reference

### Client (User) Endpoints

#### Trigger SOS
```http
POST /api/client/sos
Authorization: Bearer <token>
Content-Type: application/json

{
  "location": {"lat": 12.9716, "lng": 77.5946},
  "condition": "accident",
  "severity": "high",
  "auto_triggered": true,
  "sensor_data": {
    "accelerometer": {"x": 0.12, "y": -9.8, "z": 2.1},
    "gyroscope": {"x": 0.05, "y": 0.1, "z": 0.0}
  }
}
```

#### Get My Requests
```http
GET /api/client/my_requests
Authorization: Bearer <token>
```

### Driver Endpoints

#### Get Nearby Patients
```http
GET /api/driver/nearby_patients
Authorization: Bearer <token>
```

#### Accept Request
```http
POST /api/driver/accept_request
Authorization: Bearer <token>
Content-Type: application/json

{
  "request_id": "507f1f77bcf86cd799439011"
}
```

#### Update Location (Real-time)
```http
POST /api/driver/update_location
Authorization: Bearer <token>
Content-Type: application/json

{
  "location": {"lat": 12.9716, "lng": 77.5946}
}
```

#### Toggle Status
```http
POST /api/driver/toggle_status
Authorization: Bearer <token>
Content-Type: application/json

{
  "active": true
}
```

### Hospital Admin Endpoints

#### Update Capacity
```http
POST /api/hospital/update_capacity
Authorization: Bearer <token>
Content-Type: application/json

{
  "capacity": {
    "icu_beds": 5,
    "general_beds": 20,
    "doctors_available": 4
  }
}
```

#### Get Patient Requests
```http
GET /api/hospital/patient_requests
Authorization: Bearer <token>
```

#### Confirm Admission
```http
POST /api/hospital/confirm_admission
Authorization: Bearer <token>
Content-Type: application/json

{
  "request_id": "507f1f77bcf86cd799439011",
  "action": "accept"  // or "reject"
}
```

### Public Endpoints

#### Get Nearby Hospitals
```http
GET /api/hospital/nearby_hospitals?lat=12.9716&lng=77.5946
```

---

## 🔄 WebSocket Events

### Client Connection
```javascript
socket.emit('join', {room: 'clients'});  // Join clients room
socket.emit('join', {room: 'user_123'}); // Join personal room
```

### Events

#### New SOS Request (Driver receives)
```json
{
  "event": "new_sos_request",
  "data": {
    "request_id": "507f1f77bcf86cd799439011",
    "client_id": "user_123",
    "location": {"lat": 12.9716, "lng": 77.5946},
    "severity": "high"
  }
}
```

#### SOS Accepted (Client receives)
```json
{
  "event": "sos_accepted",
  "data": {
    "request_id": "507f1f77bcf86cd799439011",
    "driver_id": "driver_456"
  }
}
```

#### Driver Location Update
```json
{
  "event": "driver_location_update",
  "data": {
    "driver_id": "driver_456",
    "location": {"lat": 12.9716, "lng": 77.5946}
  }
}
```

---

## 🧪 Testing Workflow

### 1. Start Backend
```bash
cd backend
python app_extended.py
```

### 2. Test Client SOS Flow

#### Login as Client
```http
POST http://localhost:5000/api/login/client
Content-Type: application/json

{
  "identifier": "client@example.com",
  "password": "Client123"
}
```

#### Trigger SOS
```http
POST http://localhost:5000/api/client/sos
Authorization: Bearer <client_token>
Content-Type: application/json

{
  "location": {"lat": 12.9716, "lng": 77.5946},
  "condition": "accident",
  "severity": "high"
}
```

### 3. Test Driver Flow

#### Login as Driver
```http
POST http://localhost:5000/api/login/driver
Content-Type: application/json

{
  "driver_id": "drive123",
  "password": "drive@123"
}
```

#### Get Nearby Patients
```http
GET http://localhost:5000/api/driver/nearby_patients
Authorization: Bearer <driver_token>
```

#### Accept Request
```http
POST http://localhost:5000/api/driver/accept_request
Authorization: Bearer <driver_token>
Content-Type: application/json

{
  "request_id": "<request_id_from_nearby_patients>"
}
```

### 4. Test Hospital Flow

#### Login as Admin
```http
POST http://localhost:5000/api/login/admin
Content-Type: application/json

{
  "hospital_code": "1",
  "password": "123"
}
```

#### Get Patient Requests
```http
GET http://localhost:5000/api/hospital/patient_requests
Authorization: Bearer <admin_token>
```

#### Confirm Admission
```http
POST http://localhost:5000/api/hospital/confirm_admission
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "request_id": "<request_id>",
  "action": "accept"
}
```

---

## 📊 Features by Dashboard

### 1️⃣ Client Dashboard (`client_dashboard_enhanced.dart`)
✅ **Manual SOS Button** - Large red emergency button  
✅ **Auto SOS Toggle** - Sensor-based accident detection  
✅ **Live Map** - Shows user, ambulance, hospital locations  
✅ **Hospital Info** - ICU availability, ETA, admission status  
✅ **Request History** - Color-coded severity (red/orange/green)

### 2️⃣ Driver Dashboard (`driver_dashboard_enhanced.dart`)
✅ **Active/Offline Toggle** - Control request visibility  
✅ **Incoming Requests** - List of nearby SOS with distance/severity  
✅ **Accept/Decline** - Quick action buttons  
✅ **Navigation** - Map route to patient location  
✅ **Status Updates** - "Picked up patient", "Reached hospital"  
✅ **Live Location Broadcast** - Real-time GPS updates

### 3️⃣ Hospital Admin Dashboard (`admin_dashboard_enhanced.dart`)
✅ **Capacity Management** - Update ICU/beds/doctors  
✅ **Incoming Patients** - List with ETA and severity  
✅ **Accept/Reject** - Admission decision buttons  
✅ **Live Tracking** - Map showing ambulances en route  
✅ **Admission History** - Past decisions with outcomes

---

## 🤖 Accident Detection System

### Sensor Monitoring
The `AccidentDetectorService` monitors:
- **Accelerometer:** Detects sudden impact (>25 m/s² threshold)
- **Gyroscope:** Detects rapid rotation (>5 rad/s threshold)

### Severity Classification
- **High:** `accelMagnitude > 40.0` or `gyroMagnitude > 8.0`
- **Mid:** `accelMagnitude > 30.0` or `gyroMagnitude > 6.0`
- **Low:** Detectable impact but below critical thresholds

### ML Integration (Optional)
For advanced severity prediction, integrate MobileNetV2:
```dart
// TODO: Load tflite_flutter model
// Model: google/mobilenet_v2_1.4_224
// Hugging Face token: <YOUR_HF_TOKEN_HERE>
```

---

## 🚨 Troubleshooting

### Backend Issues

**"No module named 'flask_socketio'"**
```bash
pip install flask-socketio flask-cors python-socketio geopy
```

**"Collection does not exist" errors**
```bash
python -c "from models import init_indexes; init_indexes()"
```

### Flutter Issues

**"MissingPluginException (Google Maps)"**
- Ensure API key is correctly added to AndroidManifest.xml
- Run `flutter clean && flutter pub get`

**Location permission denied**
- Check AndroidManifest.xml has all location permissions
- Grant permissions in Android Settings → Apps → sdg → Permissions

**"Unable to connect to backend"**
- Android emulator: Use `http://10.0.2.2:5000` (not localhost)
- Physical device: Use computer's IP address (e.g., `http://192.168.1.100:5000`)

---

## 📦 Production Deployment

### Backend (Flask)
```bash
# Use production WSGI server
pip install gunicorn gevent-websocket

gunicorn --worker-class eventlet -w 1 app_extended:app --bind 0.0.0.0:5000
```

### Frontend (Flutter)
```bash
# Build release APK
flutter build apk --release --split-per-abi

# Output: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### MongoDB
- Use MongoDB Atlas with replica set for geospatial queries
- Enable authentication and IP whitelist
- Set up backup strategy

---

## 📄 Environment Variables

Create `backend/.env`:
```env
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/?retryWrites=true&w=majority
JWT_SECRET=your_super_secret_jwt_key_here_change_in_production
JWT_EXP_SECONDS=86400
FLASK_ENV=production
```

Load in app:
```python
from dotenv import load_dotenv
load_dotenv()
```

---

## 🔐 Security Checklist

- [ ] Change JWT_SECRET in production
- [ ] Enable MongoDB authentication
- [ ] Restrict Google Maps API key to app bundle ID
- [ ] Use HTTPS for backend API
- [ ] Implement rate limiting on SOS endpoint
- [ ] Add input validation for all API endpoints
- [ ] Store sensitive tokens in flutter_secure_storage
- [ ] Enable MongoDB IP whitelist

---

## 📞 Support & Documentation

**Backend Code:** `backend/app_extended.py`  
**Client Dashboard:** `lib/pages/client_dashboard_enhanced.dart`  
**Driver Dashboard:** `lib/pages/driver_dashboard_enhanced.dart`  
**Admin Dashboard:** `lib/pages/admin_dashboard_enhanced.dart`  

**Services:**
- `lib/services/location_service.dart` - GPS tracking
- `lib/services/sos_service.dart` - SOS API calls
- `lib/services/socket_service.dart` - Real-time WebSocket
- `lib/services/hospital_service.dart` - Hospital APIs
- `lib/services/accident_detector_service.dart` - Sensor monitoring

---

## 🎉 Quick Start Summary

```bash
# 1. Backend
cd backend
pip install -r requirements.txt
python create_users.py
python app_extended.py

# 2. Frontend (new terminal)
flutter pub get
# Add Google Maps API key to AndroidManifest.xml
flutter run

# 3. Test
# Login as client → Trigger SOS → Driver accepts → Hospital confirms
```

**Default Server:** http://127.0.0.1:5000  
**Android Emulator API:** http://10.0.2.2:5000  
**Test Users:** See `LOGIN_CREDENTIALS.md`

---

**Built with ❤️ for emergency response optimization**
