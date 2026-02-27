# Quick Start Guide - Dynamic IP Solution

## 🚀 Three Steps to Never Rebuild APK Again

### 1️⃣ Configure Your Backend URL
```powershell
# Run this once to auto-configure .env with your hostname and IP
.\SETUP_DYNAMIC_IP.ps1
```

### 2️⃣ Start Backend (accessible on network)
```powershell
cd backend
python -m uvicorn app_fastapi:app --host 0.0.0.0 --port 8000
```
**Important:** Use `--host 0.0.0.0` (not 127.0.0.1) so phones can connect!

### 3️⃣ Build APK ONE LAST TIME
```powershell
flutter build apk
# Install on phone - you're done! No more rebuilds needed.
```

---

## ✨ What Changes When IP Changes?

**Nothing!** The app automatically:
1. Checks cached backend URL
2. Tries mDNS discovery for `.local` hostnames
3. Falls back to direct IP from `.env`
4. Caches the working URL for next time

---

## 🔧 Using in Your Code

```dart
// Import the service
import 'package:sdg/services/base_api_service.dart';

// Initialize once
final api = BaseApiService();
await api.init();

// Make requests (URL is automatic)
final response = await api.get('/api/endpoint');
final response = await api.post('/api/login', body: data);
```

---

## 📱 Testing

### From phone browser:
```
http://LAPTOP-9U845AIS.local:8000/health
# or
http://192.168.226.206:8000/health
```

### Should return:
```json
{"status": "healthy", "database": "connected", "timestamp": "..."}
```

---

## ⚙️ Optional: Set Static IP

### Windows (Quick):
1. Open Network Adapter Settings
2. IPv4 Properties → Use static IP
3. Set IP: 192.168.1.50 (or similar)
4. Gateway: 192.168.1.1 (your router)

### Router DHCP Reservation (Better):
1. Login to router admin (usually 192.168.1.1)
2. Find DHCP settings → Address Reservation
3. Add your laptop's MAC address
4. Assign fixed IP → Save

---

## 🌐 Optional: Public Access (ngrok)

```powershell
# Install ngrok, then:
ngrok http 8000

# Copy the HTTPS URL and update .env:
BACKEND_URL=https://abc123.ngrok.io
```

---

## 🆘 Troubleshooting

### "Backend not found"
- ✅ Backend running? Check with: `curl http://localhost:8000/health`
- ✅ Using `0.0.0.0`? Not `127.0.0.1`
- ✅ Phone on same WiFi?
- ✅ Firewall blocking port 8000?

### "Clear cached URL"
```dart
final api = BaseApiService();
await api.init();
await api.clearSaved(); // Force rediscovery
```

### ".local hostname not working"
- Install Bonjour: https://support.apple.com/kb/DL999
- Or use IP address in `.env` as fallback

---

## 📚 Full Documentation

See `DYNAMIC_IP_SOLUTION.md` for:
- Detailed architecture
- Advanced configuration
- Cloudflare Tunnel setup
- Migration guide for existing services
- Platform-specific notes

---

## ✅ Files Created/Modified

✅ `.env` - Backend configuration  
✅ `lib/services/base_api_service.dart` - Discovery service  
✅ `pubspec.yaml` - Added packages  
✅ `lib/main.dart` - Initialize dotenv  
✅ `android/app/src/main/AndroidManifest.xml` - Permissions  
✅ `ios/Runner/Info.plist` - Local network access  
✅ `DYNAMIC_IP_SOLUTION.md` - Full guide  
✅ `SETUP_DYNAMIC_IP.ps1` - Auto-configuration script  

---

**You're all set! Build the APK once, and never worry about IP changes again! 🎉**
