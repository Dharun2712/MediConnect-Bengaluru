# 🚀 Release APK Build - LifeLink Ambulance App

## 📋 Release Configuration

### Backend API Endpoint
- **Production Server**: `http://20.47.72.43:8000`
- **Configuration File**: `lib/config/api_config.dart`

### Build Command
```bash
flutter build apk --release
```

### Output Location
After successful build, the APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## 📱 APK Details

### Application Info
- **Package Name**: `com.example.sdg`
- **Min SDK**: 26 (Android 8.0)
- **Target SDK**: Latest Flutter target
- **Signing**: Using keystore from `android/key.properties`

### Features Included
✅ Hospital Mapping System (8 hospitals near Kongu Engineering College)
✅ Color-coded distance markers
✅ Real-time ambulance tracking
✅ SOS emergency system
✅ Driver dashboard with live requests
✅ Client dashboard with hospital list
✅ Socket.IO real-time communication

## 🔧 Installation Instructions

### For Testing on Physical Device:

1. **Enable USB Debugging** on Android device
2. **Transfer APK** to device
3. **Install** by tapping the APK file
4. **Allow installation** from unknown sources if prompted

### Via ADB:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via PowerShell Script:
The `INSTALL_APK.ps1` script can be used:
```powershell
.\INSTALL_APK.ps1
```

## 🌐 Backend Requirements

Ensure the backend server is running at `20.47.72.43:8000`:

### Python Backend:
```bash
cd backend
python app_extended.py
```

### Expected Services:
- REST API endpoints
- Socket.IO WebSocket server
- MongoDB database connection

### Verify Server:
```bash
curl http://20.47.72.43:8000/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "..."
}
```

## 🗺️ Hospital Data

The APK includes data for 8 hospitals near Kongu Engineering College:

| Hospital | Distance | Color |
|----------|----------|-------|
| Sree Shaanthi Hospital | 2.0 km | 🟢 Green |
| ADHITHI HOSPITAL | 2.0 km | 🟢 Green |
| Priya Hospital | 2.2 km | 🟡 Yellow |
| Sivakumar Hospital | 2.2 km | 🟡 Yellow |
| Marutham Hospital | 2.5 km | 🟡 Yellow |
| KMC Hospital | 2.7 km | 🟡 Yellow |
| M A G Hospital | 2.7 km | 🟡 Yellow |
| Govt Hospital - Perundurai | 3.0 km | 🟠 Orange |

## 📊 Build Information

### Dependencies:
- Flutter SDK
- Google Maps Flutter
- Socket.IO Client
- Geolocator
- HTTP
- And 40+ other packages

### Signing Configuration:
The APK is signed using the keystore defined in:
- `android/key.properties` (signing credentials)
- `android/key.jks` (keystore file)

## 🎯 User Roles

### Client/User:
- Login with email/phone
- Trigger SOS
- View nearby hospitals
- Track ambulance location

### Driver:
- Login with driver ID
- Accept/decline requests
- View hospital locations
- Navigate to patient

### Admin/Hospital:
- Login with hospital code
- View incoming patients
- Accept/reject admissions
- Update bed capacity

## 🔒 Permissions Required

The APK requires the following Android permissions:
- ✅ **Location** (GPS tracking)
- ✅ **Internet** (API communication)
- ✅ **Network State** (Connection monitoring)
- ✅ **Foreground Service** (Background tracking)
- ✅ **Notifications** (Alerts)

## 📦 File Size

Expected APK size: ~50-100 MB
(Includes Google Maps, ML models, and assets)

## 🐛 Troubleshooting

### Build Fails:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Retry build

### APK Won't Install:
1. Enable "Unknown Sources" in Android settings
2. Check minimum Android version (8.0+)
3. Ensure enough storage space

### Connection Issues:
1. Verify backend server is running
2. Check IP address is accessible
3. Ensure firewall allows port 8000

## ✅ Testing Checklist

After installation:
- [ ] App launches successfully
- [ ] Login works for all roles
- [ ] Map displays with hospital markers
- [ ] Hospital list shows 8 hospitals
- [ ] Colors match distance categories
- [ ] Backend API connection works
- [ ] Real-time updates function

## 📞 Support

For issues or questions:
1. Check logs: `adb logcat | grep Flutter`
2. Verify backend connectivity
3. Review console output during build

---

**Build Date**: January 23, 2026
**Backend URL**: http://20.47.72.43:8000
**Status**: ✅ Building Release APK
