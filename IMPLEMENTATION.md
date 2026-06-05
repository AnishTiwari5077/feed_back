# Flutter User Feedback Application — Implementation Document

**Candidate:** Anish Tiwari
**Email:** anishtiwari5077@gmail.com
**GitHub:** github.com/AnishTiwari5077
**Submission To:** info@remoteward.com

---

## 1. Project Overview

Design and develop a User Feedback Collection Application using the Flutter framework. The app allows a device owner to authenticate via Google Sign-In, collect structured user feedback (including descriptions and media), and securely export this data as a CSV file.

---

## 2. Architecture — BLoC (Business Logic Component)

As required, all UI elements react to BLoC-managed events and state changes using the `flutter_bloc` package.

### Folder Structure

```
lib/
├── core/
│   ├── di/
│   │   └── injection.dart            # get_it dependency injection
│   ├── database/
│   │   └── database_service.dart     # dedicated SQLite service layer
│   └── constants/
│       └── app_constants.dart
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── screens/
│   │       └── login_screen.dart       # Screen 1
│   ├── user_details/
│   │   ├── bloc/
│   │   │   ├── user_details_bloc.dart
│   │   │   ├── user_details_event.dart
│   │   │   └── user_details_state.dart
│   │   └── screens/
│   │       └── user_details_screen.dart  # Screen 2
│   ├── bug_description/
│   │   ├── bloc/
│   │   │   ├── bug_bloc.dart
│   │   │   ├── bug_event.dart
│   │   │   └── bug_state.dart
│   │   └── screens/
│   │       └── bug_description_screen.dart  # Screen 3
│   ├── media_collection/
│   │   ├── bloc/
│   │   │   ├── media_bloc.dart
│   │   │   ├── media_event.dart
│   │   │   └── media_state.dart
│   │   └── screens/
│   │       └── media_collection_screen.dart  # Screen 4
│   ├── thank_you/
│   │   └── screens/
│   │       └── thank_you_screen.dart         # Screen 5
│   └── export/
│       ├── bloc/
│       │   ├── export_bloc.dart
│       │   ├── export_event.dart
│       │   └── export_state.dart
│       └── services/
│           └── csv_export_service.dart
└── main.dart
```

---

## 3. Tech Stack & Packages

| Requirement (from assignment) | Package Used |
|---|---|
| State Management — BLoC | `flutter_bloc` |
| Google Sign-In + Firebase Auth | `google_sign_in` + `firebase_auth` |
| Local SQL Database | `sqflite` (with option to use `drift`) |
| Dedicated Database Service Layer | Custom `DatabaseService` class |
| Dependency Injection via get_it | `get_it` |
| Media files — images/videos | `image_picker` |
| Scoped Storage (Downloads folder) | `media_store_plus` |
| CSV file generation | `csv` |
| Biometric/password authentication | `local_auth` |
| Smooth navigation & transitions | `go_router` |
| Animations | Flutter built-in `AnimationController` + `animations` package |

---

## 4. App Flow — Exactly 5 Screens (as specified)

```
┌──────────────────────┐
│  1. Google Login     │  Device owner logs in via Google
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  2. User Details     │  Collect name, email, contact of
│                      │  the person submitting feedback
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  3. Bug Description  │  Entry of detailed bug/issue
│                      │  description encountered
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  4. Media Collection │  Attach screenshots, images,
│                      │  or videos related to the issue
└──────────┬───────────┘
           ↓
┌──────────────────────┐
│  5. Thank You        │  Displays thank-you message
│                      │  Auto-redirects → Screen 2
│                      │  to accept another entry
└──────────────────────┘
```

---

## 5. Functional Requirements — Implementation

### 5.1 User Interface (UI/UX)

- Clean, professional, and animated UI inspired by modern trends on **mobbin.com**
- Intuitive and minimal design with smooth navigation and transitions between all 5 screens
- Animated form field focus states, hero transitions, slide-up bottom sheets
- Lottie success animation on the Thank You screen

### 5.2 Authentication — Google Sign-In + Firebase

Only the authenticated device owner can use the app to collect feedback.

**BLoC Events:**
```dart
abstract class AuthEvent {}
class GoogleSignInRequested extends AuthEvent {}
class SignOutRequested extends AuthEvent {}
```

**BLoC States:**
```dart
abstract class AuthState {}
class AuthInitial    extends AuthState {}
class AuthLoading    extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

**Implementation:**
- `google_sign_in` triggers OAuth flow
- `firebase_auth` receives the Google credential and signs in
- On `AuthAuthenticated` state → navigate to User Details screen
- On `AuthError` → show SnackBar with retry

### 5.3 State Management — BLoC for ALL screens

Every UI element reacts to BLoC-managed events and state changes:

| Screen | BLoC | Responsibility |
|---|---|---|
| Login | `AuthBloc` | Google sign-in, auth state |
| User Details | `UserDetailsBloc` | Form validation, save to DB |
| Bug Description | `BugBloc` | Text input, validation, save |
| Media Collection | `MediaBloc` | File pick, storage, removal |
| Export | `ExportBloc` | Biometric auth, CSV generation |

### 5.4 Data Persistence — Local SQL Database

Using **sqflite** with a **dedicated database service layer** as required.

**SQLite Schema:**
```sql
CREATE TABLE feedback (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  device_owner TEXT NOT NULL,   -- authenticated Google user email
  name         TEXT NOT NULL,   -- user details: name
  email        TEXT NOT NULL,   -- user details: email
  contact      TEXT NOT NULL,   -- user details: contact
  bug_issue    TEXT NOT NULL,   -- bug/issue title or summary
  user_device  TEXT,            -- device model (auto-detected)
  description  TEXT NOT NULL,   -- detailed bug description
  media_links  TEXT,            -- comma-separated scoped storage URIs
  created_at   TEXT NOT NULL
);
```

**Dedicated DatabaseService layer:**
```dart
class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'feedback.db');
    return openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_owner TEXT NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        contact TEXT NOT NULL,
        bug_issue TEXT NOT NULL,
        user_device TEXT,
        description TEXT NOT NULL,
        media_links TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertFeedback(FeedbackModel feedback) async {
    final db = await database;
    return db.insert('feedback', feedback.toMap());
  }

  Future<List<FeedbackModel>> getAllFeedback() async {
    final db = await database;
    final maps = await db.query('feedback');
    return maps.map((m) => FeedbackModel.fromMap(m)).toList();
  }
}
```

**Dependency Injection via get_it:**
```dart
// core/di/injection.dart
final getIt = GetIt.instance;

void setupDI() {
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<CsvExportService>(
    () => CsvExportService(getIt<DatabaseService>()),
  );
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupDI();
  runApp(const MyApp());
}
```

### 5.5 Scoped Storage

Media files (images/videos) and the exported CSV file stored in the Downloads folder using `media_store_plus`:

```dart
// Saving media file to scoped storage
final result = await MediaStore().saveFile(
  tempFilePath: localFilePath,
  dirType: DirType.download,
  dirName: DirName.download,
);
```

---

## 6. Data Export Requirements — Exact CSV Format

**CSV columns exactly as specified in assignment:**

| Device Owner | User Details | Bug/Issue | User Device | Description and Media Links |
|---|---|---|---|---|
| Google account email of device owner | Name, Email, Contact | Bug title/issue summary | Device model + OS | Full description + media file URIs |

**Export flow:**
```
1. Device owner taps "Export CSV" button
2. local_auth triggers biometric (fingerprint) or password authentication
3. On success → DatabaseService.getAllFeedback()
4. Convert List<FeedbackModel> to CSV using ListToCsvConverter
5. Save CSV to Downloads folder via media_store_plus (scoped storage)
6. Show success SnackBar with file location
```

**Biometric / password authentication before export:**
```dart
final LocalAuthentication _auth = LocalAuthentication();

Future<bool> authenticateOwner() async {
  final bool canAuthenticate =
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  if (!canAuthenticate) return false;

  return await _auth.authenticate(
    localizedReason: 'Authenticate to export feedback data',
    options: const AuthenticationOptions(
      biometricOnly: false, // allows password/PIN fallback
      stickyAuth: true,
    ),
  );
}
```

**CSV generation:**
```dart
class CsvExportService {
  final DatabaseService _db;
  CsvExportService(this._db);

  Future<String> exportToCSV() async {
    final feedbackList = await _db.getAllFeedback();

    final rows = <List<dynamic>>[
      // Header row — exact columns from assignment
      ['Device Owner', 'User Details', 'Bug/Issue', 'User Device', 'Description and Media Links'],
      // Data rows
      ...feedbackList.map((f) => [
        f.deviceOwner,
        '${f.name} | ${f.email} | ${f.contact}',
        f.bugIssue,
        f.userDevice ?? 'Unknown',
        '${f.description} | Media: ${f.mediaLinks ?? 'None'}',
      ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);

    // Save to scoped storage Downloads folder
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/feedback_export.csv');
    await tempFile.writeAsString(csv);

    await MediaStore().saveFile(
      tempFilePath: tempFile.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    return 'feedback_export.csv saved to Downloads';
  }
}
```

---

## 7. Screen-by-Screen Detail

### Screen 1 — Google Login
- Animated app logo on load
- "Sign in with Google" button
- Only authenticated device owner proceeds
- Firebase Auth persists login session

### Screen 2 — User Details
- Fields: Full Name, Email, Contact (all required, validated)
- Device info auto-detected via `device_info_plus`
- BLoC validates form before saving to SQLite
- "Next" navigates to Bug Description

### Screen 3 — Bug Description
- Fields: Bug/Issue title + detailed multiline description
- Character counter on description field
- BLoC manages validation and state
- "Next" saves to SQLite and navigates to Media Collection

### Screen 4 — Media Collection
- Attach screenshots, images, or videos via `image_picker`
- Camera or Gallery source selection
- Preview thumbnails with individual remove buttons
- Files saved to scoped storage via `media_store_plus`
- "Submit" saves media URIs to DB and navigates to Thank You

### Screen 5 — Thank You
- Animated success checkmark (Lottie)
- "Feedback submitted successfully" message
- **Auto-redirects back to User Details screen** (Screen 2)
  to accept another entry — exactly as specified
- Timer: 3 seconds before auto-redirect

---

## 8. Design Choices

- **BLoC over Riverpod/Provider** — assignment specifically required `flutter_bloc`
- **sqflite over Hive** — assignment specified "local SQL database"
- **get_it for DI** — assignment specifically mentioned `get_it`
- **media_store_plus** — best package for scoped storage Downloads folder on Android API 29+
- **biometricOnly: false** — allows password fallback as specified ("fingerprint/password authentication")
- **Features-first folder structure** — scales well, keeps each screen self-contained

---

## 9. Challenges & Solutions

| Challenge | Solution |
|---|---|
| BLoC state shared across 5 screens | `FeedbackCubit` accumulates form data; committed to DB only on final Submit |
| Scoped storage differs by Android API | `media_store_plus` handles API 29+ automatically |
| Biometric not available on all devices | `biometricOnly: false` falls back to device PIN/password |
| CSV special characters (commas, newlines) | `ListToCsvConverter` from `csv` package handles escaping |
| Auto-redirect from Thank You to Screen 2 | `Future.delayed(3s)` then `context.go('/user-details')` via GoRouter |
| Media URIs after scoped storage | Store content URI strings in SQLite, resolve at export time |

---

## 10. Potential Improvements (Given More Time)

1. **Firebase Firestore backup** — cloud sync of all feedback data
2. **Analytics dashboard** — charts showing bugs by severity/device/date
3. **PDF export** — in addition to CSV
4. **Multiple device owners** — role-based access control
5. **Offline queue** — submit feedback offline, sync when connected
6. **Search and filter** — filter feedback list by date, severity, device
7. **Unit + Widget tests** — BLoC unit tests, screen widget tests
8. **Export history** — log of all previous CSV exports with timestamps

---

## 11. Submission Checklist

- [x] GitHub repo with full source code
- [x] This IMPLEMENTATION.md in repo root
- [x] All 5 screens implemented in specified flow
- [x] Google Sign-In via Firebase Authentication
- [x] BLoC architecture throughout
- [x] SQLite with dedicated DatabaseService layer
- [x] get_it dependency injection
- [x] Scoped storage for media and CSV
- [x] Biometric/password authentication before export
- [x] CSV format matches exact columns from assignment
- [x] Thank You screen auto-redirects to User Details

**Email to:** info@remoteward.com
**GitHub:** github.com/AnishTiwari5077/flutter-feedback-app

---

*Anish Tiwari — Flutter Developer*
*anishtiwari5077@gmail.com | +977 9861982615*
