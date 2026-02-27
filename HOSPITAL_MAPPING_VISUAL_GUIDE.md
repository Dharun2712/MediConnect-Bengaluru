# Hospital Mapping Visual Guide

## 🗺️ Map View

```
                    📍 Kongu Engineering College
                    (Maharaja Auditorium)
                         11.2722933, 77.6038564
                              |
                              |
        +-----------------+---+---+------------------+
        |                 |       |                  |
        |                 |       |                  |
    🟢 Sree Shaanthi  🟢 ADHITHI  🟡 Priya      🟡 Sivakumar
       (~2.0 km)       (~2.0 km)   (~2.2 km)       (~2.2 km)
        |                                               |
        |                                               |
    🟡 Marutham                                    🟡 KMC & M A G
       (~2.5 km)                                      (~2.7 km)
                                                        |
                                                        |
                                              🟠 Govt Hospital Perundurai
                                                     (~3.0 km)
```

## 📱 Mobile App Views

### Driver Dashboard
```
┌─────────────────────────────────────┐
│  Driver Dashboard            [≡][⟳] │
├─────────────────────────────────────┤
│                                     │
│  ╔═════════════════════════════╗   │
│  ║        Google Map           ║   │
│  ║                             ║   │
│  ║  🔵 Reference Point         ║   │
│  ║  🟢 Hospital (Very Close)   ║   │
│  ║  🟡 Hospital (Close)        ║   │
│  ║  🟠 Hospital (Moderate)     ║   │
│  ║  🔴 Hospital (Far)          ║   │
│  ║                             ║   │
│  ╚═════════════════════════════╝   │
│                                     │
│  [Nearby Requests]                  │
│                                     │
│          [🏥 Hospitals]  ◄──────────┤ Floating button
│                                     │
└─────────────────────────────────────┘
```

### User/Client Dashboard
```
┌─────────────────────────────────────┐
│  User Dashboard              [⟳][✕] │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │  🚨 TRIGGER SOS               │ │
│  │                               │ │
│  └───────────────────────────────┘ │
│                                     │
│  ╔═════════════════════════════╗   │
│  ║        Google Map           ║   │
│  ║                             ║   │
│  ║  🔵 Your Location           ║   │
│  ║  🟠 Ambulance               ║   │
│  ║  🟢 Hospitals (Colored)     ║   │
│  ║                             ║   │
│  ╚═════════════════════════════╝   │
│                                     │
│          [🏥 Hospitals]  ◄──────────┤ Floating button
│                                     │
└─────────────────────────────────────┘
```

## 🏥 Hospital List Bottom Sheet

```
┌─────────────────────────────────────────┐
│        ──                               │ ◄─ Drag handle
│  🏥 Nearby Hospitals              [✕]   │
├─────────────────────────────────────────┤
│  Legend:                                │
│  🟢 Very Close  🟡 Close                │
│  🟠 Moderate    🔴 Far                  │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐ │
│  │ 🏥 Sree Shaanthi Hospital   [2.0km]│ │ ◄─ Green border
│  │ ⭐ 4.2  🛏️ 80  🏥 8  👨‍⚕️ 25         │ │
│  │ [Very Close]                       │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ 🏥 ADHITHI HOSPITAL        [2.0km]│ │ ◄─ Green border
│  │ ⭐ 4.4  🛏️ 90  🏥 10  👨‍⚕️ 30        │ │
│  │ [Very Close]                       │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ 🏥 Priya Hospital          [2.2km]│ │ ◄─ Yellow border
│  │ ⭐ 4.1  🛏️ 70  🏥 7  👨‍⚕️ 22         │ │
│  │ [Close]                            │ │
│  └───────────────────────────────────┘ │
│  ... (more hospitals)                   │
└─────────────────────────────────────────┘
```

## 🗺️ Hospital Info Window (On Map)

When you tap a hospital marker:
```
┌─────────────────────────────────────┐
│  🏥 Sree Shaanthi Hospital          │
│  ─────────────────────────────────  │
│  2.00km • ⭐4.2 • 🛏️80 beds •      │
│  🏥8 ICU • 👨‍⚕️25 doctors            │
└─────────────────────────────────────┘
```

## 🎨 Color Coding Examples

### Map Markers
- **🔵 Blue/Azure**: Reference Point (Kongu Engineering College)
- **🟢 Green (Hue 120°)**: Very Close (< 2 km)
- **🟡 Yellow (Hue 60°)**: Close (2-3 km)
- **🟠 Orange (Hue 30°)**: Moderate (3-4 km)
- **🔴 Red (Hue 0°)**: Far (> 4 km)

### Hospital Cards
Each card has:
1. **Border Color**: Matches distance category
2. **Distance Badge**: Top-right corner with color
3. **Stats Chips**: 
   - ⭐ Rating (Amber)
   - 🛏️ Beds (Blue)
   - 🏥 ICU (Red)
   - 👨‍⚕️ Doctors (Green)
4. **Category Badge**: Bottom-right (Very Close/Close/Moderate/Far)

## 📊 Hospital Statistics Display

```
Hospital Card Layout:
┌─────────────────────────────────────────┐
│ Hospital Name            [Distance Badge]│ ◄─ Colored border
│                                          │
│ [⭐ 4.2] [🛏️ 80 beds] [🏥  8 ICU]        │
│                                          │
│ [👨‍⚕️ 25 doctors]        [Category Badge] │
└─────────────────────────────────────────┘
```

## 🔄 Data Flow

```
User Action
    │
    ├─→ Tap Map
    │      │
    │      └─→ Show Info Window
    │            (Hospital details)
    │
    └─→ Tap [Hospitals] Button
           │
           └─→ Open Bottom Sheet
                  │
                  ├─→ Show Legend
                  ├─→ Show All Hospitals
                  │   (Sorted by distance)
                  │
                  └─→ Tap Hospital Card
                         │
                         └─→ Close Sheet
                             (Optional: Focus map)
```

## 📐 Distance Calculation

```
Haversine Formula:
─────────────────
a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)
c = 2 × atan2(√a, √(1-a))
distance = R × c

Where:
- R = 6371 km (Earth's radius)
- lat1, lon1 = Reference point (Kongu College)
- lat2, lon2 = Hospital location
- Result in kilometers
```

## 🎯 User Experience Flow

### New User Opens App
1. **Login** as Driver or Client
2. **See Map** with colored hospital markers
3. **Notice** reference point (Blue marker)
4. **Observe** color-coded hospitals (Green = Nearest)
5. **Tap Marker** to see hospital details
6. **Tap [Hospitals] Button** to see full list
7. **Scroll List** sorted by distance (nearest first)
8. **Read Details** on each hospital card
9. **Select Hospital** (optional navigation)

### During Emergency (Client)
1. **Trigger SOS**
2. **Map Updates** with ambulance location
3. **Route Line** drawn to nearest hospital (Green marker)
4. **Track Ambulance** approaching
5. **See Hospital Details** where you'll be taken

### Accepting Request (Driver)
1. **See Request** with patient location
2. **View Map** with all hospitals
3. **Plan Route** considering nearest hospitals
4. **Accept Request**
5. **Navigate** with hospital options visible

## 💡 Key Features Highlighted

✅ **Real-time Distance**: Calculated from reference point
✅ **Visual Clarity**: Color-coded pins easy to distinguish
✅ **Detailed Info**: Rating, beds, ICU, doctors all visible
✅ **Sorted List**: Always shows nearest hospitals first
✅ **Interactive**: Tap markers, cards, buttons
✅ **Responsive**: Works in both Driver and Client dashboards
✅ **Database Ready**: Backend script to populate MongoDB

---

**Visual Guide Complete** 🎨
All UI elements designed for maximum clarity and usability!
