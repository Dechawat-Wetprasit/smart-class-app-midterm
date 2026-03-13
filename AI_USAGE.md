# AI Usage Report

**Project:** Smart Class Check-in & Learning Reflection App  
**Course:** 1305216 Mobile Application Development — Midterm Exam

---

## 1. AI Tools Used

| Tool | Provider | Purpose |
|------|----------|---------|
| **Claude (Anthropic)** | Anthropic | Primary AI assistant for code generation and architecture planning |

---

## 2. What AI Helped Generate

### 2.1 Architecture & Planning
- Defined the layered folder structure: `models/` → `services/` → `screens/` → `widgets/`
- Designed the data model with 17 fields matching the PRD requirements
- Suggested the SQLite-first + Firebase-sync pattern for offline support

### 2.2 Data Layer
- **`checkin_record.dart`** — Data class with `toMap()` / `fromMap()` serialization for both SQLite and Firestore
- **`database_helper.dart`** — Full SQLite CRUD implementation using `sqflite`, including methods for active session detection, today's records filter, and delete
- **`firestore_service.dart`** — Firebase Firestore integration with graceful failure handling and full CRUD support (save, update, delete)

### 2.3 Service Layer
- **`location_service.dart`** — GPS location retrieval with full permission request flow (denied, denied forever, service disabled cases)

### 2.4 UI & Screens
- **`app_theme.dart`** — Premium dark glassmorphism design system with gradient definitions and Material `ThemeData` configuration
- **`glass_card.dart`** — Reusable `GlassCard` (BackdropFilter blur effect), `GradientButton` (scale press animation), `MoodSelector` (animated emoji picker), `AnimatedInfoTile`
- **`login_screen.dart`** — Student login with SharedPreferences session persistence
- **`home_screen.dart`** — Dashboard with personalized greeting, Quick Stats row (total/completed/avg mood), pulsing animated status card, gradient action buttons, today's activity list, and About dialog
- **`checkin_screen.dart`** — 3-step animated wizard (GPS → QR → Form) with step indicator, form validation, and success dialog
- **`finish_class_screen.dart`** — 3-step animated wizard (QR → GPS → Feedback) mirroring check-in flow
- **`qr_scanner_screen.dart`** — Camera view with custom dark overlay, animated scan line, and `Canvas`-painted corner decorations
- **`history_screen.dart`** — Session list with swipe-to-delete (Dismissible widget), confirmation dialog, and detail bottom sheet showing all 17 data fields
- **`profile_screen.dart`** — Student profile with session statistics (total, completed, streak, avg mood, avg understanding), attendance rate progress bar, and mood distribution bar chart

### 2.5 Documentation
- `PRD.md`: Problem statement, feature list (35 features), user flow, data fields, tech stack, architecture diagram
- `README.md`: Project setup, architecture diagrams, data model tables, deployment guide, screen descriptions

---

## 3. What I Reviewed, Modified, and Implemented Myself

| Task | My Contribution |
|------|----------------|
| **Understanding Requirements** | Interpreted the incomplete draft requirements from the exam, defined missing data fields (understandingRating, qrCodeDataOut), and decided the WiFi + GPS + QR combination |
| **Android Permissions** | Manually added Camera, GPS, and Internet permissions to `AndroidManifest.xml` |
| **Form Validation Logic** | Verified all form validators — required fields, mood selection guard, understanding rating guard |
| **Flutter SDK Setup** | Installed Flutter SDK from scratch, resolved PATH issues, ran `flutter doctor` |
| **Dependency Resolution** | Reviewed the 76 dependencies, confirmed compatibility with Flutter 3.41.4 / Dart 3.11.1 |
| **Code Review** | Read and traced through all generated code to verify correctness — identified and fixed unused `_isLoading` field, replaced `print` with `debugPrint`, removed unused imports |
| **Error Handling** | Added `mounted` checks on async setState calls to prevent widget lifecycle bugs |
| **Firebase Fallback** | Implemented the try/catch pattern in `FirestoreService` so the app works with just SQLite when Firebase is not configured |
| **Deployment** | Firebase project creation, `google-services.json` placement, `flutter build web`, Firebase Hosting configuration |
| **Testing** | Ran the app on emulator, tested each screen flow manually, validated data persistence in SQLite |
| **Feature Planning** | Planned and reviewed new v1.1 features (Profile, Quick Stats, Swipe-to-Delete, About, Greeting) |

---

## 4. Reflection on AI-Assisted Development

Using AI as a coding assistant significantly accelerated development while requiring active engineering judgment throughout:

- **Productivity gain:** Writing 1000+ lines of Flutter across 12 files in one session would have taken 3–4x longer manually.
- **Critical review was essential:** The AI-generated code required verification — unused variables, missing `mounted` checks, and import cleanup all needed manual fixes.
- **Architecture decisions were mine:** I guided the AI with the specific requirements, chose SQLite-first over pure Firestore, and structured the 3-step wizard flow based on my understanding of the UX.
- **Understanding code I didn't type:** I can explain every function in the codebase — from how `BackdropFilter.blur` creates the glass effect, to why `ConflictAlgorithm.replace` is used in SQLite inserts, to how the `CustomPainter` draws QR scanner corners.
- **Iterative enhancement:** The v1.1 features (Profile stats, swipe-to-delete, mood distribution) were planned based on real UX improvements I identified after testing the v1.0 MVP.

> The exam rubric states: *"AI used effectively and student demonstrates clear understanding of generated code."*  
> My approach: Use AI to scaffold quickly, then own the code completely through review, testing, and debugging.
