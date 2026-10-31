import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:live_location_tracker/features/location/data/datasources/location_service.dart";
import "package:live_location_tracker/features/location/presentation/cubit/location_cubit.dart";
import "package:live_location_tracker/features/location/presentation/cubit/location_state.dart";

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  void initState() {
    // LocationService().checkLocationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LocationCubit, LocationState>(
        listener: (context, state) {
          if (state.status == LocationStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred."),
              ),
            );
          }
          if (state.status == LocationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Location retrieved successfully.")),
            );
          }
        },
        builder: (context, state) {
          final position = state.position;
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.status == LocationStatus.loading)
                    const CircularProgressIndicator(),

                  if (state.status == LocationStatus.success &&
                      position != null) ...[
                    Text("Latitude: ${position.latitude}"),
                    Text("Longitude: ${position.longitude}"),
                    Text("Accuracy: ${position.accuracy} m"),
                  ],

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: state.status == LocationStatus.loading
                        ? null
                        : () {
                            context.read<LocationCubit>().getCurrentLocation();
                          },
                    child: const Text("Get Current Location"),
                  ),
                ],
              ),
            ),
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
