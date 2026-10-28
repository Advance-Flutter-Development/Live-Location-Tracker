# Live Location Tracker 📍

A Flutter practice project to **show current GPS location on Google Maps, track movement, and save location history**.

> **Goal:** Learn Cubit, GPS integration, Google Maps, SQLite, and clean project organization.  
> **Scope (v1):** Android foreground tracking only. Background tracking is not included.

## Features (planned)

- Ask for location permission and check whether GPS is enabled.
- Show current latitude/longitude on Google Maps.
- Start/stop live location tracking.
- Draw the traveled route and calculate distance.
- Save tracking sessions locally and view history.
- Handle permission errors and allow users to delete history.

## Tech stack

| Technology / package | Why we use it |
| --- | --- |
| Flutter + Dart | Build the mobile app |
| `flutter_bloc` (Cubit) | Manage location and tracking state |
| `equatable` | Compare states easily |
| `geolocator` | Get GPS position, location stream, and permissions |
| `google_maps_flutter` | Display map, markers, and route polyline |
| `sqflite` + `path` | Save location history on the device |
| `intl` | Format dates and times |
| `permission_handler` | Optional; Geolocator already handles basic location permissions |

**No backend or Firebase is needed for v1.** Google Maps requires a configured Maps SDK for Android API key and Google Cloud billing setup.

## Folder structure

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   └── utils/
└── features/
    └── location/
        ├── data/
        │   ├── models/
        │   │   └── location_point_model.dart
        │   ├── datasources/
        │   │   ├── location_service.dart
        │   │   └── location_database.dart
        │   └── repositories/
        │       └── location_repository.dart
        └── presentation/
            ├── cubit/
            │   ├── location_cubit.dart
            │   └── location_state.dart
            ├── pages/
            │   ├── location_page.dart
            │   └── history_page.dart
            └── widgets/
                ├── tracking_controls.dart
                └── location_info_card.dart
```

> This is the **planned structure**. Create files as features are implemented.

## What each folder/file does

| Folder / file | Simple explanation |
| --- | --- |
| `main.dart` | Starts the app and provides Cubit/dependencies. |
| `core/constants/` | Shared constants, e.g. app settings. |
| `core/utils/` | Shared helpers, e.g. distance formatting. |
| `data/models/location_point_model.dart` | Shape of one GPS point: latitude, longitude, time. |
| `data/datasources/location_service.dart` | Talks directly to Geolocator (GPS). |
| `data/datasources/location_database.dart` | Talks directly to SQLite (save/read/delete). |
| `data/repositories/location_repository.dart` | One place Cubit calls for location/history operations. |
| `presentation/cubit/location_cubit.dart` | Handles actions: start, stop, get location; emits states. |
| `presentation/cubit/location_state.dart` | Holds current UI data: coordinates, tracking status, errors. |
| `presentation/pages/location_page.dart` | Main Google Maps screen. |
| `presentation/pages/history_page.dart` | Shows saved tracking sessions. |
| `presentation/widgets/tracking_controls.dart` | Reusable Start/Stop buttons. |
| `presentation/widgets/location_info_card.dart` | Displays coordinates, distance, etc. |

### Remember these three layers

- **Presentation:** What the user sees + Cubit state.
- **Repository:** The middle layer Cubit talks to.
- **Data sources:** Actual GPS and database calls.

## How data flows

When the user taps **Start Tracking**:

```text
location_page.dart (button tapped)
        ↓
location_cubit.dart (startTracking)
        ↓
location_repository.dart
        ↓
location_service.dart (GPS stream)
        ↓
location_cubit.dart (emit new LocationState)
        ↓
BlocBuilder updates map and coordinates
```

To save history, the repository also uses `location_database.dart`.

## GetX → Cubit quick reference

| In GetX | In this project |
| --- | --- |
| `GetxController` | `Cubit<LocationState> (OR) location_cubit.dart` |
| `.obs` / `Rx` variables | Fields in `LocationState (OR) location_state.dart` |
| Update `.value` | `emit(newState)` |
| `Obx()` | `BlocBuilder` |
| `Get.put()` | `BlocProvider` |
| `Get.find()` | `context.read<T>()` (inside provider scope) |
| Side effects/snackbars | `BlocListener (action)` |

These are **similar roles**, not exact equivalents.

**Cubit reminders:**
- `BlocBuilder` → rebuild UI when state changes.
- `BlocListener` → one-time effects such as SnackBars/navigation.
- `BlocConsumer` → combines builder + listener.
- `emit()` → sends a new state; avoid mutating the old state.

## Setup

```bash
flutter pub get/fvm flutter pub get
flutter run/fvm flutter run
```

Before showing Google Maps, configure the **Maps SDK for Android API key**. Before reading GPS, configure Android location permissions and request them at runtime. Run on an Android device or emulator with location services available.

## Learning checklist

- [ ] Create Flutter project and install packages
- [ ] Configure Android location permissions
- [ ] Read current GPS location
- [ ] Build `LocationCubit` + `LocationState`
- [ ] Display location on Google Maps
- [ ] Start/stop live location updates
- [ ] Draw polyline and calculate distance
- [ ] Save points/sessions to SQLite
- [ ] Display and delete history
- [ ] Test errors, write README updates, push to GitHub

## One-line memory trick

**Page → Cubit → Repository → GPS/SQLite → Cubit emits State → UI rebuilds.**

*Note: This structure is a learning-friendly choice, not a requirement of BLoC. It can be simplified or expanded as the app grows.*
