import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/repositories/location_repository.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository locationRepository;

  StreamSubscription<Position>? _positionStreamSubscription;

  LocationCubit(this.locationRepository) : super(const LocationState());

  //Step5
  Future<void> getCurrentLocation() async {
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

      debugPrint("3");

      final stopwatch = Stopwatch()..start();

      final cachedPosition = await Geolocator.getLastKnownPosition();

      if (cachedPosition != null && !isClosed) {
        emit(state.copyWith(position: cachedPosition));
      }

      _positionStreamSubscription = locationRepository
          .getLiveLocationStream()
          .listen(
            (position) {
              if (isClosed) return;

              debugPrint(
                "GPS received after ${stopwatch.elapsedMilliseconds} ms",
              );

              emit(
                state.copyWith(
                  status: LocationStatus.success,
                  position: position,
                  isTracking: true,
                ),
              );
            },
            onError: (Object error) {
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
      debugPrint("4");
      // if (isClosed) {
      //   await _positionStreamSubscription?.cancel();
      //   // _positionStreamSubscription = null;
      //   return;
      // }
      // debugPrint("5");
      //Tracking Started, waiting for the first position update
      emit(state.copyWith(status: LocationStatus.success, isTracking: true));
      debugPrint("6");
    } catch (e) {
      debugPrint("7");
      if (isClosed) return;
      debugPrint("8");
      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
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
    super.close();
  }
}
