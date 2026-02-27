# Smart Ambulance Authentication System - Setup Guide

This guide walks you through setting up the complete authentication system with Flask backend and Flutter frontend.

## Table of Contents
1. [MongoDB Setup](#mongodb-setup)
2. [Flask Backend Setup](#flask-backend-setup)
3. [Flutter Frontend Setup](#flutter-frontend-setup)
4. [Testing](#testing)
5. [Production Deployment](#production-deployment)

---

## MongoDB Setup

### 1. Database Structure

The system uses a single `users` collection with a `role` field to distinguish between different user types.

### 2. Sample Documents

Insert these test documents into your `users` collection:

#### Client User
```json
{
  "role": "client",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "<bcrypt_hash>",
  "created_at": ISODate("2025-10-24T00:00:00Z")
}
```

#### Driver User
```json
{
  "role": "driver",
  "name": "Ram Kumar",
  "driver_id": "DR-1001",
  "phone": "9999999999",
  "password": "<bcrypt_hash>",
  "created_at": ISODate("2025-10-24T00:00:00Z")
}
```

#### Admin User
```json
{
  "role": "admin",
  "name": "City Hospital",
  "hospital_code": "HOSP-001",
  "password": "<bcrypt_hash>",
  "created_at": ISODate("2025-10-24T00:00:00Z")
}
```

### 3. Generate Password Hashes

Use this Python script to generate bcrypt password hashes:

```python
import bcrypt

def hash_password(password):
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(pwd_bytes, salt)
    return hashed

# Example: Generate hash for password "Test123"
password = "Test123"
hashed = hash_password(password)
print(f"Hashed password: {hashed}")
```

Or run directly in Python shell:
```bash
python -c "import bcrypt; print(bcrypt.hashpw(b'Test123', bcrypt.gensalt()))"
```

**Insert the binary hash value into MongoDB for the `password` field.**

### 4. Test Credentials

After inserting sample data with password "Test123":

- **Client**: 
  - Email: `john@example.com` or Phone: `9876543210`
  - Password: `Test123`

- **Driver**:
  - Driver ID: `DR-1001`
  - Password: `Test123`

- **Admin**:
  - Hospital Code: `HOSP-001`
  - Password: `Test123`

---

## Flask Backend Setup

### 1. Install Python (if not already installed)

Download and install Python 3.8 or later from [python.org](https://www.python.org/downloads/).

### 2. Setup Virtual Environment

```powershell
cd backend
python -m venv venv
.\venv\Scripts\activate
```

### 3. Install Dependencies

```powershell
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Copy `.env.example` to `.env`:
```powershell
copy .env.example .env
```

Edit `.env` and update:
```env
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXP_SECONDS=86400
MONGO_URI=mongodb+srv://Dharun:Dharun2712@cluster0.yr5quzl.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
```

**⚠️ IMPORTANT:** Change `JWT_SECRET` to a strong random string in production!

### 5. Run the Development Server

```powershell
python app.py
```

The server will start on `http://localhost:5000`

### 6. Verify Backend is Running

Open a browser or use curl:
```powershell
curl http://localhost:5000/api/health
```

Expected response:
```json
{"success": true, "message": "OK"}
```

---

## Flutter Frontend Setup

### 1. Install Flutter Dependencies

```powershell
flutter pub get
```

### 2. Configure API Endpoint

Open `lib/config/api_config.dart` and update the `baseUrl`:

**For local development:**
```dart
static const String baseUrl = "http://localhost:5000";
```

**For testing on physical device or with ngrok:**
```dart
static const String baseUrl = "https://your-ngrok-url.ngrok.io";
```

### 3. Run the Flutter App

```powershell
flutter run
```

Or for specific device:
```powershell
flutter run -d windows
flutter run -d chrome
```

---

## Testing

### 1. Test Backend API with curl

#### Client Login
```powershell
curl -X POST http://localhost:5000/api/login/client `
  -H "Content-Type: application/json" `
  -d '{\"identifier\":\"john@example.com\",\"password\":\"Test123\"}'
```

#### Driver Login
```powershell
curl -X POST http://localhost:5000/api/login/driver `
  -H "Content-Type: application/json" `
  -d '{\"driver_id\":\"DR-1001\",\"password\":\"Test123\"}'
```

#### Admin Login
```powershell
curl -X POST http://localhost:5000/api/login/admin `
  -H "Content-Type: application/json" `
  -d '{\"hospital_code\":\"HOSP-001\",\"password\":\"Test123\"}'
```

#### Client Registration
```powershell
curl -X POST http://localhost:5000/api/register/client `
  -H "Content-Type: application/json" `
  -d '{\"identifier\":\"alice@example.com\",\"password\":\"Alice123\",\"name\":\"Alice Smith\"}'
```

### 2. Test Flutter App

1. Launch the app
2. Select a role (Client / Driver / Admin)
3. Enter credentials from test data
4. Click "Sign In"
5. Verify navigation to appropriate dashboard
6. Test logout functionality

---

## Production Deployment

### Backend Deployment

#### 1. Use Environment Variables

Set these environment variables on your production server:
```bash
export JWT_SECRET="your_very_strong_secret_key_here"
export MONGO_URI="your_production_mongodb_uri"
export FLASK_ENV="production"
```

#### 2. Use Gunicorn (Production WSGI Server)

Install gunicorn:
```bash
pip install gunicorn
```

Run with gunicorn:
```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

#### 3. Setup Nginx with TLS

Example nginx configuration:
```nginx
server {
    listen 443 ssl;
    server_name api.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Get free SSL certificate with Let's Encrypt:
```bash
sudo certbot --nginx -d api.yourdomain.com
```

### Flutter Deployment

#### 1. Update API Configuration

In `lib/config/api_config.dart`:
```dart
static const String baseUrl = "https://api.yourdomain.com";
```

#### 2. Build Release Version

**For Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

**For iOS:**
```bash
flutter build ios --release
```

**For Web:**
```bash
flutter build web --release
```

**For Windows:**
```bash
flutter build windows --release
```

---

## Security Best Practices

1. **Never commit `.env` files** - Add to `.gitignore`
2. **Use strong JWT secrets** - At least 32 random characters
3. **Always use HTTPS in production** - Never send credentials over plain HTTP
4. **Implement rate limiting** - Prevent brute force attacks
5. **Add account lockout** - Lock accounts after failed login attempts
6. **Validate all inputs** - Server-side validation is crucial
7. **Keep dependencies updated** - Regularly update packages
8. **Use secure password policies** - Enforce minimum length and complexity
9. **Log authentication events** - Monitor for suspicious activity
10. **Rotate JWT tokens** - Implement refresh token mechanism for long sessions

---

## Troubleshooting

### Backend Issues

**Problem:** MongoDB connection fails
- Check `MONGO_URI` is correct
- Verify network access in MongoDB Atlas
- Check firewall settings

**Problem:** JWT token errors
- Ensure `JWT_SECRET` is set
- Check token expiration time
- Verify Authorization header format

### Flutter Issues

**Problem:** Network error when logging in
- Verify backend is running
- Check `api_config.dart` has correct URL
- For Android emulator, use `10.0.2.2:5000` instead of `localhost:5000`
- For physical device, use your computer's IP address or ngrok

**Problem:** Token not persisting
- Check `flutter_secure_storage` permissions
- For Android, ensure minimum SDK version is 18+
- For iOS, ensure keychain access is configured

---

## Next Steps

Once the authentication system is working, you can:

1. **Add Registration Page** - Full client registration UI
2. **Implement Password Reset** - Email/SMS based password recovery
3. **Add Protected API Routes** - Use `@token_required` decorator
4. **Build Core Features**:
   - Ambulance request system
   - Real-time tracking
   - Driver assignment
   - Hospital management
5. **Add Push Notifications** - For request updates
6. **Implement Analytics** - Track usage and performance

---

## Support & Resources

- **Flask Documentation**: https://flask.palletsprojects.com/
- **Flutter Documentation**: https://flutter.dev/docs
- **MongoDB Documentation**: https://docs.mongodb.com/
- **JWT Best Practices**: https://tools.ietf.org/html/rfc8725

---

## License

This project is part of the Smart Ambulance Assistance system.
