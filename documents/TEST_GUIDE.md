# 🚀 Quick Test Guide - Smart Ambulance SOS

## ✅ System Status
- **Backend**: Running on `http://127.0.0.1:5000`
- **Frontend**: Running on emulator-5554
- **Database**: MongoDB Atlas connected

## 🧪 Test Scenarios

### Test 1: SOS Confirmation Flow
**Steps**:
1. Login as client (client1@test.com / password)
2. Navigate to Client Dashboard
3. Tap **"Trigger SOS"** button (red button in bottom section)
4. **Observe**: Confirmation modal appears with urgent gradient
5. **Wait**: 5-second countdown before "Continue" activates
6. **Action**: Tap "Continue"
7. **Step 2**: Adjust severity slider (1-10)
8. **Optional**: Add emergency note
9. **Action**: Tap "CONFIRM SOS"
10. **Expected**: Modal closes, SOS Active Screen opens

**Success Indicators**:
- ✅ Modal has gradient background (red → orange)
- ✅ Countdown timer displays 5, 4, 3, 2, 1
- ✅ Severity slider moves smoothly
- ✅ Navigation to SOS Active Screen occurs

### Test 2: SOS Active Screen
**Steps**:
1. After confirming SOS (from Test 1)
2. **Observe**: Emergency banner at top "SOS ACTIVE - Help is on the way"
3. **Observe**: Google Map with your location marker
4. **Observe**: Status timeline showing progress:
   - ✓ SOS Triggered (green checkmark)
   - ⏳ Awaiting Driver (orange hourglass)
   - □ Driver Assigned (gray)
   - □ Driver En Route (gray)
   - □ Driver Arrived (gray)
5. **Monitor**: Backend logs for driver assignment

**Success Indicators**:
- ✅ Map centered on your location
- ✅ Timeline shows current status
- ✅ Emergency banner visible at top
- ✅ When driver accepts: Driver info card appears
- ✅ Call/Chat buttons become available

### Test 3: Driver Queue Screen
**Steps**:
1. Logout from client account
2. Login as driver (driver1@test.com / password)
3. Navigate to Driver Dashboard
4. **Action**: Tap menu → "SOS Queue" (or navigate to driver_queue route)
5. **Observe**: List of active SOS requests
6. **Observe**: Map preview with marker locations
7. **Action**: Tap a request card
8. **Observe**: Detail modal opens
9. **Action**: Tap "Accept Request"

**Success Indicators**:
- ✅ Requests sorted by severity/distance
- ✅ Color coding: Red (≥8), Orange (5-7), Yellow (<5)
- ✅ Distance and ETA displayed
- ✅ Map preview shows all active requests
- ✅ Detail modal has larger map view
- ✅ Accept button triggers navigation

### Test 4: Theme Consistency
**Steps**:
1. Navigate through all screens
2. **Check Colors**:
   - Primary buttons: Red (#ED4C5C)
   - Secondary elements: Teal (#2A9D8F)
   - Warnings: Orange (#F4A261)
   - Success states: Green (#2A9D8F)
3. **Check Typography**:
   - Headers: Bold, larger size
   - Body: Roboto, 16px
   - Labels: Roboto Condensed, 12px
4. **Check Spacing**:
   - Consistent margins and padding
   - Cards have 12px border radius
   - 16px standard spacing between elements

**Success Indicators**:
- ✅ All buttons use theme colors
- ✅ Cards have consistent styling
- ✅ Typography is readable and hierarchical
- ✅ Spacing feels balanced

## 🔍 What to Look For

### Visual Quality
- **Gradient Effects**: SOS modal should have smooth red-to-orange gradient
- **Animations**: Timeline items should have smooth transitions
- **Icons**: Material Design icons throughout
- **Cards**: Elevated with subtle shadows

### Functionality
- **Location Tracking**: Map should update with current position
- **Real-time Updates**: Status changes should reflect immediately
- **Navigation**: Smooth transitions between screens
- **Error Handling**: Graceful fallbacks for network issues

### Performance
- **Map Loading**: Should load within 2-3 seconds
- **Modal Animation**: Smooth open/close transitions
- **Scrolling**: Request list should scroll smoothly
- **Memory**: No lag when switching screens

## 🐛 Known Issues

1. **Socket.IO Connection**: May show 404 error in logs
   - **Reason**: Backend running on different host
   - **Impact**: Real-time updates delayed, falls back to REST polling
   - **Fix**: Update socket URL in `lib/config/api_config.dart`

2. **Location Permissions**: First launch requires GPS permission
   - **Action**: Accept location permission when prompted
   - **Required**: For SOS trigger to work

3. **Driver Assignment**: Requires drivers in database
   - **Solution**: Backend has 4 drivers created via init script
   - **Verify**: Check MongoDB for ambulance_drivers collection

## 📱 Test Credentials

### Client Accounts
```
Email: client1@test.com
Password: password

Email: client2@test.com  
Password: password

Email: client3@test.com
Password: password
```

### Driver Accounts
```
Email: driver1@test.com
Password: password

Email: driver2@test.com
Password: password
```

### Admin Account
```
Email: admin@test.com
Password: password
```

## 🎯 Feature Checklist

### Implemented ✅
- [x] Theme system with color palette
- [x] SOS confirmation modal (2-step)
- [x] SOS active screen with timeline
- [x] Driver queue screen with map
- [x] Real-time status updates
- [x] Severity-based prioritization
- [x] Google Maps integration
- [x] Material Design 3 styling

### Pending ⏳
- [ ] SOS resolved screen (feedback form)
- [ ] Driver navigation overlay (turn-by-turn)
- [ ] Hospital admission interface
- [ ] Push notifications (FCM)
- [ ] Offline mode support
- [ ] Call/Chat functionality (currently placeholder)
- [ ] Photo upload for incidents
- [ ] Vitals tracking

## 🔄 Hot Reload Testing

**In terminal, press**:
- `r` - Hot reload (preserves state, fast)
- `R` - Hot restart (resets state, complete reload)
- `q` - Quit app

**When to use**:
- **Hot Reload (r)**: After UI changes, color tweaks
- **Hot Restart (R)**: After adding new screens, changing routes
- **Full Rebuild**: After pubspec.yaml changes

## 📊 Backend Monitoring

**Check SOS requests**:
```powershell
# In backend terminal, watch for:
"POST /api/client/sos" - SOS triggered
"201" - Success, 3 nearby drivers found
```

**MongoDB verification**:
```javascript
// Use MongoDB Compass or shell
db.requests.find().pretty()
db.ambulance_drivers.find().pretty()
```

## 🎉 Success Criteria

**Complete Success** when:
1. ✅ SOS modal opens with gradient and countdown
2. ✅ Severity slider adjusts smoothly
3. ✅ SOS Active Screen shows timeline
4. ✅ Map displays user location marker
5. ✅ Driver queue shows mock requests
6. ✅ Theme colors consistent across screens
7. ✅ Backend responds to SOS trigger (201)
8. ✅ No app crashes or freezes

---

**Ready to test!** Start with Test 1 (SOS Confirmation Flow) and work through each scenario. 🚀
