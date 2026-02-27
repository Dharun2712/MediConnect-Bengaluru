# Smart Ambulance - Quick Start Guide

Get up and running in 5 minutes!

## Prerequisites
- Python 3.8+ installed
- Flutter SDK installed
- MongoDB account (using provided MongoDB URI)

## Quick Start

### Step 1: Setup Backend (2 minutes)

```powershell
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
copy .env.example .env

# Run the server
python app.py
```

Backend will run on http://localhost:5000

### Step 2: Setup Flutter (1 minute)

Open a new terminal:

```powershell
# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

### Step 3: Create Test User in MongoDB (2 minutes)

1. Go to MongoDB Atlas (https://cloud.mongodb.com)
2. Connect to your cluster
3. Navigate to the `users` collection
4. Insert a test document:

```python
# First, generate a password hash
# Run this in Python:
import bcrypt
hashed = bcrypt.hashpw(b"Test123", bcrypt.gensalt())
print(hashed)
```

Insert into MongoDB:
```json
{
  "role": "client",
  "name": "Test User",
  "email": "test@example.com",
  "password": "<paste_the_hash_here>",
  "created_at": ISODate()
}
```

### Step 4: Test Login

1. Open the Flutter app
2. Select "Client" role
3. Enter:
   - Email: `test@example.com`
   - Password: `Test123`
4. Click "Sign In"

✅ You should see the Client Dashboard!

## What's Included

### Backend (Flask)
- ✅ JWT authentication
- ✅ Three role-based login endpoints
- ✅ Client registration endpoint
- ✅ Secure password hashing (bcrypt)
- ✅ MongoDB integration

### Frontend (Flutter)
- ✅ Beautiful login UI with role tabs
- ✅ Form validation
- ✅ Secure token storage
- ✅ Role-based routing
- ✅ Three dashboard pages (Client/Driver/Admin)
- ✅ Logout functionality

## File Structure

```
sdg/
├── backend/                  # Flask backend
│   ├── app.py               # Main Flask application
│   ├── requirements.txt     # Python dependencies
│   ├── .env.example        # Environment variables template
│   └── README.md           # Backend documentation
│
├── lib/                     # Flutter frontend
│   ├── config/
│   │   └── api_config.dart # API configuration
│   ├── services/
│   │   └── auth_service.dart # Authentication service
│   ├── pages/
│   │   ├── login_page.dart      # Login UI
│   │   ├── client_dashboard.dart
│   │   ├── driver_dashboard.dart
│   │   └── admin_dashboard.dart
│   └── main.dart           # App entry point
│
├── SETUP.md                # Detailed setup guide
├── QUICKSTART.md           # This file
└── pubspec.yaml           # Flutter dependencies
```

## Test All Roles

Create these MongoDB documents to test all three roles:

**Client:**
```json
{
  "role": "client",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "<bcrypt_hash_of_Test123>"
}
```

**Driver:**
```json
{
  "role": "driver",
  "name": "Ram Kumar",
  "driver_id": "DR-1001",
  "password": "<bcrypt_hash_of_Test123>"
}
```

**Admin:**
```json
{
  "role": "admin",
  "name": "City Hospital",
  "hospital_code": "HOSP-001",
  "password": "<bcrypt_hash_of_Test123>"
}
```

## API Testing with curl

**Client Login:**
```powershell
curl -X POST http://localhost:5000/api/login/client `
  -H "Content-Type: application/json" `
  -d '{\"identifier\":\"test@example.com\",\"password\":\"Test123\"}'
```

**Health Check:**
```powershell
curl http://localhost:5000/api/health
```

## Troubleshooting

**Backend won't start:**
- Make sure port 5000 is not in use
- Check MongoDB URI in `.env` file
- Verify all dependencies are installed

**Flutter won't build:**
- Run `flutter doctor` to check setup
- Run `flutter clean` then `flutter pub get`

**Can't login:**
- Verify backend is running (check http://localhost:5000/api/health)
- Check MongoDB has test user with correct password hash
- Check browser console / Flutter logs for errors

**Testing on physical device:**
- Update `lib/config/api_config.dart` with your computer's IP
- Or use ngrok: `ngrok http 5000` and use the HTTPS URL

## Next Steps

See **SETUP.md** for:
- Production deployment guide
- Security best practices
- Advanced configuration
- Troubleshooting details

## Need Help?

Check the detailed documentation:
- **SETUP.md** - Complete setup and deployment guide
- **backend/README.md** - Backend-specific documentation
- **Flutter Docs** - https://flutter.dev/docs
- **Flask Docs** - https://flask.palletsprojects.com/

---

Happy coding! 🚀
