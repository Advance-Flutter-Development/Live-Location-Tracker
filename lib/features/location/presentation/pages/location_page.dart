import "package:flutter/material.dart";
import "package:live_location_tracker/features/location/data/datasources/location_service.dart";


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
}
