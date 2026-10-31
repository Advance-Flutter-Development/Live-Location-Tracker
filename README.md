# Live Location Tracker — Step 5: Google Maps Integration

> **Branch:** Step 5 — Google Maps + Cubit  
> **Goal:** Display Google Maps, fetch the phone's current GPS position, and move the map to that location.

## 1. Tech Stack & Packages

| Technology / Package | Use |
|---|---|
| Flutter + Dart | Android app and UI |
| `flutter_bloc` | Cubit state management and `BlocConsumer` |
| `equatable` | Compare location states |
| `geolocator` | Location permissions and current GPS position |
| `google_maps_flutter` | Google Map, marker, and camera movement |
| Google Cloud Console | Configure Maps SDK for Android and API key |

> Other packages installed for future steps (such as `sqflite`, `path`, and `intl`) are **not used in Step 5**.

## 2. What We Completed

- [x] Displayed Google Maps inside `location_page.dart`.
- [x] Configured Google Maps API key for Android.
- [x] Kept the existing location permission checks.
- [x] Fetched latitude, longitude, and accuracy through Cubit.
- [x] Added a marker at the fetched location.
- [x] Animated the map camera to the current location.
- [x] Used `BlocConsumer` to show loading, success, and error feedback.
- [x] Resolved a GPS timeout during testing by using medium accuracy and a longer timeout.

**Not implemented yet:** continuous movement tracking, route polylines, distance calculation, and SQLite history.

## 3. Simple Data Flow

```text
User taps "Get Current Location"
              |
              v
      location_page.dart
              |
              v
      location_cubit.dart
       (loading state)
              |
              v
    location_repository.dart
              |
              v
      location_service.dart
       (Geolocator GPS)
              |
              v
      location_cubit.dart
       emit(success/error)
              |
              v
      BlocConsumer in page
         /          \
   listener        builder
   moves map       draws marker,
   + SnackBar      coordinates, loader
```

**Remember:** `Cubit` manages location state. The page owns `GoogleMapController` to control the map camera.

## 4. Files Used / Changed

```text
lib/
├── main.dart                                # Provides LocationCubit
└── features/location/
    ├── data/
    │   ├── datasources/
    │   │   └── location_service.dart        # GPS permissions + getCurrentPosition()
    │   └── repositories/
    │       └── location_repository.dart     # Calls LocationService
    └── presentation/
        ├── cubit/
        │   ├── location_cubit.dart          # Loading / success / failure emits
        │   └── location_state.dart          # Status, Position, error message
        └── pages/
            └── location_page.dart           # GoogleMap, marker, camera, BlocConsumer

android/app/
├── build.gradle.kts                         # Maps API key manifest placeholder
└── src/main/AndroidManifest.xml             # Location permissions + Maps API key

pubspec.yaml                                 # google_maps_flutter dependency
```

| File | Step 5 change |
|---|---|
| `pubspec.yaml` | Added `google_maps_flutter` |
| `AndroidManifest.xml` | Added Google Maps API metadata; kept location permissions |
| `build.gradle.kts` | Reads `MAPS_API_KEY` environment variable for manifest placeholder |
| `location_page.dart` | Replaced coordinates-only screen with Google Map and marker |
| `location_service.dart` | Adjusted GPS accuracy and timeout during debugging |
| `main.dart`, Cubit, State, Repository | Reused the Step 4 implementation; no new logic required |

## 5. Google Cloud Console Setup

1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a project (e.g. **Live Location Tracker**).
3. Enable **billing** for the project.
4. Go to **APIs & Services → Library** and enable **Maps SDK for Android**.
5. Go to **APIs & Services → Credentials** and create an **API key**.
6. Restrict the key:
   - **Application restriction:** Android apps
   - Enter your Android **application ID** and **SHA-1** certificate fingerprint.
   - **API restriction:** Maps SDK for Android.
7. Set a billing budget/alerts and monitor usage.

### Find application ID

Open `android/app/build.gradle.kts` and find:

```kotlin
defaultConfig {
    applicationId = "com.example.live_location_tracker" // Example only
}
```

### Find debug SHA-1 (Windows)

From the project's `android` folder:

```cmd
cd android
gradlew signingReport
```

Use the **debug** SHA-1 for debug builds. Release signing certificates can have different SHA-1 values.

## 6. Android Configuration

### `android/app/src/main/AndroidManifest.xml`

Keep these inside `<manifest>` but **outside** `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Add this **inside** `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

Keep all existing Flutter activity and manifest entries.

### `android/app/build.gradle.kts`

Inside the existing `defaultConfig` block:

```kotlin
manifestPlaceholders["MAPS_API_KEY"] =
    System.getenv("MAPS_API_KEY") ?: ""
```

**Do not commit your actual API key.** Android Maps keys are bundled into the app, so Google Cloud application/API restrictions are important.

## 7. Run the App (Windows CMD)

From the project root:

```cmd
set "MAPS_API_KEY=YOUR_ACTUAL_API_KEY"
flutter pub get
flutter run
```

To verify the variable exists (avoid sharing the printed key):

```cmd
echo %MAPS_API_KEY%
```

**PowerShell alternative:**

```powershell
$env:MAPS_API_KEY="YOUR_ACTUAL_API_KEY"
flutter run
```

> CMD uses `set`; PowerShell uses `$env:`. The environment variable is temporary for that terminal session. If the Gradle daemon was started before setting it, stop the daemon (`cd android && gradlew --stop`) and rebuild.

## 8. GPS Timeout Fix

**Problem seen:**

```text
TimeoutException: Future not completed
```

**Working test configuration** in `location_service.dart`:

```dart
final position = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 30),
  ),
);
```

**Why it may help:** medium accuracy can return a location more quickly, and 30 seconds gives the device longer to obtain a fix. We changed both settings, so the exact cause of the earlier timeout is not confirmed.

For route tracking in Step 6, we will revisit accuracy and filter noisy readings.

## 9. Quick Test Checklist

- [ ] Map tiles load (not a blank map).
- [ ] Phone location service is ON.
- [ ] App location permission is granted (prefer **Precise** for testing).
- [ ] Tap **Get Current Location**.
- [ ] Loading indicator appears while fetching.
- [ ] Latitude, longitude, and accuracy appear.
- [ ] Map zooms to the current location and shows a marker.
- [ ] GPS/permission errors show a SnackBar.

## 10. Next Step

**Step 6 — Live Tracking:** `Geolocator.getPositionStream()`, `StreamSubscription<Position>`, Start/Stop buttons, and map updates while moving.

**Quick reminder:**

```text
Step 5 = One GPS position + Google Map
Step 6 = Continuous GPS positions + live map updates
```
