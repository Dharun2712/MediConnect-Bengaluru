# Install Smart Ambulance App on Your Phone via USB

## Prerequisites
1. **Enable Developer Options** on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times until you see "You are now a developer!"

2. **Enable USB Debugging**:
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect your phone** to the computer via USB cable

## Installation Steps

### Method 1: Using Flutter (Recommended)
1. Connect your phone via USB
2. On your phone, allow USB debugging when prompted
3. Run this command:
   ```powershell
   flutter devices
   ```
   You should see your phone listed

4. Install the app:
   ```powershell
   flutter install
   ```

### Method 2: Using ADB Directly
1. Navigate to the project folder:
   ```powershell
   cd d:\projects\sdg\sdg
   ```

2. Install via ADB:
   ```powershell
   adb install SmartAmbulance_Latest.apk
   ```

### Method 3: Manual Transfer (If USB not working)
1. **Copy the APK** `SmartAmbulance_Latest.apk` from:
   ```
   d:\projects\sdg\sdg\SmartAmbulance_Latest.apk
   ```

2. **Transfer to phone**:
   - Option A: Email it to yourself and download on phone
   - Option B: Upload to Google Drive and download on phone
   - Option C: Use USB cable to copy to phone's Download folder

3. **Install on phone**:
   - Open the APK file on your phone
   - Tap "Install"
   - If prompted, allow "Install from Unknown Sources" for this app

## Important: Network Configuration

⚠️ **Your phone MUST be on the same WiFi network as your computer!**

Current backend IP address: `http://10.0.251.131:5000`

### Verify Connection:
1. Make sure your phone is connected to the same WiFi as your PC
2. Your PC's IP is: `10.0.251.131`
3. Backend is running on port `5000`

### If Connection Fails:
1. Check your PC's current IP address:
   ```powershell
   ipconfig
   ```
   Look for "IPv4 Address" under your WiFi adapter

2. Update the IP in the app's config file:
   - File: `lib\config\api_config.dart`
   - Line: `url = "http://YOUR_PC_IP:5000";`

3. Rebuild the APK:
   ```powershell
   flutter build apk --debug
   copy build\app\outputs\flutter-apk\app-debug.apk SmartAmbulance_Latest.apk
   ```

## Test Credentials

### Client Login
- Email: `john.doe@example.com` OR `client@example.com`
- Phone: `9876543210`
- Password: `client123` OR `Client123`

### Driver Login
- Driver ID: `drive123`
- Password: `drive@123`

### Hospital Login
- Hospital Code: `hospital1`
- Password: `hospital@1`

## Troubleshooting

### Phone Not Detected
1. Make sure USB debugging is enabled
2. Try different USB cable (some cables are charge-only)
3. Try different USB port on your computer
4. Install your phone's USB drivers from manufacturer website

### App Won't Install
1. Enable "Install from Unknown Sources" in Settings
2. If app exists, uninstall old version first
3. Make sure you have enough storage space

### Can't Connect to Backend
1. Verify both devices are on same WiFi network
2. Check Windows Firewall isn't blocking port 5000
3. Try accessing `http://10.0.251.131:5000/api/health` from phone's browser
4. If needed, temporarily disable firewall for testing

## Backend Status
✅ Backend is currently running on: `http://10.0.251.131:5000`

To restart backend if needed:
```powershell
cd d:\projects\sdg\sdg\backend
python app_extended.py
```

## APK Location
The ready-to-install APK is located at:
```
d:\projects\sdg\sdg\SmartAmbulance_Latest.apk
```
Size: ~50-60 MB
