# 📍 Flutter Live Location Tracker

## Step 7 — Live GPS Route Tracking & Distance Calculation

A Flutter application that tracks a user's real-time GPS location, visualizes the traveled route on Google Maps, and calculates the total distance traveled using **Cubit state management**.

### ✅ Status: Completed

Step 7 was successfully tested outdoors while walking.

## 🚀 Features

- **Live Location Tracking:** Receive continuous GPS location updates using Geolocator.
- **Google Maps Integration:** Display the user's current location on an interactive map.
- **Route Polyline:** Draw the traveled path using `LatLng` coordinates.
- **Distance Calculation:** Calculate the total distance traveled in meters.
- **GPS Accuracy Filtering:** Reject readings with poor estimated accuracy.
- **GPS Drift Prevention:** Filter small or implausible location changes to reduce false route segments.
- **Start/Stop Tracking:** Control GPS stream subscriptions.
- **Recenter Map:** Move the camera to the current tracked position.
- **Satellite/Hybrid View:** Switch between different Google Maps display modes.
- **Compass Control:** Reset the map orientation toward north.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter & Dart | Mobile application development |
| Cubit (`flutter_bloc`) | State management |
| Geolocator | GPS location services |
| Google Maps Flutter | Maps and route visualization |
| Equatable | State equality |

## 📁 Project Architecture

```text
lib/
└── features/
    └── location/
        ├── data/
        │   ├── datasources/
        │   │   └── location_service.dart
        │   └── repositories/
        └── presentation/
            ├── cubit/
            │   ├── location_cubit.dart
            │   └── location_state.dart
            └── pages/
                └── location_page.dart
```

The project separates location services, repository logic, state management, and UI.

## ⚙️ How Tracking Works

1. The user taps **Start**.
2. The application checks location permissions.
3. Geolocator starts streaming GPS positions.
4. Incoming readings pass through accuracy and movement filters.
5. Accepted coordinates are added to `routePoints`.
6. Distance between accepted positions is calculated using `Geolocator.distanceBetween()`.
7. Cubit emits the updated location state.
8. Google Maps redraws the polyline and updates the distance.
9. The user taps **Stop** to cancel tracking.

## 🛰️ GPS Accuracy & Drift Filtering

GPS readings can fluctuate even when a device is stationary.

The application uses:

- Estimated horizontal GPS accuracy.
- Distance between consecutive accepted positions.
- Timestamp differences.
- Movement plausibility checks.

Readings that fail these checks are excluded from the recorded route.

**Note:** GPS filtering reduces unwanted route movements but cannot eliminate all GPS errors. It may also reject genuine small movements when location accuracy is poor.

## 🧪 Outdoor Testing Results

| Parameter | Result |
|---|---|
| Test environment | Outdoor |
| Activity | Walking |
| Reported GPS accuracy | 3.9 m |
| Recorded distance | 911.4 m |
| Route polyline | Working |
| Live GPS updates | Working |
| Cubit state updates | Working |

### Indoor vs. Outdoor Testing

**Indoor:** GPS accuracy frequently reported around 40 m or worse because buildings obstruct and reflect satellite signals.

**Outdoor:** GPS accuracy improved to below 10 m, producing a clear walking route.

The outdoor test demonstrated functional route tracking. The recorded distance has not been independently checked against a measured reference route.

## ▶️ Running the Project

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

### Prerequisites

- Flutter SDK
- Android device with location services
- Google Maps SDK configuration
- Restricted Google Maps API key
- Android location permissions

Do not commit API keys or sensitive local configuration files to Git.

## 📌 Limitations

Step 7 supports foreground GPS route tracking.

It does not yet implement road-based directions, destination search, estimated arrival time, background location tracking, or persistent route history.

## 🗺️ Future Roadmap

| Step | Feature | Status |
|---|---|---|
| 7 | Live GPS Route Tracking | ✅ Completed |
| 8 | Location Search & Autocomplete | Upcoming |
| 9 | Directions, Distance & Duration | Planned |
| 10 | Turn-by-Turn Navigation | Planned |
| 11 | Background Location Tracking | Planned |
| 12 | Picture-in-Picture Navigation | Planned |
| 13 | SQLite Tracking History | Planned |
| 14 | CI/CD Deployment with Codemagic | Planned |

## 🎯 Learning Outcomes

Through Step 7, this project demonstrates practical experience with:

- Flutter location-based services (LBS)
- GPS position streams
- Cubit state management
- Google Maps SDK
- Latitude and longitude (`LatLng`)
- Route polylines
- Geospatial distance calculations
- GPS accuracy and drift handling
- Asynchronous stream subscriptions

---

**Project:** Flutter Live Location Tracker  
**Milestone:** Step 7 — Completed  
**Next:** Step 8 — Location Search & Autocomplete
