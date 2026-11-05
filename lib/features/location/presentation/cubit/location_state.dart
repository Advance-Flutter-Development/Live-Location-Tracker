import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum LocationStatus { initial, loading, success, failure }

// Equatable -> Compares states based on their properties
class LocationState extends Equatable {
  final LocationStatus status;
  final Position? position; //Store GPS Position
  final double? livePosition; //Store live GPS Position
  final String? errorMessage;
  final bool isTracking;

  //Step7
  final List<LatLng>
  routePoints; //stores GPS coordinates for drawing the route.
  final double totalDistance; // stores total traveled distance in meters.

  const LocationState({
    this.status = LocationStatus.initial,
    this.position,
    this.livePosition,
    this.errorMessage,
    this.isTracking = false,
    this.routePoints = const [],
    this.totalDistance = 0.0,
  });

  LocationState copyWith({
    LocationStatus? status,
    Position? position,
    double? livePosition,
    String? errorMessage,
    bool? isTracking,
    List<LatLng>? routePoints,
    double? totalDistance,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      livePosition: livePosition ?? this.livePosition,
      errorMessage: errorMessage ?? this.errorMessage,
      isTracking: isTracking ?? this.isTracking,
      routePoints: routePoints ?? this.routePoints,
      totalDistance: totalDistance ?? this.totalDistance,
    );
  }

  @override
  List<Object?> get props => [
    status,
    position,
    livePosition,
    errorMessage,
    isTracking,
    routePoints,
    totalDistance,
  ];
}
