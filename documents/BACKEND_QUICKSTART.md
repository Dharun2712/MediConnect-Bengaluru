# Smart-Aid Backend - Quick Start Guide 🚀

## Easy Backend Startup (Recommended)

**Just double-click** `backend/RUN_BACKEND.bat`

This will:
- Start the backend on `http://0.0.0.0:8000`
- Show **all logs directly in the terminal** (no need to tail log files!)
- Display Socket.IO connections, API requests, and mobile login attempts in real-time
- Allow you to stop the server with `CTRL+C`

### What You'll See:
```
============================================
   Smart-Aid Backend - Simple Launcher
============================================

Starting backend on http://0.0.0.0:8000
Press CTRL+C to stop the server

Logs will appear below:
----------------------------------------

INFO:     Started server process [12345]
INFO:     Waiting for application startup.
19:41:21 - INFO - MongoDB connection successful
19:41:22 - INFO - MongoDB indexes created successfully
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

When your mobile app connects, you'll see:
```
INFO:     Client connected: <socket-id>
19:42:03 - INFO - emitting event "connection_established" to <socket-id> [/]
19:42:03 - INFO - Client <socket-id> joined room: drivers
19:42:14 - INFO - OK POST   /api/auth/login                      | Status: 200 | Duration: 45.23ms | Client: 10.141.130.224
```

---

## Alternative: Background Mode (No Terminal Window)

If you want the backend to run in the background (minimized window):

```powershell
cd E:\Smart-Aid\backend
cmd /c START_FASTAPI.bat
```

Then watch logs separately:
```powershell
Get-Content -Path logs\uvicorn_err.log -Wait
```

To stop:
```powershell
cmd /c STOP_FASTAPI.bat
```

---

## Mobile App Testing

### 1. Get Your Computer's IP Address:
```powershell
ipconfig | Select-String "IPv4"
```
Look for the IP on your Wi-Fi adapter (e.g., `10.141.130.206`)

### 2. Update Mobile App Configuration:

Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:8000';  // e.g., http://10.141.130.206:8000
```

### 3. Rebuild and Install APK:

```powershell
# Build new signed release APK
flutter build apk --release

# Install on connected device
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

Or use the existing signed APK if the IP hasn't changed.

### 4. Test Login from Mobile:

Open the app and login. You'll immediately see in the backend terminal:
```
INFO:     ('10.141.130.224', 54321) - "WebSocket /socket.io/?EIO=4&transport=websocket" [accepted]
INFO:     connection open
19:42:03 - INFO - Client connected: <socket-id>
19:42:14 - INFO - OK POST   /api/auth/login                      | Status: 200 | Duration: 45.23ms | Client: 10.141.130.224
```

---

## Test Credentials

### Client Login:
- Email: `client@test.com`
- Password: (whatever you set)

### Driver Login:
- Email: `driver1@test.com`
- Password: (whatever you set)

### Hospital Admin:
- Email: `admin@apollo.com`
- Password: (whatever you set)

---

## Troubleshooting

### Mobile Can't Connect to Backend:

1. **Check firewall**: Make sure Windows Firewall allows Python on port 8000
   ```powershell
   # Add firewall rule
   netsh advfirewall firewall add rule name="Smart-Aid Backend" dir=in action=allow protocol=TCP localport=8000
   ```

2. **Verify both devices on same Wi-Fi network**

3. **Test from mobile browser**:
   - Open browser on phone
   - Go to `http://YOUR_COMPUTER_IP:8000/health`
   - Should see: `{"status":"healthy","database":"connected",...}`

### Backend Won't Start:

- Check if port 8000 is already in use:
  ```powershell
  netstat -ano | findstr :8000
  ```
- Kill any process using port 8000:
  ```powershell
  taskkill /F /PID <PID_NUMBER>
  ```

---

## Quick Commands Reference

### Start Backend (with logs in terminal):
```bat
backend\RUN_BACKEND.bat
```

### Start Backend (background mode):
```powershell
cd backend
cmd /c START_FASTAPI.bat
```

### Stop Backend:
```powershell
cd backend
cmd /c STOP_FASTAPI.bat
```

### Watch Logs (if running in background):
```powershell
cd backend
Get-Content -Path logs\uvicorn_err.log -Wait
```

### Check Backend Health:
```powershell
curl http://127.0.0.1:8000/health
```

### Rebuild & Install APK:
```powershell
flutter build apk --release
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

---

**Your backend is now running and ready for mobile testing!** 🎉

See `BACKEND_FIXES_COMPLETE.md` for detailed technical documentation.
