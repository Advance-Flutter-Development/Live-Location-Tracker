import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";

import "../cubit/location_cubit.dart";
import "../cubit/location_state.dart";

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? mapController;

  MapType _mapType = MapType.normal;

  // Default camera location until GPS is fetched.
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  Future<void> moveCamera(LatLng location) async {
    if (mapController == null) return;

    await mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, 17),
    );
  }

  @override
  void initState() {
    // LocationService().checkLocationPermission();
    super.initState();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<LocationCubit, LocationState>(
        //i forget to add in step 4
        listenWhen: (previous, current) =>
            // previous.position != current.position ||
            // (current.status == LocationStatus.success &&
            //     current.status == LocationStatus.failure),
            ///It Listens newly occurring errors - This stops the map from chasing GPS drift.:
            previous.status != LocationStatus.failure &&
            current.status == LocationStatus.failure,
        listener: (context, state) {
          if (state.status == LocationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred."),
              ),
            );
          }
          if (state.position != null &&
              state.status == LocationStatus.success) {
            ///commented: Because, it returns the camera direction based on GPS Noise and GPS Drifting
            // final position = state.position!;
            // moveCamera(LatLng(position.latitude, position.longitude));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Location retrieved successfully.")),
            );
          }
        },
        builder: (context, state) {
          final position = state.position;

          final LatLng? currentLocation = position == null
              ? null
              : LatLng(position.latitude, position.longitude);
          return Stack(
            children: [
              GoogleMap(
                compassEnabled: false,
                mapType: _mapType,
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (controller) {
                  mapController = controller;

                  if (currentLocation != null) {
                    moveCamera(currentLocation);
                  }
                },
                myLocationEnabled: state.position != null,
                // myLocationEnabled: false,
                // myLocationButtonEnabled: state.position != null,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  // if (currentLocation != null)
                  //   Marker(
                  //     markerId: const MarkerId("current_location"),
                  //     position: currentLocation,
                  //     infoWindow: const InfoWindow(title: "My Location"),
                  //     icon: BitmapDescriptor.defaultMarkerWithHue(
                  //       BitmapDescriptor.hueAzure,
                  //     ),
                  //   ),
                },

                polylines: {
                  if (state.routePoints.length >= 2)
                    Polyline(
                      polylineId: const PolylineId("tracking_route"),
                      points: state.routePoints,
                      color: Colors.blue,
                      width: 5,
                      startCap: Cap.roundCap,
                      endCap: Cap.roundCap,
                    ),
                },
              ),

              Positioned(
                right: 16,
                bottom: 260,
                child: FloatingActionButton.small(
                  heroTag: 'map_type',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _mapType = _mapType == MapType.normal
                          ? MapType.hybrid
                          : MapType.normal;
                    });
                  },
                  child: const Icon(Icons.layers),
                ),
              ),

              //Compass Button
              Positioned(
                right: 16,
                bottom: 320, // Adjust to your preferred position
                child: FloatingActionButton.small(
                  heroTag: 'compass_button',
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    if (mapController == null) return;

                    final cameraPosition = await mapController!
                        .getVisibleRegion();

                    // Instead of changing the location,
                    // reset the map orientation to North.
                    await mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            (cameraPosition.northeast.latitude +
                                    cameraPosition.southwest.latitude) /
                                2,
                            (cameraPosition.northeast.longitude +
                                    cameraPosition.southwest.longitude) /
                                2,
                          ),
                          zoom: await mapController!.getZoomLevel(),
                          bearing: 0,
                          tilt: 0,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.explore),
                ),
              ),

              //Relocation Btn
              Positioned(
                right: 16,
                bottom: 200, // Adjust based on your tracking card height
                child: FloatingActionButton(
                  heroTag: 'recenter_location',
                  backgroundColor: Colors.white,
                  mini: true,
                  onPressed: () {
                    final position = state.position;

                    if (position == null) {
                      context.read<LocationCubit>().getCurrentLocation();
                      return;
                    }

                    moveCamera(LatLng(position.latitude, position.longitude));
                  },
                  child: const Icon(Icons.my_location),
                ),
              ),

              // Location details
              if (state.status == LocationStatus.success && position != null)
                Positioned(
                  top: 36,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Colors.white.withValues(alpha: 0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Latitude: ${position.latitude}'),
                          Text('Longitude: ${position.longitude}'),
                          Text(
                            'Accuracy: ${position.accuracy.toStringAsFixed(1)} m',
                          ),

                          const SizedBox(height: 8),

                          Text(
                            state.totalDistance >= 1000
                                ? 'Distance: ${(state.totalDistance / 1000).toStringAsFixed(2)} km'
                                : 'Distance: ${state.totalDistance.toStringAsFixed(1)} m',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Loading indicator
              if (state.status == LocationStatus.loading)
                const Center(child: CircularProgressIndicator()),

              // Get current location button
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.isTracking
                              ? 'Tracking Active'
                              : 'Tracking Stopped',
                        ),

                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed:
                              state.isTracking ||
                                  state.status == LocationStatus.loading
                              ? null
                              : () {
                                  context
                                      .read<LocationCubit>()
                                      .getCurrentLocation();
                                },
                          child: const Text('Current'),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Current Location Btn
                            // ElevatedButton(
                            //   onPressed:
                            //       state.isTracking ||
                            //           state.status == LocationStatus.loading
                            //       ? null
                            //       : () {
                            //           context
                            //               .read<LocationCubit>()
                            //               .getCurrentLocation();
                            //         },
                            //   child: const Text('Current'),
                            // ),

                            // const SizedBox(height: 8),

                            //Start Tracking Btn
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    state.isTracking ||
                                        state.status == LocationStatus.loading
                                    ? null
                                    : () {
                                        context
                                            .read<LocationCubit>()
                                            .startTracking();
                                      },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Start'),
                              ),
                            ),

                            const SizedBox(width: 8),

                            //Stop Tracking Btn
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: !state.isTracking
                                    ? null
                                    : () {
                                        context
                                            .read<LocationCubit>()
                                            .stopTracking();
                                      },
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop'),
                              ),
                            ),
                          ],
                        ),
                        if (state.livePosition != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Accuracy: ${state.livePosition?.toStringAsFixed(3) ?? "N/A"} m',
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // SafeArea(
              //   child: Center(
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         if (state.status == LocationStatus.loading)
              //           const CircularProgressIndicator(),

              //         if (state.status == LocationStatus.success &&
              //             position != null) ...[
              //           Text("Latitude: ${position.latitude}"),
              //           Text("Longitude: ${position.longitude}"),
              //           Text("Accuracy: ${position.accuracy} m"),
              //         ],

              //         const SizedBox(height: 10),

              //         ElevatedButton(
              //           onPressed: state.status == LocationStatus.loading
              //               ? null
              //               : () {
              //                   context
              //                       .read<LocationCubit>()
              //                       .getCurrentLocation();
              //                 },
              //           child: const Text("Get Current Location"),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}

/** Get Location Permission tester  - Step 2
  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Location Page"),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Check Permission"),
                onPressed: () async {
                  try {
                    final bool result = await locationService
                        .checkLocationPermission();

                    debugPrint("Permission result: $result");

                    if (!context.mounted) return;

                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location permission granted!'),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint("Location Error: $e");

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
 */
