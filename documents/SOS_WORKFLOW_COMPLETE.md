# 🚑 Complete SOS Workflow Implementation Guide

## Overview
This document describes the complete end-to-end SOS emergency response workflow from client triggering SOS to admin receiving injury assessment.

## Workflow Steps

### 1️⃣ Client Triggers SOS
**Location**: `lib/pages/client_dashboard_enhanced.dart`

**Process**:
1. Client taps "Trigger SOS" button
2. SOS Confirmation Modal appears (2-step process)
3. Client confirms and sets severity level
4. SOS request sent to backend

**API Call**:
```
POST /api/client/sos
Body: {
  location: {lat, lng},
  condition: "manual_sos",
  preliminary_severity: "mid"
}
```

**Response**: Request ID and nearby drivers count

---

### 2️⃣ Driver Receives SOS Alert
**Location**: `lib/pages/driver_dashboard_enhanced.dart`

**Real-time Notification**:
- Socket.IO event: `new_sos_request`
- Driver sees request in incoming requests list
- Can view details (distance, severity, patient location)

**Driver Actions**:
- **Accept**: Driver accepts the request
- **Decline**: Driver declines, request goes to other drivers

---

### 3️⃣ Driver Accepts Request
**API Call**:
```
POST /api/driver/accept_request
Body: {request_id: "..."}
```

**Backend Process** (`backend/app_extended.py`):
1. Atomic update - only first driver wins
2. Request status changes: `pending` → `accepted` → `enroute`
3. Driver info added to request
4. ETA calculated based on distance
5. Socket.IO events emitted:
   - To client: `request_assigned` (with driver info)
   - To driver: `request_assigned` (with patient info)

**Client Notification**:
- Client sees "Driver assigned!" message
- Navigation to SOS Active Screen
- Shows driver info, ETA, live map

---

### 4️⃣ Driver Arrives & Assesses Injury
**Location**: `lib/pages/injury_assessment_dialog.dart`

**Trigger**: 2 seconds after accepting request (simulated arrival)

**Injury Assessment Dialog**:
- **Risk Level Selection**:
  - 🟢 Low Risk
  - 🟠 Medium Risk
  - 🔴 High Risk

- **Symptoms Checklist** (organized by category):
  - **Vital Signs**: Unconscious, Difficulty Breathing, Chest Pain, Severe Bleeding
  - **Mobility**: Cannot Move, Broken Bones, Severe Pain, Paralysis
  - **Mental Status**: Confused, Disoriented, Loss of Memory, Seizure

- **Additional Notes**: Free-text field for observations

**Submission**:
```
POST /api/driver/submit_assessment
Body: {
  request_id: "...",
  injury_risk: "low|medium|high",
  injury_notes: "detailed observations"
}
```

---

### 5️⃣ Backend Processes Assessment
**File**: `backend/app_extended.py` (Line ~515)

**Process**:
1. Validates driver is assigned to this request
2. Updates request with:
   - `injury_risk`: low/medium/high
   - `injury_notes`: driver observations
   - `assessment_time`: timestamp
   - `status`: `assessed`

3. Emits Socket.IO events:
   - `injury_assessment_submitted` → **admin** room
   - `assessment_received` → **client** (patient)

**Event Payload to Admin**:
```json
{
  "request_id": "...",
  "injury_risk": "high",
  "injury_notes": "Patient unconscious...",
  "patient_name": "John Doe",
  "location": {...},
  "driver_id": "...",
  "timestamp": "2025-10-24T..."
}
```

---

### 6️⃣ Admin Receives Assessment
**Location**: `lib/pages/admin_dashboard_enhanced.dart`

**Real-time Update**:
- Socket listener on `injury_assessment_submitted` event
- Patient card updates with injury risk badge
- Color-coded based on risk level:
  - 🟢 Green: Low Risk
  - 🟠 Orange: Medium Risk
  - 🔴 Red: High Risk

**Visual Display**:
```
┌─────────────────────────────────────────────┐
│ 🔴 Injury: HIGH RISK                        │
│ Status: assessed                             │
│ Notes: Patient unconscious, chest pain...   │
│ [HIGH] ✅ Accept  ❌ Reject                  │
└─────────────────────────────────────────────┘
```

**Admin Actions**:
- **Accept**: Admit patient to hospital
- **Reject**: Redirect to another facility

**Snackbar Notification**:
- Shows: "New injury assessment: John Doe - HIGH risk"
- Background color matches risk level

---

## Data Flow Diagram

```
┌──────────┐     SOS Trigger      ┌──────────┐
│  Client  │ ──────────────────→  │  Backend │
└──────────┘                       └──────────┘
                                        │
                                        ↓
                                   Find nearby
                                    drivers
                                        │
                                        ↓
                                  ┌──────────┐
                  Socket.IO  ←────│  Driver  │
                  new_sos          └──────────┘
                                        │
                                        ↓
                                   Accept SOS
                                        │
                                        ↓
                                   ┌──────────┐
                  Socket.IO  ────→ │  Client  │
                  request_assigned  └──────────┘
                                        │
                                        ↓
                                  Driver arrives
                                   & assesses
                                        │
                                        ↓
                                   Submit injury
                                   assessment
                                        │
                                        ↓
                                   ┌──────────┐
                  Socket.IO  ────→ │  Admin   │
                  injury_assessment └──────────┘
```

---

## Files Modified

### Frontend (Flutter)
1. ✅ `lib/pages/injury_assessment_dialog.dart` - NEW
   - Complete injury assessment UI
   - Risk level selection
   - Symptoms checklist
   - Notes field

2. ✅ `lib/pages/driver_dashboard_enhanced.dart`
   - Added injury assessment trigger
   - `_showInjuryAssessmentDialog()` method
   - `_submitInjuryAssessment()` method
   - Import `injury_assessment_dialog.dart`

3. ✅ `lib/pages/admin_dashboard_enhanced.dart`
   - Socket.IO listener for assessments
   - `_handleNewAssessment()` method
   - Updated patient card UI with risk badges
   - Color-coded injury risk display

4. ✅ `lib/services/sos_service.dart`
   - Added `submitInjuryAssessment()` method
   - API integration for assessment submission

5. ✅ `lib/services/socket_service.dart`
   - Exposed `socket` getter for custom event listeners

### Backend (Python Flask)
1. ✅ `backend/app_extended.py`
   - New endpoint: `/api/driver/submit_assessment`
   - Validates driver assignment
   - Updates request with injury data
   - Emits Socket.IO events to admin & client

---

## Testing the Workflow

### Step-by-Step Test

1. **Start Backend**:
   ```powershell
   cd backend
   python app_extended.py
   ```

2. **Run Flutter App** (already running)

3. **Login as Client**:
   - Email: `client1@test.com`
   - Password: `password`

4. **Trigger SOS**:
   - Tap red "Trigger SOS" button
   - Wait 5 seconds
   - Set severity slider
   - Confirm SOS

5. **Switch to Driver** (new emulator or logout/login):
   - Email: `driver1@test.com`
   - Password: `password`
   - See incoming SOS request
   - Tap "Accept"

6. **Injury Assessment Dialog Appears**:
   - Select risk level (Low/Medium/High)
   - Check symptoms
   - Add notes
   - Submit

7. **Switch to Admin** (or check admin dashboard):
   - Email: `admin@test.com`
   - Password: `password`
   - See incoming patient with injury risk badge
   - Snackbar notification appears
   - Patient card shows risk level and notes

---

## Socket.IO Events Summary

| Event Name | From | To | Purpose |
|------------|------|----|---------
| `new_sos_request` | Backend | Driver | Notify driver of new SOS |
| `request_assigned` | Backend | Client | Notify client driver accepted |
| `request_assigned` | Backend | Driver | Confirm assignment to driver |
| `injury_assessment_submitted` | Backend | Admin | Send assessment to hospital |
| `assessment_received` | Backend | Client | Notify client assessment done |

---

## Database Schema Updates

**Collection**: `patient_requests`

**New Fields**:
```javascript
{
  injury_risk: "low" | "medium" | "high",
  injury_notes: "Text observations from driver",
  assessment_time: ISODate("2025-10-24T..."),
  status: "assessed" // Added to status enum
}
```

---

## Success Criteria

✅ Client can trigger SOS  
✅ Driver receives real-time notification  
✅ Driver can accept request  
✅ Injury assessment dialog appears automatically  
✅ Driver can select risk level and symptoms  
✅ Assessment sent to backend successfully  
✅ Admin receives real-time notification  
✅ Admin dashboard shows injury risk badge  
✅ Color coding works (green/orange/red)  
✅ Patient notes displayed to admin  

---

## Next Steps (Future Enhancements)

1. **Photo Upload**: Allow driver to upload injury photos
2. **Vital Signs**: Add fields for heart rate, blood pressure, etc.
3. **AI Assessment**: Auto-suggest risk level based on symptoms
4. **Hospital Routing**: Auto-assign to hospital based on risk level
5. **Ambulance Tracking**: Real-time GPS tracking during transit
6. **Medical History**: Show patient's medical history to driver
7. **Multi-language**: Support for injury descriptions in multiple languages

---

**Status**: ✅ Complete and Ready to Test
**Last Updated**: October 24, 2025
