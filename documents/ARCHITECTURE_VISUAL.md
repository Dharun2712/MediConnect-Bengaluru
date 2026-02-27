# 🚑 Smart Ambulance System - Visual Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         MOBILE APP (Flutter)                        │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐            │
│  │   CLIENT     │  │   DRIVER     │  │   HOSPITAL   │            │
│  │  DASHBOARD   │  │  DASHBOARD   │  │    ADMIN     │            │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘            │
│         │                  │                  │                     │
│         └──────────────────┼──────────────────┘                     │
│                            │                                        │
└────────────────────────────┼────────────────────────────────────────┘
                             │
                             │ REST API + WebSocket
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│                    BACKEND SERVER (Flask)                           │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                    API ENDPOINTS                             │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │ • POST /api/login/{client,driver,admin}  (JWT Auth)        │  │
│  │ • POST /api/client/sos                   (Trigger SOS)      │  │
│  │ • GET  /api/driver/nearby_patients       (Geospatial)       │  │
│  │ • POST /api/driver/accept_request        (Assignment)       │  │
│  │ • POST /api/hospital/update_capacity     (ICU/Beds)         │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                WEBSOCKET SERVER (SocketIO)                   │  │
│  ├─────────────────────────────────────────────────────────────┤  │
│  │ Rooms: drivers, clients, admins, user_<id>, driver_<id>    │  │
│  │ Events:                                                      │  │
│  │   • new_sos_request      → Notify nearby drivers            │  │
│  │   • sos_accepted         → Notify client                    │  │
│  │   • driver_location_update → Track ambulance               │  │
│  └─────────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────────┘
                             │
                             │ PyMongo + Geospatial Queries
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│                    DATABASE (MongoDB Atlas)                         │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ users                                                         │ │
│  ├──────────────────────────────────────────────────────────────┤ │
│  │ • role: client | driver | admin                              │ │
│  │ • email, phone, driver_id, hospital_code                     │ │
│  │ • password (bcrypt hash)                                     │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ ambulance_drivers                                            │ │
│  ├──────────────────────────────────────────────────────────────┤ │
│  │ • user_id (ref users)                                        │ │
│  │ • location: {type: "Point", coordinates: [lng, lat]}        │ │
│  │   → GEOSPHERE index for $near queries                       │ │
│  │ • status: available | assigned | offline                     │ │
│  │ • active: true | false                                       │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ hospitals                                                     │ │
│  ├──────────────────────────────────────────────────────────────┤ │
│  │ • user_id (ref users)                                        │ │
│  │ • name, location (GEOSPHERE indexed)                         │ │
│  │ • capacity: {icu_beds, general_beds, doctors_available}     │ │
│  │ • verified: true | false                                     │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ patient_requests                                             │ │
│  ├──────────────────────────────────────────────────────────────┤ │
│  │ • client_id, driver_id, hospital_id                          │ │
│  │ • location (GEOSPHERE indexed)                               │ │
│  │ • condition, severity (high|mid|low)                         │ │
│  │ • status: pending → accepted → admitted                      │ │
│  │ • sensor_data: {accelerometer, gyroscope}                    │ │
│  │ • auto_triggered: true | false                               │ │
│  └──────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Client Dashboard Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENT DASHBOARD                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────┐
         │   1. MANUAL SOS BUTTON             │
         │      (Big Red Button)              │
         └────────────┬───────────────────────┘
                      │ tap
                      ▼
         ┌────────────────────────────────────┐
         │   Trigger SOS                      │
         │   • Get GPS location               │
         │   • POST /api/client/sos           │
         │   • condition: "manual_sos"        │
         │   • severity: "mid"                │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   Backend finds nearest ambulances │
         │   (geospatial query, 10km radius)  │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   WebSocket emits to drivers room  │
         │   event: "new_sos_request"         │
         └────────────────────────────────────┘

                              │
                              ▼
         ┌────────────────────────────────────┐
         │   2. AUTO SOS TOGGLE               │
         │      (Sensor Monitoring)           │
         └────────────┬───────────────────────┘
                      │ enable
                      ▼
         ┌────────────────────────────────────┐
         │   Start AccidentDetectorService    │
         │   • Monitor accelerometer          │
         │   • Monitor gyroscope              │
         └────────────┬───────────────────────┘
                      │
                      ▼ (impact detected: >25 m/s²)
         ┌────────────────────────────────────┐
         │   Classify Severity                │
         │   • High: >40 m/s²                 │
         │   • Mid: >30 m/s²                  │
         │   • Low: >25 m/s²                  │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   Auto-trigger SOS                 │
         │   • POST /api/client/sos           │
         │   • auto_triggered: true           │
         │   • sensor_data: {accel, gyro}     │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   Wait for driver acceptance       │
         │   (WebSocket: "sos_accepted")      │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   3. MAP VIEW (Google Maps)        │
         │   • Show user location (blue)      │
         │   • Show ambulance (red)           │
         │   • Show hospital (green)          │
         │   • Live updates via WebSocket     │
         └────────────────────────────────────┘
```

---

## Driver Dashboard Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      DRIVER DASHBOARD                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────┐
         │   1. ACTIVE/OFFLINE TOGGLE         │
         │      (Controls visibility)         │
         └────────────┬───────────────────────┘
                      │ set active
                      ▼
         ┌────────────────────────────────────┐
         │   POST /api/driver/toggle_status   │
         │   {active: true}                   │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   Join WebSocket "drivers" room    │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   2. RECEIVE SOS REQUESTS          │
         │      (WebSocket listener)          │
         └────────────┬───────────────────────┘
                      │
                      ▼ event: "new_sos_request"
         ┌────────────────────────────────────┐
         │   GET /api/driver/nearby_patients  │
         │   (geospatial query, 20km)         │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   3. INCOMING REQUESTS LIST        │
         │   • Show distance, severity        │
         │   • [Accept] [Decline] buttons     │
         └────────────┬───────────────────────┘
                      │ tap Accept
                      ▼
         ┌────────────────────────────────────┐
         │   POST /api/driver/accept_request  │
         │   {request_id: "..."}              │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   4. CURRENT ASSIGNMENT PANEL      │
         │   • Show patient details           │
         │   • Distance & ETA                 │
         │   • [Navigate] button              │
         │   • [Picked Up] button             │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   5. LIVE LOCATION BROADCAST       │
         │   • Start GPS tracking (10m)       │
         │   • POST /api/driver/update_location│
         │   • WebSocket emits to client      │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   6. MAP VIEW (Google Maps)        │
         │   • Show driver (red)              │
         │   • Show patient (blue)            │
         │   • Route polyline                 │
         └────────────────────────────────────┘
```

---

## Hospital Admin Dashboard Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   HOSPITAL ADMIN DASHBOARD                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────┐
         │   1. CAPACITY MANAGEMENT           │
         │   • ICU Beds: 3/5                  │
         │   • General Beds: 12/20            │
         │   • Doctors: 4 on duty             │
         └────────────┬───────────────────────┘
                      │ tap [Update]
                      ▼
         ┌────────────────────────────────────┐
         │   Dialog with +/- controls         │
         │   • Adjust ICU beds                │
         │   • Adjust general beds            │
         │   • Adjust doctors                 │
         └────────────┬───────────────────────┘
                      │ tap [Update]
                      ▼
         ┌────────────────────────────────────┐
         │   POST /api/hospital/update_capacity│
         │   {capacity: {...}}                │
         └────────────────────────────────────┘

                              │
                              ▼
         ┌────────────────────────────────────┐
         │   2. INCOMING PATIENT REQUESTS     │
         │      GET /api/hospital/patient_requests│
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   List of patients (50km radius)  │
         │   • Severity (color-coded)         │
         │   • Condition                      │
         │   • [✓ Accept] [✗ Reject]         │
         └────────────┬───────────────────────┘
                      │ tap Accept
                      ▼
         ┌────────────────────────────────────┐
         │   POST /api/hospital/confirm_admission│
         │   {request_id, action: "accept"}   │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   Update patient status to "admitted"│
         │   Decrement ICU/bed count          │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   3. LIVE TRACKING MAP             │
         │   • Show all incoming ambulances   │
         │   • Color-coded by severity        │
         └────────────┬───────────────────────┘
                      │
                      ▼
         ┌────────────────────────────────────┐
         │   4. ADMISSION HISTORY             │
         │   • Past 5 admissions              │
         │   • Status: Admitted / Rejected    │
         │   • Color-coded outcomes           │
         └────────────────────────────────────┘
```

---

## Geospatial Query Visualization

```
                     CLIENT (SOS Origin)
                            ●
                          (12.9716, 77.5946)
                            │
                            │ Trigger SOS
                            ▼
     ╔══════════════════════════════════════════════════╗
     ║  MongoDB Geospatial Query:                       ║
     ║  ambulance_drivers.find({                        ║
     ║    status: "available",                          ║
     ║    location: {                                   ║
     ║      $near: {                                    ║
     ║        $geometry: {                              ║
     ║          type: "Point",                          ║
     ║          coordinates: [77.5946, 12.9716]         ║
     ║        },                                        ║
     ║        $maxDistance: 10000  // 10km             ║
     ║      }                                           ║
     ║    }                                             ║
     ║  })                                              ║
     ╚══════════════════════════════════════════════════╝
                            │
                            ▼
     ┌─────────────────────────────────────────────────┐
     │   RESULTS (Sorted by Distance):                 │
     ├─────────────────────────────────────────────────┤
     │   1. Ambulance A - 2.3 km (available)          │
     │   2. Ambulance B - 5.1 km (available)          │
     │   3. Ambulance C - 8.9 km (available)          │
     └─────────────────────────────────────────────────┘
                            │
                            ▼
     ┌─────────────────────────────────────────────────┐
     │   WebSocket Broadcast:                          │
     │   emit('new_sos_request', {                     │
     │     request_id: "...",                          │
     │     location: {lat, lng},                       │
     │     severity: "high"                            │
     │   }, room='drivers')                            │
     └─────────────────────────────────────────────────┘
                            │
                            ▼
            ┌───────┐   ┌───────┐   ┌───────┐
            │Driver │   │Driver │   │Driver │
            │   A   │   │   B   │   │   C   │
            └───────┘   └───────┘   └───────┘
            Receives    Receives    Receives
            notification notification notification
```

---

## Real-Time Location Update Flow

```
     DRIVER APP                    BACKEND                 CLIENT APP
         │                            │                         │
         │  Start Location Tracking   │                         │
         ├───────────────────────────>│                         │
         │                            │                         │
         │  GPS Update (every 10m)    │                         │
         ├───────────────────────────>│                         │
         │  POST /api/driver/update_location                   │
         │  {lat: 12.97, lng: 77.59}  │                         │
         │                            │                         │
         │                            │  WebSocket Emit         │
         │                            │  to room: driver_<id>   │
         │                            ├────────────────────────>│
         │                            │  event: "driver_location_update"│
         │                            │  {driver_id, location}  │
         │                            │                         │
         │                            │                         │
         │                            │         Update map      │
         │                            │         marker position │
         │                            │                         ▼
         │                            │                    ┌─────────┐
         │                            │                    │ Update  │
         │                            │                    │ Marker  │
         │                            │                    │ on Map  │
         │                            │                    └─────────┘
```

---

## Severity Color Coding

```
┌────────────────────────────────────────────────────────────────┐
│                      SEVERITY LEVELS                           │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  🔴 HIGH    (Red)                                              │
│     • Accelerometer: > 40 m/s²                                │
│     • Gyroscope: > 8 rad/s                                    │
│     • Critical emergency                                       │
│     • Highest priority dispatch                               │
│                                                                │
│  🟠 MID     (Orange)                                           │
│     • Accelerometer: 30-40 m/s²                               │
│     • Gyroscope: 6-8 rad/s                                    │
│     • Moderate emergency                                       │
│     • Standard priority                                        │
│                                                                │
│  🟢 LOW     (Green)                                            │
│     • Accelerometer: 25-30 m/s²                               │
│     • Gyroscope: 5-6 rad/s                                    │
│     • Minor incident                                           │
│     • Lower priority                                           │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack Visual

```
┌─────────────────────────────────────────────────────────────────┐
│                      TECHNOLOGY STACK                           │
└─────────────────────────────────────────────────────────────────┘

    FRONTEND                  BACKEND                  DATABASE
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter    │         │    Flask     │         │   MongoDB    │
│   3.9.2      │◀───────▶│    2.2.5     │◀───────▶│    Atlas     │
└──────────────┘         └──────────────┘         └──────────────┘
      │                        │                         │
      │                        │                         │
   Packages                Libraries                 Features
      │                        │                         │
      ▼                        ▼                         ▼
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│ geolocator   │         │  PyMongo     │         │  Geospatial  │
│ google_maps  │         │  bcrypt      │         │   Indexes    │
│ sensors_plus │         │  PyJWT       │         │              │
│ socket_io    │         │ flask-socketio│        │  $near       │
│ permission   │         │ flask-cors   │         │  queries     │
│ tflite       │         │  geopy       │         │              │
└──────────────┘         └──────────────┘         └──────────────┘
```

---

**Built with ❤️ for emergency response optimization**
