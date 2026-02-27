# 🔐 MongoDB Setup & Password Guide

## ✅ Quick Answers to Your Questions

### 1. **What's the Password?**
- **Password**: `Test123`
- **Bcrypt Hash**: `$2b$12$23JeABIgJsPuMU.CHkiRcON7kJ7Im2hk3xziS7pAPhQol9Eo2NOf6`

### 2. **Why Can't I Register as Client?**
The client registration **WORKS**, but you need to:
- Use the `/api/register/client` endpoint from the app
- Or you can test it with curl (see below)

### 3. **Is MongoDB Connected?**
✅ **YES** - Backend is connected to: `mongodb+srv://Dharun:Dharun2712@cluster0.yr5quzl.mongodb.net/`
- Database name: `smart_ambulance`
- Collection name: `users`

---

## 📋 Step-by-Step: Create Test Users

### Option 1: Use the Registration Endpoint (Easiest for Clients)

Test client registration with curl:
```powershell
curl -X POST http://localhost:5000/api/register/client `
  -H "Content-Type: application/json" `
  -d '{\"identifier\":\"test@example.com\",\"password\":\"Test123\",\"name\":\"Test User\"}'
```

### Option 2: Insert Directly into MongoDB (For All Roles)

#### Step 1: Go to MongoDB Atlas
1. Visit https://cloud.mongodb.com
2. Login with your credentials
3. Click "Browse Collections"
4. Select Database: `smart_ambulance`
5. Collection: `users`

#### Step 2: Insert Test Documents

**CLIENT USER:**
```json
{
  "role": "client",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": {"$binary": {"base64": "JDJiJDEyJDIzSmVBQklnSnNQdU1VLkNIa2lSY09ON2tKN0ltMmhrM3h6aVM3cEFQaFFvbDlFbzJOT2Y2", "subType": "00"}},
  "created_at": {"$date": "2025-10-24T00:00:00.000Z"}
}
```

Or simpler (MongoDB will accept string):
```json
{
  "role": "client",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "9876543210",
  "password": "$2b$12$23JeABIgJsPuMU.CHkiRcON7kJ7Im2hk3xziS7pAPhQol9Eo2NOf6",
  "created_at": {"$date": "2025-10-24T00:00:00.000Z"}
}
```

**DRIVER USER:**
```json
{
  "role": "driver",
  "name": "Ram Kumar",
  "driver_id": "DR-1001",
  "phone": "9999999999",
  "password": "$2b$12$23JeABIgJsPuMU.CHkiRcON7kJ7Im2hk3xziS7pAPhQol9Eo2NOf6",
  "created_at": {"$date": "2025-10-24T00:00:00.000Z"}
}
```

**ADMIN USER:**
```json
{
  "role": "admin",
  "name": "City Hospital",
  "hospital_code": "HOSP-001",
  "password": "$2b$12$23JeABIgJsPuMU.CHkiRcON7kJ7Im2hk3xziS7pAPhQol9Eo2NOf6",
  "created_at": {"$date": "2025-10-24T00:00:00.000Z"}
}
```

---

## 🧪 Test Login Credentials

After inserting the documents above:

### Client Login:
- **Email**: `john@example.com` OR **Phone**: `9876543210`
- **Password**: `Test123`

### Driver Login:
- **Driver ID**: `DR-1001`
- **Password**: `Test123`

### Admin Login:
- **Hospital Code**: `HOSP-001`
- **Password**: `Test123`

---

## 🔍 Verify MongoDB Connection

### Check if database exists:
```powershell
# Test the health endpoint
curl http://localhost:5000/api/health
```

### Check MongoDB from Python:
```python
from pymongo import MongoClient

client = MongoClient("mongodb+srv://Dharun:Dharun2712@cluster0.yr5quzl.mongodb.net/")
db = client["smart_ambulance"]
users = db["users"]

# Check if collection exists
print("Collections:", db.list_collection_names())

# Count users
print("User count:", users.count_documents({}))

# List all users
for user in users.find():
    print(user)
```

---

## 🚀 Test Client Registration from Flutter App

1. **Open the Flutter app** (should be running)
2. **Select "Client" tab**
3. **Click "Don't have an account? Register"**
4. Follow the dialog instructions

OR test directly with API:

```powershell
# Register new client
curl -X POST http://localhost:5000/api/register/client `
  -H "Content-Type: application/json" `
  -d '{\"identifier\":\"alice@example.com\",\"password\":\"Alice123\",\"name\":\"Alice Smith\"}'
```

**Expected Response:**
```json
{
  "success": true,
  "role": "client",
  "user_id": "67xxxxxxxxxxxx",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

---

## ❌ Common Issues & Solutions

### Issue: "User not found"
**Solution**: Insert user document in MongoDB first (see above)

### Issue: "Invalid credentials"
**Solution**: Make sure you're using the bcrypt hash, not plain password in MongoDB

### Issue: "User already exists"
**Solution**: The email/phone is already registered. Use a different identifier or delete the existing user.

### Issue: Password hash as string vs binary
**Solution**: MongoDB accepts both formats. Use string format (simpler):
```json
"password": "$2b$12$23JeABIgJsPuMU.CHkiRcON7kJ7Im2hk3xziS7pAPhQol9Eo2NOf6"
```

---

## 📊 Database Structure

```
MongoDB Atlas
└── Cluster0
    └── smart_ambulance (database)
        └── users (collection)
            ├── Client documents (role: "client")
            ├── Driver documents (role: "driver")
            └── Admin documents (role: "admin")
```

---

## 🔐 Generate New Password Hashes

To create hashes for different passwords:

```powershell
python backend\generate_password.py
```

Or in Python:
```python
import bcrypt
password = b"YourPassword"
hash = bcrypt.hashpw(password, bcrypt.gensalt())
print(hash.decode('utf-8'))  # Use this string in MongoDB
```

---

## ✅ Quick Checklist

- [x] Backend running on http://localhost:5000
- [x] Flutter app running
- [ ] MongoDB has test users (insert documents above)
- [ ] Test login with credentials above
- [ ] Try client registration

---

## 🎯 Next Steps

1. **Insert test users** in MongoDB (copy-paste JSON above)
2. **Test login** in Flutter app
3. **Try registration** for client role
4. **View dashboard** after successful login

The MongoDB connection is working! You just need to add the user documents. 🚀
