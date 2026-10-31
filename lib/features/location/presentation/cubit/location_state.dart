import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus { initial, loading, success, failure }

// Equatable -> Compares states based on their properties
class LocationState extends Equatable {
  final LocationStatus status;
  final Position? position; //Store GPS Position
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.position,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    Position? position,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, position, errorMessage];
}
