# 🎯 Quick Login Reference

## ✅ Your Test Accounts Are Ready!

All users have been created in MongoDB and are ready to use.

---

## 📱 CLIENT LOGIN

**Option 1 - Email:**
- Email: `client@example.com`
- Password: `Client123`

**Option 2 - Phone:**
- Phone: `9876543210`
- Password: `Client123`

---

## 🚗 DRIVER LOGIN

- Driver ID: `drive123`
- Password: `drive@123`

---

## 👨‍⚕️ ADMIN LOGIN

- Hospital Code: `1`
- Password: `123`

---

## 🧪 How to Test

### 1. CLIENT
1. Open Flutter app
2. Select "Client" tab
3. Enter: `client@example.com`
4. Password: `Client123`
5. Click "Sign In"
6. ✅ You'll see Client Dashboard

### 2. DRIVER
1. Select "Ambulance Driver" tab
2. Enter Driver ID: `drive123`
3. Password: `drive@123`
4. Click "Sign In"
5. ✅ You'll see Driver Dashboard with On/Off Duty toggle

### 3. ADMIN
1. Select "Hospital Admin" tab
2. Enter Hospital Code: `1`
3. Password: `123`
4. Click "Sign In"
5. ✅ You'll see Admin Dashboard with statistics

---

## 🔄 Why Client Registration Works Now

**In-App Registration:**
- The `/api/register/client` endpoint **DOES WORK**
- You can register new clients directly from the app
- Click "Don't have an account? Register" on the Client tab

**Driver & Admin Creation:**
- Drivers and Admins cannot self-register (security)
- They must be created by:
  - Running the `backend\create_users.py` script
  - Inserting directly into MongoDB
  - Through an admin panel (future feature)

---

## 📊 Current Database

```
Total Users: 4
├── Clients: 2
│   ├── test@example.com (Password: Test123)
│   └── client@example.com (Password: Client123)
├── Drivers: 1
│   └── drive123 (Password: drive@123)
└── Admins: 1
    └── Hospital Code: 1 (Password: 123)
```

---

## 🛠️ Create More Users

### Using Python Script:
```powershell
python backend\create_users.py
```

### Or Edit the Script to Add Custom Users:
Edit `backend\create_users.py` and modify the `main()` function.

---

## ✅ Everything is Ready!

- ✅ Backend running on http://localhost:5000
- ✅ MongoDB connected
- ✅ 4 test users created
- ✅ Client registration works
- ✅ All 3 roles can login
- ✅ Flutter app ready to test

**Go ahead and try logging in with any of the credentials above!** 🚀

---

## 📝 Notes

- **Client** can register themselves via the app or API
- **Driver** needs to be created by script or MongoDB insert
- **Admin** needs to be created by script or MongoDB insert
- All passwords are securely hashed with bcrypt
- Tokens are stored securely in flutter_secure_storage
