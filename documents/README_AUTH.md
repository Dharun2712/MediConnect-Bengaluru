# 🚑 Smart Ambulance Authentication System

A complete, production-ready authentication system for the Smart Ambulance application with **Flask backend** and **Flutter frontend**.

## ✨ Features

### Backend (Flask + MongoDB)
- 🔐 **JWT-based authentication** with secure token generation
- 👥 **Three user roles**: Client, Ambulance Driver, Hospital Admin
- 🔒 **Bcrypt password hashing** for maximum security
- 📱 **Flexible login**: Email or phone for clients
- 🆕 **Client registration endpoint**
- 🏥 **MongoDB integration** with provided cluster
- ⚡ **Health check endpoint**

### Frontend (Flutter)
- 🎨 **Beautiful, modern UI** with Material Design
- 📑 **Tab-based role selection** (Client/Driver/Admin)
- ✅ **Real-time form validation**
- 🔐 **Secure token storage** using flutter_secure_storage
- 🎯 **Role-based routing** to appropriate dashboards
- 📱 **Cross-platform**: Works on Android, iOS, Web, Windows, macOS, Linux
- ⚡ **Loading states** and friendly error messages
- 🔄 **Auto-login** if token exists

## 🚀 Quick Start

### Option 1: Quick Start (5 minutes)
Follow **[QUICKSTART.md](QUICKSTART.md)** for the fastest way to get running.

### Option 2: Detailed Setup
Follow **[SETUP.md](SETUP.md)** for complete setup instructions with deployment guide.

## 📦 What's Included

```
sdg/
├── backend/                    # Flask Backend
│   ├── app.py                 # Main application with all endpoints
│   ├── requirements.txt       # Python dependencies
│   ├── .env.example          # Environment variables template
│   └── README.md             # Backend documentation
│
├── lib/                       # Flutter Frontend
│   ├── config/
│   │   └── api_config.dart   # API endpoint configuration
│   ├── services/
│   │   └── auth_service.dart # Authentication service
│   ├── pages/
│   │   ├── login_page.dart           # Login UI with role tabs
│   │   ├── client_dashboard.dart     # Client dashboard
│   │   ├── driver_dashboard.dart     # Driver dashboard
│   │   └── admin_dashboard.dart      # Admin dashboard
│   └── main.dart             # App entry point with routing
│
├── SETUP.md                   # Complete setup & deployment guide
├── QUICKSTART.md             # 5-minute quick start guide
└── README_AUTH.md            # This file
```

## 🔑 API Endpoints

| Endpoint | Method | Description | Request Body |
|----------|--------|-------------|--------------|
| `/api/health` | GET | Health check | - |
| `/api/login/client` | POST | Client login | `{identifier, password}` |
| `/api/login/driver` | POST | Driver login | `{driver_id, password}` |
| `/api/login/admin` | POST | Admin login | `{hospital_code, password}` |
| `/api/register/client` | POST | Register new client | `{identifier, password, name}` |

## 👥 User Roles

### 1. Client (Patient/User)
- Login with **email** or **phone number**
- Request ambulance
- View request history
- Manage profile

### 2. Ambulance Driver
- Login with unique **driver ID**
- View assigned requests
- Update trip status
- Navigation to patient

### 3. Hospital Admin
- Login with **hospital code**
- Manage ambulances
- Manage drivers
- View all requests
- Analytics & reports

## 🧪 Testing

### Test Credentials (after setup)
Create test users with password `Test123`:

- **Client**: `test@example.com` or phone `9876543210`
- **Driver**: `DR-1001`
- **Admin**: `HOSP-001`

### API Testing
```powershell
# Health check
curl http://localhost:5000/api/health

# Client login
curl -X POST http://localhost:5000/api/login/client `
  -H "Content-Type: application/json" `
  -d '{\"identifier\":\"test@example.com\",\"password\":\"Test123\"}'
```

## 🛠️ Tech Stack

### Backend
- **Flask** - Python web framework
- **MongoDB** - NoSQL database
- **PyMongo** - MongoDB driver
- **bcrypt** - Password hashing
- **PyJWT** - JSON Web Tokens

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **http** - HTTP client
- **flutter_secure_storage** - Secure token storage
- **provider** - State management (ready to use)

## 🔒 Security Features

✅ JWT token-based authentication  
✅ Bcrypt password hashing  
✅ Secure token storage  
✅ Environment variable configuration  
✅ HTTPS-ready (production)  
✅ Input validation (client & server)  
✅ Role-based access control  

## 📱 Screenshots

### Login Page
Beautiful tabbed interface for role selection with form validation and loading states.

### Dashboards
- **Client Dashboard**: Request ambulance, view history
- **Driver Dashboard**: On/off duty toggle, active requests, navigation
- **Admin Dashboard**: Statistics, manage resources, analytics

## 🚀 Deployment

### Backend
```bash
# Production with gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app

# With nginx + TLS (recommended)
# See SETUP.md for complete nginx configuration
```

### Flutter
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes
- **[SETUP.md](SETUP.md)** - Complete setup and deployment guide
- **[backend/README.md](backend/README.md)** - Backend documentation

## 🔧 Configuration

### Update API Endpoint
Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = "https://your-api-domain.com";
```

### Environment Variables
Backend uses `.env` file (create from `.env.example`):
```env
JWT_SECRET=your_secret_key
MONGO_URI=your_mongodb_uri
JWT_EXP_SECONDS=86400
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Backend won't start | Check port 5000, verify `.env` file |
| Can't connect from Flutter | Use device IP, not localhost |
| Login fails | Check MongoDB user exists with correct hash |
| Token errors | Verify JWT_SECRET is set |

See **[SETUP.md](SETUP.md)** for detailed troubleshooting.

## 🎯 Next Steps

After authentication is working:

1. ✅ **Add Registration Page** - Full UI for client signup
2. ✅ **Password Reset** - Email/SMS based recovery
3. ✅ **Protected API Routes** - Add more authenticated endpoints
4. ✅ **Core Features**:
   - Real-time ambulance tracking
   - Driver assignment algorithm
   - Hospital capacity management
   - Emergency request handling
5. ✅ **Push Notifications** - Firebase Cloud Messaging
6. ✅ **Analytics Dashboard** - Usage statistics

## 📄 License

Part of the Smart Ambulance Assistance system.

## 🤝 Contributing

This is a complete, production-ready starter template. Feel free to:
- Add more features
- Improve UI/UX
- Enhance security
- Add tests
- Optimize performance

## 📧 Support

For issues or questions:
1. Check **SETUP.md** troubleshooting section
2. Review **QUICKSTART.md** for common setup issues
3. Check Flutter/Flask documentation

---

**Built with ❤️ for emergency healthcare services**

🚑 Making ambulance assistance faster, smarter, and more reliable.
