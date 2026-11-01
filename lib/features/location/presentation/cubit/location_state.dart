import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus { initial, loading, success, failure }

// Equatable -> Compares states based on their properties
class LocationState extends Equatable {
  final LocationStatus status;
  final Position? position; //Store GPS Position
  final String? errorMessage;
  final bool isTracking;

  const LocationState({
    this.status = LocationStatus.initial,
    this.position,
    this.errorMessage,
    this.isTracking = false,
  });

  LocationState copyWith({
    LocationStatus? status,
    Position? position,
    String? errorMessage,
    bool? isTracking,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
      isTracking: isTracking ?? this.isTracking,
    );
  }

  @override
  List<Object?> get props => [status, position, errorMessage, isTracking];
}
