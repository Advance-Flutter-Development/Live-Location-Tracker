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
      body: BlocConsumer<LocationCubit, LocationState>(
        //i forget to add in step 4
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.status == LocationStatus.success ||
                current.status == LocationStatus.failure),
        listener: (context, state) {
          if (state.status == LocationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred."),
              ),
            );
          }
          if (state.status == LocationStatus.success &&
              state.position != null) {
            final position = state.position!;

            moveCamera(LatLng(position.latitude, position.longitude));

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
                initialCameraPosition: initialCameraPosition,
                onMapCreated: (controller) {
                  mapController = controller;

                  if (currentLocation != null) {
                    moveCamera(currentLocation);
                  }
                },
                myLocationEnabled: state.status == LocationStatus.success,
                myLocationButtonEnabled: state.status == LocationStatus.success,
                zoomControlsEnabled: false,
                markers: {
                  if (currentLocation != null)
                    Marker(
                      markerId: const MarkerId("current_location"),
                      position: currentLocation,
                      infoWindow: const InfoWindow(title: "My Location"),
                    ),
                },
              ),

              // Location details
              if (state.status == LocationStatus.success && position != null)
                Positioned(
                  top: 36,
                  left: 16,
                  right: 16,
                  child: Card(
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
                child: ElevatedButton.icon(
                  onPressed: state.status == LocationStatus.loading
                      ? null
                      : () {
                          context.read<LocationCubit>().getCurrentLocation();
                        },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Get Current Location'),
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
