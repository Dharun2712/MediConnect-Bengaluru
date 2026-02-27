# 🎨 Dashboard Features Visual Guide

## 📱 Client Dashboard V2 - Screen Layout

```
┌─────────────────────────────────────────┐
│  🏥 My Emergency Care                   │
│  [Refresh] [Logout]                     │
│                                         │
│  Hello, Patient                         │
│  ID: client123                          │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  🚨 ACTIVE EMERGENCY                    │
│  ┌───────────────────────────────────┐ │
│  │ 🏥 Active Emergency    [Pending] │ │
│  │ Waiting for driver...            │ │
│  ├───────────────────────────────────┤ │
│  │ ● ━━━━━ ○ ━━━━━ ○               │ │
│  │ Request Driver  Hospital          │ │
│  │ Created Assigned Accepted         │ │
│  ├───────────────────────────────────┤ │
│  │ 🚗 Driver: Not assigned           │ │
│  │ 🏥 Hospital: Not assigned         │ │
│  ├───────────────────────────────────┤ │
│  │ 🗺️ LIVE TRACKING MAP              │ │
│  │ [Shows your location in red]     │ │
│  │ [Driver location in blue]        │ │
│  │ [Hospital location in green]     │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  [ All ] [ Active ] [ Completed ]       │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  REQUEST HISTORY                        │
│  ┌───────────────────────────────────┐ │
│  │ 🚑 Request #abc12345   [Status] │ │
│  │ Oct 29, 2025 - 10:30 AM         │ │
│  ├───────────────────────────────────┤ │
│  │ 🏥 Condition  │  ⚠️ Severity      │ │
│  │ Heart Attack │  Critical         │ │
│  ├───────────────────────────────────┤ │
│  │ 📍 Latitude   │  📍 Longitude     │ │
│  │ 12.345678    │  78.901234        │ │
│  ├───────────────────────────────────┤ │
│  │ 🚗 Driver: John Doe ✓             │ │
│  │ 🏥 Hospital: City Hospital ✓      │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
         ↓
        [SOS] ← Floating Action Button
```

---

## 🚗 Driver Dashboard V2 - Screen Layout

```
┌─────────────────────────────────────────┐
│  🚗 Driver Dashboard                    │
│  [Refresh] [Logout]                     │
│                                         │
│  Welcome, Driver                        │
│  ID: driver456                          │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  DUTY STATUS                            │
│  ┌───────────────────────────────────┐ │
│  │  ✓  ON DUTY                       │ │
│  │     Available for requests        │ │
│  │                                   │ │
│  │  [  GO OFF DUTY  ]                │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  STATISTICS                             │
│  ┌──────┐  ┌──────┐  ┌──────┐         │
│  │  📊  │  │  🚗  │  │  ✓   │         │
│  │   5  │  │   0  │  │  12  │         │
│  │Nearby│  │Active│  │Done  │         │
│  └──────┘  └──────┘  └──────┘         │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  [ Nearby ] [ My Trips ] [ History ]    │
└─────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────┐
│  NEARBY EMERGENCY REQUESTS              │
│  ┌───────────────────────────────────┐ │
│  │ 🚑 Emergency Request   📍 2.3 km │ │
│  │ Oct 29, 2025 - 11:45 AM         │ │
│  ├───────────────────────────────────┤ │
│  │ 👤 Patient                        │ │
│  │ Sarah Johnson                    │ │
│  ├───────────────────────────────────┤ │
│  │ 🏥 Condition  │  ⚠️ Severity      │ │
│  │ Heart Attack │  Critical         │ │
│  ├───────────────────────────────────┤ │
│  │ 📍 Location Coordinates           │ │
│  │ LAT: 12.345678 │ LNG: 78.901234  │ │
│  ├───────────────────────────────────┤ │
│  │ [View Map]    │   [Accept]       │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 🎨 Color Coding Guide

### Client Dashboard Colors:
- 🔴 **Red/Orange Gradient** - Main theme (Emergency)
- 🔵 **Blue** - Driver related information
- 🟢 **Green** - Hospital related information
- 🟠 **Orange** - Pending status
- ⚫ **Gray** - Cancelled/Inactive

### Driver Dashboard Colors:
- 🟠 **Orange/Amber Gradient** - Main theme (Action)
- 🔴 **Red (Critical)** - Highest severity
- 🟠 **Orange (High)** - High severity
- 🟡 **Yellow (Medium)** - Medium severity
- 🟢 **Green (Low)** - Low severity

---

## 📊 Status Flow

### Client View:
```
Request Created
    ↓
[Pending - Orange Badge]
    ↓
Driver Assigned ✓
    ↓
[En Route - Blue Badge]
    ↓
Hospital Accepted ✓
    ↓
[Accepted - Green Badge]
    ↓
[Completed - Gray Badge]
```

### Driver View:
```
Go ON DUTY
    ↓
See Nearby Requests
    ↓
View Details (Name, Condition, Lat/Long)
    ↓
View on Map
    ↓
Accept Request
    ↓
Navigate to Patient
```

---

## 🗺️ Map Features

### Client Dashboard Map:
- 🔴 **Red Marker** - Your current location
- 🔵 **Blue Marker** - Driver location (when assigned)
- 🟢 **Green Marker** - Hospital location (when accepted)
- 🔄 **Auto-refresh** - Every 5 seconds
- 📱 **Pan/Zoom** - Touch controls enabled

### Driver Dashboard Map:
- 📍 **Single Marker** - Patient location
- 🗺️ **Pop-up Dialog** - Quick view in modal
- 🧭 **Navigation Ready** - Shows exact coordinates

---

## 📱 Interactive Elements

### Client Dashboard:
1. **Pull to Refresh** - Swipe down on any list
2. **Tab Navigation** - All / Active / Completed
3. **SOS Button** - Floating action button (bottom right)
4. **Logout** - Top right corner
5. **Auto-refresh** - Active requests update automatically

### Driver Dashboard:
1. **Duty Toggle** - Large button to go ON/OFF duty
2. **Pull to Refresh** - Swipe down on requests
3. **Tab Navigation** - Nearby / My Trips / History
4. **View Map** - Opens location in dialog
5. **Accept Button** - Accept emergency request

---

## 🎯 Information Display

### Client Request Card Shows:
```
┌─────────────────────────────────────┐
│ Request ID:     #abc12345           │
│ Date/Time:      Oct 29, 10:30 AM    │
│ Condition:      Heart Attack        │
│ Severity:       Critical (Red)      │
│ Latitude:       12.345678           │
│ Longitude:      78.901234           │
│ Driver:         John Doe ✓          │
│ Hospital:       City Hospital ✓     │
│ Status:         [En Route]          │
└─────────────────────────────────────┘
```

### Driver Request Card Shows:
```
┌─────────────────────────────────────┐
│ Patient:        Sarah Johnson       │
│ Distance:       2.3 km              │
│ Condition:      Heart Attack        │
│ Severity:       Critical (Red)      │
│ Latitude:       12.345678           │
│ Longitude:      78.901234           │
│ Time:           Oct 29, 11:45 AM    │
│ [View Map]      [Accept]            │
└─────────────────────────────────────┘
```

---

## ✨ Special Features

### Live Tracking (Client):
- Map visible until hospital accepts request
- Shows real-time driver location
- Updates every 5 seconds
- Smooth camera animations

### Duty Status (Driver):
- Nearby requests ONLY visible when ON DUTY
- Green glow effect when active
- Statistics update in real-time
- Auto-refresh every 10 seconds

### Responsive Design:
- Works on all screen sizes
- Touch-friendly buttons
- Readable text hierarchy
- Sufficient padding and spacing

---

## 🚀 Quick Start

1. **Run the app**: `flutter run`
2. **Login as Client** - See request history & live tracking
3. **Login as Driver** - Toggle ON DUTY to see nearby requests
4. **Test Features** - Create SOS requests, accept them as driver

---

## 📝 Notes

- All coordinates shown with 6 decimal precision
- Severity levels color-coded for quick identification
- Distance calculated and displayed in kilometers
- Date/time in readable format (Oct 29, 2025 - 10:30 AM)
- Status badges clearly visible
- Assignment confirmations with checkmarks (✓)

---

Enjoy your beautiful new dashboards! 🎉
