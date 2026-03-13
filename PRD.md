# Product Requirement Document (PRD)

<div align="center">

## Smart Class Check-in & Learning Reflection App

| | |
|---|---|
| **Version** | 1.1 |
| **Date** | 13 March 2026 |
| **Course** | 1305216 Mobile Application Development |
| **Type** | Mobile Application (MVP) |

</div>

---

## 1. Problem Statement

### Background

Traditional classroom attendance tracking relies on manual methods — calling names, signing paper sheets, or tapping ID cards. These approaches have several critical flaws:

| Problem | Impact |
|---------|--------|
| Easy to fake (proxy attendance) | Attendance data is unreliable |
| No engagement measurement | Students may be present but not participating |
| No learning feedback loop | Instructors don't know what students expect or feel |
| Time-consuming | 5–10 minutes per session lost to attendance |
| Paper records are hard to analyze | No digital data for improvement |

### Solution

**Smart Class Check-in & Learning Reflection App** solves these problems by combining three verification and feedback mechanisms into a single mobile experience:

1. **GPS Location** — Confirms the student is physically near the classroom
2. **QR Code Scanning** — Ties each check-in to a specific session, specific room
3. **Learning Reflection Form** — Captures pre-class intent and post-class learning outcome

This creates a complete digital record of both **physical attendance** and **cognitive participation** for every class session.

---

## 2. Vision

> *"Build a smart attendance and reflection system that makes classrooms more connected — where teachers know not just who showed up, but how every student felt and what they learned."*

The system aims to:
- **Replace** unreliable paper-based attendance
- **Measure** student engagement through structured reflection
- **Enable** data-driven improvements for instructors
- **Create** a habit of learning reflection for students

---

## 3. Target Users

| User | Role | Need |
|------|------|------|
| **Students** (Primary) | University students | Simple, fast check-in + reflection that proves attendance |
| **Instructors** (Future) | Faculty members | Dashboard to monitor attendance and mood trends |
| **Administrators** (Future) | Department staff | Export reports, monitor class-level engagement data |

> **MVP Scope:** This version focuses entirely on the **student-facing experience**.  
> Instructor and admin features are planned for a future version.

---

## 4. Feature List

### 4.1 Core Features — Home Screen

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F01 | Dashboard Status | 🔴 Must Have | Live session status card showing whether student is checked in or not |
| F02 | Check-in Button | 🔴 Must Have | Navigate to the Check-in wizard |
| F03 | Finish Class Button | 🔴 Must Have | Navigate to the Finish Class wizard (only active after check-in) |
| F04 | Today's Activity | 🟡 Should Have | List of today's sessions with status badges |
| F05 | Session History | 🟢 Nice to Have | Navigate to full history with detailed records |
| F25 | Quick Stats Row | 🟡 Should Have | Three mini stat cards showing total sessions, completed, and average mood |
| F26 | Personalized Greeting | 🟡 Should Have | Time-based greeting with student name (Good Morning/Afternoon/Evening) |
| F27 | About Dialog | 🟢 Nice to Have | App info dialog showing version, course, exam date, tech stack |

### 4.2 Check-in Features — Before Class

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F06 | GPS Location Capture | 🔴 Must Have | Auto-capture latitude & longitude using device GPS |
| F07 | Timestamp Auto-record | 🔴 Must Have | Record exact date and time of check-in |
| F08 | QR Code Scanner | 🔴 Must Have | Camera scanner to read classroom QR code |
| F09 | Previous Topic Input | 🔴 Must Have | Text input: "What was covered in the previous class?" |
| F10 | Expected Topic Input | 🔴 Must Have | Text input: "What do you expect to learn today?" |
| F11 | Mood Rating (Before) | 🔴 Must Have | Emoji scale 1–5: "How do you feel about today's lesson?" |
| F12 | Form Validation | 🔴 Must Have | Ensure all required fields are filled before saving |
| F13 | Save to Local DB | 🔴 Must Have | Persist check-in data to SQLite immediately |
| F14 | Sync to Firebase | 🟡 Should Have | Background sync of check-in data to Firestore |

### 4.3 Finish Class Features — After Class

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F15 | QR Code Scanner (Out) | 🔴 Must Have | Scan QR code again to confirm student stayed until end of class |
| F16 | GPS Location Capture (Out) | 🔴 Must Have | Auto-capture GPS at check-out |
| F17 | Timestamp Auto-record (Out) | 🔴 Must Have | Record exact check-out time |
| F18 | Learning Summary Input | 🔴 Must Have | Text input: "What did you learn today?" |
| F19 | Understanding Rating | 🔴 Must Have | Emoji scale 1–5: "How well did you understand?" |
| F20 | Feedback Input | 🔴 Must Have | Text input: "Any comments or suggestions for the instructor?" |
| F21 | Update Local DB | 🔴 Must Have | Update the existing session record in SQLite |
| F22 | Sync Update to Firebase | 🟡 Should Have | Background sync of check-out data to Firestore |

### 4.4 History Features

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F23 | Session List | 🟡 Should Have | Show all past sessions ordered by date, with status badges |
| F24 | Session Detail View | 🟡 Should Have | Tap a session to see all 17 fields in a bottom sheet |
| F28 | Swipe-to-Delete | 🟡 Should Have | Swipe left on a session card to delete from SQLite + Firestore with confirmation |

### 4.5 Profile Features

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F29 | Profile Screen | 🟡 Should Have | Dedicated profile page showing student info and session statistics |
| F30 | Attendance Rate | 🟡 Should Have | Visual progress bar showing completion percentage |
| F31 | Mood Distribution | 🟢 Nice to Have | Bar chart showing distribution of mood ratings across all sessions |
| F32 | Session Streak | 🟢 Nice to Have | Consecutive day attendance streak counter |

### 4.6 Authentication Features

| ID | Feature | Priority | Description |
|----|---------|----------|-------------|
| F33 | Student Login | 🔴 Must Have | Simple login screen with Student ID and Name |
| F34 | Session Persistence | 🔴 Must Have | Remember login state using SharedPreferences |
| F35 | Logout | 🔴 Must Have | Clear session and return to login screen |

---

## 5. Rating Scale

Used for both **Mood Before Class (F11)** and **Understanding After Class (F19)**:

| Score | Emoji | Label | Interpretation |
|-------|-------|-------|----------------|
| 1 | 😡 | Very Negative | Student is unhappy or very confused |
| 2 | 🙁 | Negative | Below average mood or understanding |
| 3 | 😐 | Neutral | Average, neither positive nor negative |
| 4 | 🙂 | Positive | Good mood or good understanding |
| 5 | 😄 | Very Positive | Excellent mood or excellent understanding |

---

## 6. User Flow

### 6.1 Authentication Flow

```
Student Opens App
      │
      ▼
  First Time?
  ┌───────────────────┐
  │  Login Screen     │
  │  Enter Student ID │
  │  Enter Name       │
  │  → Save to Prefs  │
  └────────┬──────────┘
           │ ✓ Logged in
           ▼
     Home Screen
```

### 6.2 Check-in Flow (Before Class)

```
Student Opens App
      │
      ▼
 Home Screen
 [Not Checked In]
      │
      │ Tap "Check-in"
      ▼
┌─────────────────────────────────────────────┐
│           Check-in Wizard                   │
│                                             │
│  STEP 1: GPS                                │
│  ┌─────────────────────┐                    │
│  │ Tap "Get Location"  │                    │
│  │ → Capture lat/lng   │                    │
│  │ → Record timestamp  │                    │
│  └──────────┬──────────┘                    │
│             │ ✓ GPS captured                │
│             ▼                               │
│  STEP 2: QR Code                            │
│  ┌─────────────────────┐                    │
│  │ Open camera scanner  │                   │
│  │ → Scan classroom QR │                    │
│  │ → Decode QR content │                    │
│  └──────────┬──────────┘                    │
│             │ ✓ QR scanned                  │
│             ▼                               │
│  STEP 3: Reflection Form                    │
│  ┌─────────────────────┐                    │
│  │ • Previous topic    │                    │
│  │ • Expected topic    │                    │
│  │ • Mood rating (1-5) │                    │
│  │ → Tap Submit        │                    │
│  └──────────┬──────────┘                    │
│             │ ✓ Form validated              │
└─────────────┼───────────────────────────────┘
              │
              ▼
     Save to SQLite (local)
     Sync to Firestore (cloud)
              │
              ▼
   Home Screen [Checked In ✓]
```

### 6.3 Finish Class Flow (After Class)

```
Home Screen
[Checked In ✓]
      │
      │ Tap "Finish Class"
      ▼
┌─────────────────────────────────────────────┐
│          Finish Class Wizard                │
│                                             │
│  STEP 1: QR Code                            │
│  ┌─────────────────────┐                    │
│  │ Scan QR again       │                    │
│  │ → Confirm same room │                    │
│  └──────────┬──────────┘                    │
│             │ ✓ QR scanned                  │
│             ▼                               │
│  STEP 2: GPS                                │
│  ┌─────────────────────┐                    │
│  │ Get current location│                    │
│  │ → Confirm still in  │                    │
│  │   classroom area    │                    │
│  └──────────┬──────────┘                    │
│             │ ✓ GPS captured                │
│             ▼                               │
│  STEP 3: Feedback Form                      │
│  ┌─────────────────────┐                    │
│  │ • What learned today│                    │
│  │ • Understanding (1-5│                    │
│  │ • Feedback text     │                    │
│  │ → Tap Complete      │                    │
│  └──────────┬──────────┘                    │
│             │ ✓ Form validated              │
└─────────────┼───────────────────────────────┘
              │
              ▼
    Update SQLite (local)
    Sync to Firestore (cloud)
              │
              ▼
 Home Screen [Session Completed 🎉]
```

---

## 7. Data Fields

### 7.1 Session Record Schema

All check-in/check-out data is stored as a single **session record** with the following 17 fields:

| # | Field | Type | Source | Required | Description |
|---|-------|------|--------|----------|-------------|
| 1 | `id` | String (UUID) | Auto-generated | ✅ | Unique session identifier |
| 2 | `studentId` | String | App config | ✅ | Student identifier |
| 3 | `checkInTime` | DateTime | Auto (system clock) | ✅ | Exact timestamp of check-in |
| 4 | `checkInLatitude` | Double | GPS | ✅ | Latitude at check-in location |
| 5 | `checkInLongitude` | Double | GPS | ✅ | Longitude at check-in location |
| 6 | `qrCodeData` | String | QR Scan | ✅ | Content of classroom QR code |
| 7 | `previousTopic` | String | Form input | ✅ | What was taught last class |
| 8 | `expectedTopic` | String | Form input | ✅ | What student expects to learn |
| 9 | `moodBefore` | Int (1–5) | Form input | ✅ | Mood rating before class |
| 10 | `checkOutTime` | DateTime? | Auto (system clock) | ❌ | Timestamp of check-out |
| 11 | `checkOutLatitude` | Double? | GPS | ❌ | Latitude at check-out |
| 12 | `checkOutLongitude` | Double? | GPS | ❌ | Longitude at check-out |
| 13 | `qrCodeDataOut` | String? | QR Scan | ❌ | QR content scanned at check-out |
| 14 | `learnedToday` | String? | Form input | ❌ | What the student learned |
| 15 | `understandingRating` | Int? (1–5) | Form input | ❌ | Understanding rating after class |
| 16 | `feedback` | String? | Form input | ❌ | Feedback for the instructor |
| 17 | `createdAt` | DateTime | Auto-generated | ✅ | Record creation timestamp |

> Fields marked ❌ on Required are **nullable** — they are only populated after the student completes the Finish Class flow.

### 7.2 Data Storage Map

```
Session Record
│
├── Stored in SQLite (Local DB)   → Always, offline-first
│   Table: checkin_records
│   Path: /data/data/com.smartclass.smart_class_app/databases/smart_class.db
│
└── Synced to Firebase Firestore  → When internet is available
    Collection: checkin_records
    Document ID: {uuid}
    URL: https://firestore.googleapis.com/...
```

---

## 8. Tech Stack

| Layer | Technology | Package / Version | Purpose |
|-------|-----------|-------------------|---------| 
| **Framework** | Flutter (Dart) | SDK 3.41.4 / Dart 3.11.1 | Cross-platform mobile + web |
| **State Management** | StatefulWidget + setState | built-in | Manage UI state per screen |
| **Local Storage** | SQLite | `sqflite ^2.4.2` | Offline-first data persistence |
| **Cloud Database** | Firebase Firestore | `cloud_firestore ^5.6.5` | Cloud storage + future teacher access |
| **Firebase Core** | Firebase SDK | `firebase_core ^3.12.1` | Firebase initialization |
| **Hosting** | Firebase Hosting | Firebase CLI | Flutter Web deployment |
| **GPS** | Geolocator | `geolocator ^14.0.0` | Get device coordinates |
| **QR Scanner** | Mobile Scanner | `mobile_scanner ^6.0.0` | Camera-based QR scanning |
| **Permissions** | Permission Handler | `permission_handler ^11.3.1` | Runtime camera + location requests |
| **Typography** | Google Fonts | `google_fonts ^6.2.1` | Poppins font family |
| **Animations** | Animate Do | `animate_do ^3.3.4` | FadeIn, ZoomIn entrance animations |
| **Date Formatting** | Intl | `intl ^0.20.2` | Format timestamps |
| **UUID** | UUID | `uuid ^4.5.1` | Generate unique session IDs |
| **Session** | SharedPreferences | `shared_preferences ^2.5.4` | Persist login state |

---

## 9. System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     Flutter App                              │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                    UI Layer (Screens)                │   │
│  │  LoginScreen │ HomeScreen │ CheckInScreen            │   │
│  │  FinishClassScreen │ QRScannerScreen                 │   │
│  │  HistoryScreen │ ProfileScreen                       │   │
│  └────────────────────────┬─────────────────────────────┘   │
│                           │                                  │
│  ┌────────────────────────▼─────────────────────────────┐   │
│  │                  Service Layer                        │   │
│  │  LocationService │ DatabaseHelper │ FirestoreService  │   │
│  └────────┬──────────────────────────────┬──────────────┘   │
│           │                              │                   │
│  ┌────────▼──────────┐        ┌──────────▼──────────────┐   │
│  │   SQLite (Local)  │        │  Firebase Firestore      │   │
│  │  smart_class.db   │        │   checkin_records        │   │
│  │  (offline-first)  │        │   (cloud backup)         │   │
│  └───────────────────┘        └─────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
         ↕ GPS                            ↕ Internet
    Device Location                  Firebase Cloud
```

---

## 10. Non-Functional Requirements

| Category | Requirement | Detail |
|----------|-------------|--------|
| **Platform** | Cross-platform | Android 5.0+ (API 21), iOS 12+, Web (Chrome) |
| **Offline Support** | Offline-first | All data written to SQLite before Firebase sync |
| **Permissions** | Runtime requests | Camera (QR) and Location (GPS) requested at point of use |
| **Performance** | Response time | GPS capture < 10 seconds, QR scan < 3 seconds |
| **Reliability** | Graceful degradation | App remains fully functional even if Firebase is unavailable |
| **Security** | Data privacy | Location data stored locally; synced only when online |
| **Usability** | Ease of use | 3-step wizard flow; form validated before submission |

---

## 11. Out of Scope (MVP v1.1)

The following features are intentionally excluded from this version:

| Feature | Reason |
|---------|--------|
| Instructor dashboard | Requires separate admin web app |
| Geofencing auto-detection | GPS accuracy varies, needs calibration |
| Push notifications | Requires backend server setup |
| Analytics & reporting | Post-MVP feature |
| Multi-language (Thai/English) | Post-MVP feature |

---

## 12. Success Criteria

The MVP is considered successful when:

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Student can complete the full **check-in flow** (GPS + QR + reflection) | ✅ |
| 2 | Student can complete the full **finish class flow** (QR + GPS + feedback) | ✅ |
| 3 | All session data is **saved to SQLite** immediately | ✅ |
| 4 | All session data is **synced to Firebase Firestore** | ✅ |
| 5 | App works **offline** when Firebase is unavailable | ✅ |
| 6 | Flutter Web build is **deployed** via Firebase Hosting ([View Live Demo](https://smart-class-app-5eaab.web.app)) | ✅ |
| 7 | Source code is **pushed to GitHub** with README ([View Repository](https://github.com/Dechawat-Wetprasit/smart-class-app-midterm)) | ✅ |
| 8 | `flutter analyze` returns **0 errors** | ✅ |
| 9 | **Profile Screen** with session statistics and mood distribution | ✅ |
| 10 | **Quick Stats** on home screen (total, completed, avg mood) | ✅ |
| 11 | **Swipe-to-delete** sessions from both SQLite and Firestore | ✅ |
| 12 | **Student login/logout** with SharedPreferences session | ✅ |
