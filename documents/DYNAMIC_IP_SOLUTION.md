# Dynamic IP Solution - No More APK Rebuilds! 🎉

## Problem Solved

Your Flutter app can now automatically find your FastAPI backend on the local network, even when your WiFi changes or router restarts. **No more rebuilding APKs!**

---

## What Was Implemented

### 1. **Backend URL Discovery & Caching** ✅
- Created `BaseApiService` in `lib/services/base_api_service.dart`
- Automatically discovers backend using multiple strategies
- Caches working URL to `SharedPreferences`
- Falls back gracefully through multiple methods

### 2. **Configuration System** ✅
- `.env` file for default backend settings
- `flutter_dotenv` package for environment variables
- Supports both IP addresses and `.local` hostnames

### 3. **mDNS/Zeroconf Discovery** ✅
- Uses `multicast_dns` package to find services on local network
- Discovers `_http._tcp.local` services automatically
- Works with Bonjour/Avahi for `.local` hostname resolution

### 4. **Platform Permissions** ✅
- **Android**: Added multicast DNS permission & cleartext traffic support
- **iOS**: Added local network usage description & Bonjour services

### 5. **FastAPI Backend** ✅
- CORS already configured for all origins
- Health endpoint (`/health`) already exists
- Ready for local network connections

---

## How It Works

### Discovery Strategy (In Order)

1. **Check Cache** → Tries saved URL from `SharedPreferences`
2. **mDNS Discovery** → Scans local network for `_http._tcp` services
3. **Try .local Hostname** → Attempts `BACKEND_HOSTNAME` from `.env` (e.g., `my-pc.local`)
4. **Fallback to .env IP** → Uses `BACKEND_URL` from `.env`
5. **Throw Error** → If nothing works, shows helpful error message

The first working URL is cached, so subsequent app launches are instant!

---

## Setup Instructions

### Step 1: Update `.env` File

1. Open `.env` in your project root
2. Update with your computer's hostname:

```env
BACKEND_URL=http://192.168.1.100:8000
BACKEND_HOSTNAME=YOUR-PC-NAME.local
BACKEND_PORT=8000
```

**To find your hostname on Windows:**
```powershell
hostname
```

Then use `YOUR-HOSTNAME.local` (e.g., if hostname is `DESKTOP-ABC123`, use `DESKTOP-ABC123.local`)

### Step 2: Install Dependencies

Run in your Flutter project directory:

```powershell
flutter pub get
```

This installs:
- `flutter_dotenv` - Environment variables
- `shared_preferences` - Persistent storage
- `multicast_dns` - Network discovery

### Step 3: Run Backend

Make sure your FastAPI backend is accessible on the network:

```powershell
cd backend
python -m uvicorn app_fastapi:app --host 0.0.0.0 --port 8000
```

**Important:** Use `--host 0.0.0.0` so other devices can connect!

### Step 4: Build & Install APK

```powershell
flutter build apk
```

Install on your phone - **this is the LAST time you'll need to rebuild for IP changes!**

---

## Using BaseApiService

### Initialize in Your Code

```dart
import 'package:sdg/services/base_api_service.dart';

final apiService = BaseApiService();
await apiService.init();

// Make requests
final response = await apiService.get('/api/endpoint');
```

### Available Methods

```dart
// GET request
final response = await apiService.get('/api/users');

// POST request
final response = await apiService.post(
  '/api/login',
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'email': 'test@example.com'}),
);

// PUT request
await apiService.put('/api/users/123', body: data);

// DELETE request
await apiService.delete('/api/users/123');
```

### Utility Methods

```dart
// Get current backend URL
String url = await apiService.getBackendUrl();

// Get cached URL (no network check)
String? cached = apiService.getCachedUrl();

// Clear cache (useful for debugging)
await apiService.clearSaved();

// Manually set backend URL
await apiService.setBackendUrl('http://192.168.1.50:8000');
```

---

## Advanced Solutions

### Option 1: Set Static Local IP (Windows)

**Method A: Windows Network Adapter Settings**

1. Open `Control Panel` → `Network and Sharing Center`
2. Click `Change adapter settings`
3. Right-click your WiFi adapter → `Properties`
4. Select `Internet Protocol Version 4 (TCP/IPv4)` → `Properties`
5. Choose `Use the following IP address`:
   - IP address: `192.168.1.50` (choose an unused IP in your range)
   - Subnet mask: `255.255.255.0`
   - Default gateway: `192.168.1.1` (your router IP)
   - Preferred DNS: `8.8.8.8` or your router IP
6. Click `OK` and reconnect

⚠️ **Downside:** Won't work if you move to different networks.

**Method B: Router DHCP Reservation (RECOMMENDED)**

1. Login to your router's admin panel (usually `http://192.168.1.1`)
2. Find `DHCP Settings` or `Address Reservation`
3. Add your laptop's MAC address and assign a fixed IP
4. Your device will always get the same IP from DHCP

✅ **Advantage:** Works across network changes, device still uses DHCP.

### Option 2: Enable Bonjour/mDNS on Windows

For `.local` hostname resolution to work:

1. **Install Bonjour:**
   - Download: [Bonjour Print Services](https://support.apple.com/kb/DL999)
   - Or install iTunes (includes Bonjour)

2. **Verify Bonjour is running:**
```powershell
Get-Service | Where-Object {$_.Name -like "*Bonjour*"}
```

Should show "Bonjour Service" as Running.

3. **Test hostname resolution:**
```powershell
ping YOUR-HOSTNAME.local
```

If it works, your Flutter app will use the hostname instead of IP!

### Option 3: Public Tunnel (ngrok / Cloudflare)

For a permanent stable URL that works anywhere:

#### **ngrok** (Quick & Easy)

1. Install: https://ngrok.com/download
2. Authenticate: `ngrok config add-authtoken YOUR_TOKEN`
3. Start tunnel:
```powershell
ngrok http 8000
```
4. Copy the HTTPS URL (e.g., `https://abc123.ngrok.io`)
5. Update `.env`:
```env
BACKEND_URL=https://abc123.ngrok.io
```

**Free tier:** Random subdomain changes on restart  
**Paid tier:** Reserved domain (e.g., `myapp.ngrok.io`)

#### **Cloudflare Tunnel** (Free & Stable)

1. Install `cloudflared`: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/
2. Login: `cloudflared tunnel login`
3. Create tunnel: `cloudflared tunnel create smart-aid`
4. Route traffic: `cloudflared tunnel route dns smart-aid backend.yourdomain.com`
5. Run tunnel:
```powershell
cloudflared tunnel run --url http://localhost:8000 smart-aid
```

Now use `https://backend.yourdomain.com` as your backend URL!

---

## Testing the Solution

### 1. **Test Backend Health**

```powershell
# From your phone's browser
http://YOUR-PC-NAME.local:8000/health
# or
http://192.168.1.X:8000/health
```

Should return:
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2025-11-19T..."
}
```

### 2. **Test Discovery in Flutter**

Add this to a test screen:

```dart
import 'package:sdg/services/base_api_service.dart';

Future<void> testBackend() async {
  final api = BaseApiService();
  await api.init();
  
  try {
    final url = await api.getBackendUrl();
    print('✅ Backend found: $url');
    
    final response = await api.get('/health');
    print('✅ Health check: ${response.body}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### 3. **Test IP Change Scenario**

1. Note your current IP: `ipconfig`
2. Run app - it should connect
3. Restart router or connect to different WiFi
4. Note new IP
5. Run app again - **it should still work!** (using cached hostname or rediscovery)

---

## Troubleshooting

### Issue: "Backend not found on local network"

**Fixes:**
1. Verify backend is running: `curl http://localhost:8000/health`
2. Check firewall isn't blocking port 8000
3. Ensure backend is bound to `0.0.0.0`, not `127.0.0.1`
4. Verify phone and laptop are on same WiFi network
5. Update `.env` with correct IP or hostname

### Issue: App still using old IP

**Fixes:**
1. Clear app cache in BaseApiService:
```dart
final api = BaseApiService();
await api.init();
await api.clearSaved(); // Clear cached URL
```
2. Or reinstall the app

### Issue: `.local` hostname not resolving

**Fixes (Windows):**
1. Install Bonjour (see "Enable Bonjour" section above)
2. Check Bonjour service is running
3. Temporarily disable Windows Firewall to test
4. Use IP address in `.env` as fallback

**Fixes (Android):**
- Some Android devices have issues with mDNS
- Fallback: Use static IP in `.env`
- Or use ngrok/Cloudflare tunnel for public URL

### Issue: CORS errors in Flutter

**Fix:** Already handled! CORS is configured in FastAPI to allow all origins.

### Issue: ERR_CLEARTEXT_NOT_PERMITTED

**Fix:** Already handled! `android:usesCleartextTraffic="true"` is set in AndroidManifest.xml

---

## Migration from Existing Code

If your existing services (like `AuthService`) use hardcoded URLs, update them:

### Before:
```dart
final response = await http.post(
  Uri.parse('http://192.168.1.100:8000/api/login'),
  body: data,
);
```

### After:
```dart
final apiService = BaseApiService();
await apiService.init();

final response = await apiService.post(
  '/api/login',
  body: data,
);
```

---

## Files Modified

✅ `pubspec.yaml` - Added dependencies  
✅ `.env` - Backend configuration  
✅ `lib/main.dart` - Initialize dotenv  
✅ `lib/services/base_api_service.dart` - Discovery service (NEW)  
✅ `android/app/src/main/AndroidManifest.xml` - Permissions  
✅ `ios/Runner/Info.plist` - Local network permissions  
✅ `backend/app_fastapi.py` - Already had CORS & health endpoint  

---

## Benefits of This Solution

✅ **No More APK Rebuilds** - IP changes handled automatically  
✅ **Multiple Discovery Methods** - Tries hostname, mDNS, IP fallback  
✅ **Persistent Caching** - Fast startup after first discovery  
✅ **Easy to Debug** - Clear cache and rediscover anytime  
✅ **Production Ready** - Add ngrok/Cloudflare tunnel for public access  
✅ **Developer Friendly** - Simple API, extensive error messages  

---

## Next Steps

1. ✅ Install dependencies: `flutter pub get`
2. ✅ Update `.env` with your hostname
3. ✅ Run backend with `--host 0.0.0.0`
4. ✅ Build APK: `flutter build apk`
5. ✅ Test on phone - **this is the last build you'll need!**
6. 🔄 Update existing services to use `BaseApiService`
7. 🚀 (Optional) Set up ngrok/Cloudflare for production

---

## Questions?

- Check logs for discovery attempts
- Use `apiService.clearSaved()` to force rediscovery
- Test backend health endpoint manually
- Ensure both devices are on same WiFi

**Happy coding! No more IP headaches! 🎉**
