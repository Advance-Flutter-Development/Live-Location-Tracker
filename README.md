# Live Location Tracker — Step 6: Live GPS Tracking

Flutter + Cubit | Android foreground tracking

## What we completed

- **Start Tracking** subscribes to live GPS updates.
- The map marker and latitude/longitude update as the device moves.
- The camera follows new GPS positions.
- **Stop Tracking** cancels the GPS subscription.
- Added a custom **Recenter** button above the tracking controls and removed the duplicate **Current** button.
- Fixed blank Google Maps tiles by configuring the API key through local Android settings.

> **Scope:** Tracks while the app is open. No route lines, distance totals, SQLite history, or background tracking yet.

## Tech stack / packages

| Tool | Why we use it |
|---|---|
| Flutter + Dart | Android app and UI |
| `flutter_bloc` (Cubit) | Tracking state and UI updates |
| `equatable` | Compare state values |
| `geolocator` | GPS permission, one-time position, live position stream |
| `google_maps_flutter` | Map, marker, and camera movement |
| Android Gradle + Google Maps SDK | Configure the Android Maps API key |

SQLite (`sqflite`) is planned for a later step; it is **not used for saving history in Step 6**.

## Files changed

```text
lib/
└── features/location/
    ├── data/
    │   ├── datasources/
    │   │   └── location_service.dart       # GPS stream settings
    │   └── repositories/
    │       └── location_repository.dart    # Exposes stream + permission check
    └── presentation/
        ├── cubit/
        │   ├── location_cubit.dart         # Start, listen, stop, cancel
        │   └── location_state.dart         # isTracking + position + status
        └── pages/
            └── location_page.dart          # Map, buttons, recenter, listener

android/
├── local.properties                        # Local API key; never commit
├── app/build.gradle.kts                    # Reads key into manifest placeholder
└── app/src/main/AndroidManifest.xml        # Maps API metadata + GPS permissions
```

## Simple flow

```text
Tap Start Tracking
       ↓
LocationPage → LocationCubit → LocationRepository
                                      ↓
                              LocationService
                                      ↓
                         Geolocator position stream
                                      ↓
                    New Position (lat, lng, accuracy)
                                      ↓
                       Cubit emits LocationState
                                      ↓
                   BlocConsumer rebuilds marker/UI
                   Listener moves the map camera

Tap Stop Tracking → cancel StreamSubscription → no more updates
```

### Which file does what?

| File | Simple explanation |
|---|---|
| `location_service.dart` | Uses `Geolocator.getPositionStream()` with high accuracy and `distanceFilter: 10` |
| `location_repository.dart` | Passes GPS stream and permission operations to Cubit |
| `location_cubit.dart` | Starts/stops the stream and emits positions |
| `location_state.dart` | Holds `position`, `status`, `errorMessage`, and `isTracking` |
| `location_page.dart` | Shows map, marker, status, buttons, and moves camera |

## Key code to remember

**GPS stream (service)**

```dart
Stream<Position> getLiveLocationStream() {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );
}
```

**Listen and update (Cubit)**

```dart
_positionSubscription = repository.getLiveLocationStream().listen(
  (position) {
    if (isClosed) return;
    emit(state.copyWith(
      status: LocationStatus.success,
      position: position,
      isTracking: true,
    ));
  },
  onError: (error) {
    // Handle the error and stop tracking.
  },
);
```

**Stop and clean up (Cubit)**

```dart
await _positionSubscription?.cancel();
_positionSubscription = null;
```

Also cancel the subscription in Cubit's `close()` method.

**UI (BlocConsumer)**

- `builder`: marker, location details, tracking status, enabled/disabled buttons.
- `listener`: show errors and move the camera when the position changes.
- Custom recenter button: while tracking, move to latest position; otherwise request a new one through Cubit.
- Set `myLocationButtonEnabled: false` to hide the built-in Google Maps button.

## Android Maps key setup (local development)

1. In **Google Cloud Console**, enable billing and **Maps SDK for Android**.
2. Create an API key. Restrict it to your Android application ID + signing SHA-1 and Maps SDK for Android.
3. Put this in `android/local.properties` (keep existing entries):

```properties
MAPS_API_KEY=YOUR_KEY_HERE
```

4. Add this code inside android/app/build.gradle.kts in the top:

```dart
import java.util.Properties
import java.io.FileInputStream

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use {
        localProperties.load(it)
    }
}
```

5. In `android/app/build.gradle.kts`, load `local.properties` and set `manifestPlaceholders["MAPS_API_KEY"]` to the property value.
6. Inside `<application>` in `AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="${MAPS_API_KEY}" />
```

7. Keep `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` permissions in the manifest.
8. Confirm `android/local.properties` is ignored by Git. **Never commit your key.**
9. After changing native settings, rebuild (`flutter run`), not just hot reload.

## Quick test checklist

- [ ] Map tiles load (not a blank beige screen).
- [ ] Location permission is granted and GPS is on.
- [ ] **Start Tracking** changes status to **Tracking Active**.
- [ ] Moving outdoors produces new GPS positions and marker updates.
- [ ] Map camera follows new positions.
- [ ] Custom **Recenter** button moves camera to current/latest position.
- [ ] **Stop Tracking** stops GPS updates.
- [ ] No further updates arrive after leaving the page / Cubit disposal.

## Troubleshooting

| Issue | Quick check |
|---|---|
| Blank map | Verify API key, Android package/SHA-1 restrictions, billing, and internet |
| GPS times out | Check precise-location permission; try medium accuracy / longer timeout for one-time GPS |
| No movement updates | `distanceFilter: 10` requests updates after movement; try outdoors and move more than 10 m |
| Recenter uses an old position | When tracking is stopped, fetch a new position; when tracking, use latest state |

**Note:** GPS accuracy is approximate; `distanceFilter` is not a fixed timer or an exact guarantee. The earlier one-time GPS fix used `LocationAccuracy.medium` and a 30-second timeout; the Step 6 stream requests `high` accuracy.

## Next step

**Step 7:** Draw route polylines on Google Maps and calculate traveled distance. Save sessions in SQLite in a later step.
