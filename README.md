<div align="center">

# 🎓 Smart Class Check-in & Learning Reflection App

**A premium Flutter mobile application for smart classroom attendance tracking**

![Flutter](https://img.shields.io/badge/Flutter-3.41.4-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.1-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![SQLite](https://img.shields.io/badge/SQLite-Local_DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white)

> **Course:** 1305216 Mobile Application Development  
> **Exam:** Midterm Lab Exam — 13 March 2026

</div>

---

## 📖 Overview

Universities currently lack a **reliable and tamper-proof** way to verify that students are physically present in classrooms and actively participating in sessions.

This application solves the problem by combining three verification mechanisms:

| Mechanism | Purpose |
|-----------|---------| 
| 📍 **GPS Location** | Confirms student is physically inside the classroom |
| 📸 **QR Code Scan** | Ties attendance to a specific class session |
| 📝 **Learning Reflection** | Captures engagement before and after class |

The system records both **check-in** (before class) and **check-out** (after class) along with structured reflection data, synced to Firebase Firestore for teacher access.

---

## ✨ Features

### Student-Facing Features

| Feature | Description |
|---------|-------------|
| 📍 GPS Location Recording | Auto-captures lat/lng coordinates at check-in and check-out |
| 📸 QR Code Scanning | Real-time camera scanner with animated overlay |
| 🕐 Timestamp Recording | Records exact check-in and check-out times |
| 😊 Mood Rating (Before Class) | 5-point emoji mood scale — how you feel about today's lesson |
| 📝 Previous Topic Input | What was covered in the last class |
| 💡 Expected Topic Input | What you expect to learn today |
| 📖 Learning Summary (After Class) | What did you actually learn |
| 🧠 Understanding Rating (After Class) | How well did you understand the lesson (1–5) |
| 💬 Feedback | Comments or suggestions about the class |
| 📊 Session History | View all past sessions with full detail |
| 👤 Profile Screen | Student info, session statistics, mood distribution chart |
| 📈 Quick Stats | Home screen mini cards showing total sessions, completed, avg mood |
| 🗑️ Swipe-to-Delete | Swipe left on history cards to delete from SQLite + Firestore |
| 🔑 Student Login | Simple login with Student ID and Name, persisted via SharedPreferences |
| ℹ️ About Dialog | App version, course info, tech stack details |
| 👋 Personalized Greeting | Time-based greeting with student name on home screen |
| 🔔 Premium Animated Notifications | Custom sliding SnackBars and pulsing dialogs for all alerts |
| 🛡️ Student Data Isolation | Security layer to ensure users only see their own private history |
| 🔐 User Verification | Labeled Student ID-Name mapping to prevent unauthorized name changes |

### Technical Features

| Feature | Detail |
|---------|--------|
| 🔄 Offline-First | All data saved to SQLite locally before Firebase sync |
| ☁️ Cloud Sync | Background sync to Firebase Firestore (save, update, delete) |
| 🔐 Permission Handling | Runtime camera + location permissions |
| 🎨 Premium UI | Dark glassmorphism design with animations |
| 🚀 Firebase Hosting | Deployed as Flutter Web app |
| 📱 Session Persistence | Login state remembered across app restarts |

---

## 🏗️ Architecture

### Tech Stack

| Layer | Technology | Package |
|-------|-----------|---------| 
| **Framework** | Flutter 3.41.4 (Dart) | — |
| **State Management** | setState + StatefulWidget | built-in |
| **Local Storage** | SQLite | `sqflite ^2.4.2` |
| **Cloud Database** | Firebase Firestore | `cloud_firestore ^5.6.5` |
| **Firebase Core** | Firebase SDK | `firebase_core ^3.12.1` |
| **GPS** | Geolocator | `geolocator ^14.0.0` |
| **QR Scanner** | Mobile Scanner | `mobile_scanner ^6.0.0` |
| **Permissions** | Permission Handler | `permission_handler ^11.3.1` |
| **Animations** | Animate Do | `animate_do ^3.3.4` |
| **Typography** | Google Fonts (Poppins) | `google_fonts ^6.2.1` |
| **Date Formatting** | Intl | `intl ^0.20.2` |
| **UUID Generation** | UUID | `uuid ^4.5.1` |
| **Session** | SharedPreferences | `shared_preferences ^2.5.4` |
| **Hosting** | Firebase Hosting | — |

### Project Structure

```
smart_class_app/
├── lib/
│   ├── main.dart                       # App entry point, Firebase init, login state check
│   ├── theme/
│   │   └── app_theme.dart              # Dark glassmorphism theme, colors, gradients
│   ├── models/
│   │   └── checkin_record.dart         # Data model with 17 fields, toMap/fromMap
│   ├── services/
│   │   ├── database_helper.dart        # SQLite: CRUD, active session, today's records
│   │   ├── location_service.dart       # GPS with permission request flow
│   │   └── firestore_service.dart      # Firebase Firestore cloud sync + delete
│   ├── screens/
│   │   ├── login_screen.dart           # Student ID + Name login with SharedPreferences
│   │   ├── home_screen.dart            # Dashboard, quick stats, greeting, action buttons
│   │   ├── checkin_screen.dart         # 3-step wizard: GPS → QR → Reflection Form
│   │   ├── finish_class_screen.dart    # 3-step wizard: QR → GPS → Feedback Form
│   │   ├── qr_scanner_screen.dart      # Camera with animated scan overlay
│   │   ├── history_screen.dart         # Session list with swipe-to-delete + detail sheet
│   │   └── profile_screen.dart         # Student profile with stats + mood distribution
│   └── widgets/
│       ├── glass_card.dart             # GlassCard, GradientButton, MoodSelector, AnimatedInfoTile
│       └── app_notification.dart       # Premium animated alert systems
├── android/
│   └── app/src/main/AndroidManifest.xml   # Camera + GPS + Internet permissions
├── README.md
├── PRD.md
├── AI_USAGE.md
└── pubspec.yaml
```

---

## 📱 Screens

### 1. Login Screen
- Student ID and Name input fields
- Premium glassmorphism card design
- Session persisted with SharedPreferences

### 2. Home Screen
- **Personalized greeting** with student name (Good Morning/Afternoon/Evening)
- **Quick Stats Row** — 3 mini cards: Total Sessions, Completed, Avg Mood
- Live session **status card** with pulsing indicator
- Gradient **"Check-in"** and **"Finish Class"** buttons
- **Today's activity** timeline with session count badge
- **Profile**, **History**, **About**, and **Logout** action buttons

### 3. Check-in Screen (3-Step Wizard)
```
Step 1: GPS     →    Step 2: QR Code    →    Step 3: Reflection Form
(Get location)       (Scan QR code)          (Previous topic, Expected topic, Mood 1-5)
```

### 4. Finish Class Screen (3-Step Wizard)
```
Step 1: QR Code    →    Step 2: GPS     →    Step 3: Feedback Form
(Scan QR code)          (Get location)       (What learned, Understanding 1-5, Feedback)
```

### 5. QR Scanner
- Full-camera view with dark overlay
- Animated **cyan scan line** moving up and down
- Custom **corner decorations** painted with Canvas API

### 6. History Screen
- Session cards showing date, check-in/out time, status badge, mood emoji
- **Swipe left to delete** with confirmation dialog (deletes from SQLite + Firestore)
- Tap card → **bottom sheet** with full session details (all 17 fields)

### 7. Profile Screen
- Student avatar with initials, name, and ID badge
- **Attendance Rate** — completion percentage with animated progress bar
- **Stats Grid** — Total sessions, Streak, Avg Mood, Avg Understanding
- **Mood Distribution** — visual bar chart of all mood ratings
- App info section (version, course, framework)

---

## 🗄️ Data Model

All data is stored with 17 fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | String (UUID) | Unique session identifier |
| `studentId` | String | Student identifier |
| `checkInTime` | DateTime | Timestamp of check-in |
| `checkInLatitude` | Double | GPS latitude at check-in |
| `checkInLongitude` | Double | GPS longitude at check-in |
| `qrCodeData` | String | QR code content at check-in |
| `previousTopic` | String | What was covered last class |
| `expectedTopic` | String | What student expects to learn |
| `moodBefore` | Int (1–5) | Mood rating before class |
| `checkOutTime` | DateTime? | Timestamp of check-out |
| `checkOutLatitude` | Double? | GPS latitude at check-out |
| `checkOutLongitude` | Double? | GPS longitude at check-out |
| `qrCodeDataOut` | String? | QR code content at check-out |
| `learnedToday` | String? | What the student learned |
| `understandingRating` | Int? (1–5) | Understanding rating after class |
| `feedback` | String? | Feedback for instructor |
| `createdAt` | DateTime | Record creation timestamp |

---

## 🚀 Setup & Installation

### Prerequisites

- Flutter SDK 3.x+
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)
- Firebase account (for cloud features)

### 1. Clone & Install

```bash
git clone https://github.com/Dechawat-Wetprasit/smart-class-app-midterm.git
cd smart_class_app
flutter pub get
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com) → **Create Project**
2. Add **Android App** → Package name: `com.smartclass.smart_class_app`
3. Download `google-services.json` → place in `android/app/`
4. Add **Web App** → copy Firebase config into `web/index.html`
5. In Firebase Console → **Firestore Database** → Create database (production mode)

> ⚠️ Without `google-services.json`, the app still works with local SQLite storage. Firebase sync will be skipped gracefully.

### 3. Run the App

```bash
# Run on connected Android device / emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome
```

### 4. Required Android Permissions

The following permissions are already configured in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## ☁️ Firebase Hosting Deployment

```bash
# Step 1: Build Flutter Web
flutter build web

# Step 2: Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Step 3: Login & Initialize
firebase login
firebase init hosting
# → Public directory: build/web
# → Single-page app: Yes
# → Overwrite index.html: No

# Step 4: Deploy
firebase deploy --only hosting
```

**Live URL:** `https://smart-class-app-5eaab.web.app`

---

## 🔄 User Flow

```
┌──────────────────────────────────────────────────────┐
│                   Login Screen                       │
│           [Student ID]  [Name]  [Continue]           │
└──────────────────────┬───────────────────────────────┘
                       │
┌──────────────────────▼───────────────────────────────┐
│                     Home Screen                      │
│     [Quick Stats] [Status] [Check-in] [Finish Class] │
└──────────────┬──────────────────┬────────────────────┘
               │                  │
    ┌──────────▼──────┐  ┌────────▼──────────┐
    │  Check-in Flow  │  │  Finish Class Flow │
    │ 1. Get GPS      │  │ 1. Scan QR Code    │
    │ 2. Scan QR Code │  │ 2. Get GPS         │
    │ 3. Fill Form:   │  │ 3. Fill Form:      │
    │  • Prev topic   │  │  • Learned today   │
    │  • Exp topic    │  │  • Understanding   │
    │  • Mood (1-5)   │  │  • Feedback        │
    │ 4. Save → DB    │  │ 4. Update → DB     │
    └────────┬────────┘  └────────┬───────────┘
             │                    │
    ┌────────▼────────────────────▼───────────┐
    │        SQLite (Local)  +  Firestore     │
    └─────────────────────────────────────────┘
```

---

## 🧪 Code Quality

- **0 errors** from `flutter analyze`
- Clean layered architecture: Models → Services → Screens → Widgets
- Async/await with proper error handling and `mounted` checks
- Graceful Firebase fallback — app works offline via SQLite
- Firestore supports full CRUD (create, read, update, delete)

---

## 📄 License

Created for **1305216 Mobile Application Development** — Midterm Exam, March 2026.
