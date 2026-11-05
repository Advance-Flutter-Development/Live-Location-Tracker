import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/repositories/location_repository.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository locationRepository;

  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastAcceptedPosition;

  LocationCubit(this.locationRepository) : super(const LocationState());

  //Step5
  Future<void> getCurrentLocation() async {
    if (state.isTracking || state.status == LocationStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LocationStatus.loading));

    try {
      final position = await locationRepository.getCurrentLocation();

      if (isClosed) return;

      emit(state.copyWith(status: LocationStatus.success, position: position));
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  //Step6
  Future<void> startTracking() async {
    if (state.isTracking || state.status == LocationStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LocationStatus.loading, errorMessage: null));

    try {
      debugPrint("Checking location permission...");
      await locationRepository.checkLocationPermission();

      debugPrint("1");

      if (isClosed) return;

      debugPrint("2");

      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _lastAcceptedPosition = null;

      debugPrint("3");

      // final stopwatch = Stopwatch()..start();

      // final cachedPosition = await Geolocator.getLastKnownPosition();

      // if (cachedPosition != null && !isClosed) {
      //   emit(state.copyWith(position: cachedPosition));
      // }

      //Reset route for the new tracking session.
      emit(
        state.copyWith(
          status: LocationStatus.loading,
          isTracking: true,
          routePoints: const [],
          totalDistance: 0.0,
        ),
      );

      _positionStreamSubscription = locationRepository
          .getLiveLocationStream()
          .listen(
            _handleNewPosition,
            // (position) {
            //   if (isClosed) return;

            //   debugPrint(
            //     "GPS received after ${stopwatch.elapsedMilliseconds} ms",
            //   );

            //   emit(
            //     state.copyWith(
            //       status: LocationStatus.success,
            //       position: position,
            //       isTracking: true,
            //     ),
            //   );
            // },
            onError: (Object error) async {
              debugPrint("_positionStreamSubscription-error: $error");
              final subscription = _positionStreamSubscription;
              _positionStreamSubscription = null;

              await subscription?.cancel();

              if (isClosed) return;

              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;

              emit(
                state.copyWith(
                  status: LocationStatus.failure,
                  errorMessage: error.toString(),
                  isTracking: false,
                ),
              );
            },
          );
      debugPrint("_positionStreamSubscription:${_positionStreamSubscription}");
      debugPrint("4");
      // if (isClosed) {
      //   await _positionStreamSubscription?.cancel();
      //   // _positionStreamSubscription = null;
      //   return;
      // }
      // debugPrint("5");
      //Tracking Started, waiting for the first position update
      // emit(state.copyWith(status: LocationStatus.success, isTracking: true));
      // debugPrint("6");
    } catch (e) {
      debugPrint("7");
      if (isClosed) return;
      debugPrint("8");
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
          isTracking: false,
        ),
      );
      debugPrint("9");
    }
  }

  Future<void> stopTracking() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    if (isClosed) return;

    emit(state.copyWith(status: LocationStatus.initial, isTracking: false));
  }

  @override
  Future<void> close() async {
    await _positionStreamSubscription?.cancel();
    await super.close();
  }

  //Step7
  // void _handleNewPosition(Position position) {
  //   if (isClosed || !state.isTracking) return;

  //   debugPrint(
  //     'GPS: accuracy=${position.accuracy.toStringAsFixed(1)}m, '
  //     'speed=${position.speed.toStringAsFixed(2)}m/s',
  //   );

  //   // 1. Reject invalid or inaccurate readings.
  //   if (position.accuracy.isNaN ||
  //       !position.accuracy.isFinite ||
  //       position.accuracy <= 0) {
  //     debugPrint(
  //       "1. Reject invalid or inaccurate readings: ${position.accuracy}",
  //     );
  //     emit(state.copyWith(livePosition: position.accuracy));
  //     return;
  //   }

  //   if (position.accuracy > 50) {
  //     debugPrint(
  //       "1.1. Reject invalid or inaccurate readings: ${position.accuracy}",
  //     );
  //     return;
  //   }

  //   final newPoint = LatLng(position.latitude, position.longitude);

  //   final previousPoint = state.routePoints;

  //   final lastPosition = _lastAcceptedPosition;

  //   double newDistance = state.totalDistance;

  //   if (lastPosition != null) {
  //     // 2. Ignore old or duplicate timestamps.
  //     final seconds =
  //         position.timestamp.difference(lastPosition.timestamp).inMilliseconds /
  //         1000.0;
  //     debugPrint("2. Ignore old or duplicate timestamps: $seconds");

  //     if (seconds <= 0) return;

  //     // final lastPoint = previousPoint.last;

  //     final distance = Geolocator.distanceBetween(
  //       lastPosition.latitude,
  //       lastPosition.longitude,
  //       newPoint.latitude,
  //       newPoint.longitude,
  //     );

  //     // 3. Movement must exceed estimated GPS noise.
  //     // final noiseThreshold = (lastPosition.accuracy + position.accuracy).clamp(
  //     //   5.0,
  //     //   30.0,
  //     // );
  //     final noiseThreshold = (lastPosition.accuracy + position.accuracy).clamp(
  //       10.0,
  //       double.infinity,
  //     );
  //     debugPrint(
  //       "3. Movement must exceed estimated GPS noise: $noiseThreshold",
  //     );

  //     if (distance <= noiseThreshold) return;

  //     // 4. Reject unrealistic walking speeds.
  //     final calculatedSpeed = distance / seconds;

  //     if (calculatedSpeed > 3.0) return;
  //     debugPrint("4. Reject unrealistic walking speeds: $calculatedSpeed");

  //     // //Ignore tiny movements caused by GPS noise
  //     // if (distance < 5) {
  //     //   return;
  //     // }

  //     // //Ignore suspiciously large jumps in distance (e.g., due to GPS errors)
  //     // if (distance > 500) {
  //     //   return;
  //     // }

  //     // if (position.accuracy.isNaN ||
  //     //     !position.accuracy.isFinite ||
  //     //     position.accuracy < 0 ||
  //     //     position.accuracy > 50) {
  //     //   return;
  //     // }

  //     newDistance += distance;
  //     debugPrint("New distance: $newDistance meters");
  //   }

  //   _lastAcceptedPosition = position;
  //   debugPrint(
  //     "5. New position accepted: ${position.latitude}, ${position.longitude}",
  //   );

  //   emit(
  //     state.copyWith(
  //       status: LocationStatus.success,
  //       position: position,
  //       routePoints: [...previousPoint, newPoint],
  //       totalDistance: newDistance,
  //     ),
  //   );
  //   debugPrint(
  //     "6. Updated state: status: ${state.status}, position: ${state.position}, routePoints: ${state.routePoints.length} points, total distance: ${state.totalDistance} meters",
  //   );
  //   debugPrint("7. Position accuracy: ${position.accuracy} meters");
  //   debugPrint('8. Speed: ${position.speed.toStringAsFixed(2)} m/s');
  // }

  //handling gps position updates with accuracy and noise and drift filtering
  void _handleNewPosition(Position position) {
    if (isClosed || !state.isTracking) return;

    debugPrint(
      'GPS: accuracy=${position.accuracy.toStringAsFixed(1)}m, '
      'speed=${position.speed.toStringAsFixed(2)}m/s',
    );

    // Reject poor GPS readings.
    if (!position.accuracy.isFinite ||
        position.accuracy <= 0 ||
        position.accuracy > 50) {
      debugPrint('Rejected: poor GPS accuracy');
      return;
    }

    final lastPosition = _lastAcceptedPosition;

    final newPoint = LatLng(position.latitude, position.longitude);

    double newDistance = state.totalDistance;

    if (lastPosition != null) {
      final seconds =
          position.timestamp.difference(lastPosition.timestamp).inMilliseconds /
          1000.0;

      if (seconds <= 0) return;

      final distance = Geolocator.distanceBetween(
        lastPosition.latitude,
        lastPosition.longitude,
        position.latitude,
        position.longitude,
      );

      // Conservative GPS uncertainty filter.
      final noiseThreshold = (lastPosition.accuracy + position.accuracy).clamp(
        10.0,
        double.infinity,
      );

      debugPrint(
        'Distance: ${distance.toStringAsFixed(1)}m | '
        'Threshold: ${noiseThreshold.toStringAsFixed(1)}m',
      );

      if (distance <= noiseThreshold) {
        debugPrint('Rejected: possible GPS drift');
        return;
      }

      // Check implied movement speed.
      final calculatedSpeed = distance / seconds;

      if (calculatedSpeed > 3.0) {
        debugPrint('Rejected: unrealistic walking speed');
        return;
      }

      // Supporting stationary check.
      // Apply only when reported speed is usable.
      if (position.speed.isFinite &&
          position.speedAccuracy.isFinite &&
          position.speedAccuracy >= 0 &&
          position.speedAccuracy <= 0.5 &&
          position.speed >= 0 &&
          position.speed < 0.3) {
        debugPrint('Rejected: likely stationary');
        return;
      }

      newDistance += distance;
    }

    _lastAcceptedPosition = position;

    emit(
      state.copyWith(
        status: LocationStatus.success,
        position: position,
        routePoints: [...state.routePoints, newPoint],
        totalDistance: newDistance,
      ),
    );

    debugPrint(
      'Accepted: ${state.routePoints.length} points, '
      '${state.totalDistance.toStringAsFixed(1)}m',
    );
  }
}
