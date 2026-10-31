import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:geolocator/geolocator.dart";
import "package:live_location_tracker/features/location/data/datasources/location_service.dart";
import "package:live_location_tracker/features/location/data/repositories/location_repository.dart";
import "package:live_location_tracker/features/location/presentation/cubit/location_cubit.dart";

import "package:live_location_tracker/features/location/presentation/pages/location_page.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      //dependency injection - like Getx(Get.put())
      create: (context) => LocationCubit(LocationRepository(LocationService())),
      child: MaterialApp(home: const LocationPage()),
    );
  }
}

//Getting Latitude and Longitude of the device using Geolocator package - Step 3
// class LocationTestPage extends StatefulWidget {
//   const LocationTestPage({super.key});

//   @override
//   State<LocationTestPage> createState() => _LocationTestPageState();
// }

// class _LocationTestPageState extends State<LocationTestPage> {
//   final LocationService locationService = LocationService();

//   Position? currentPosition;
//   bool isLoading = false;
//   String? errorMessage;

//   Future<void> fetchLocation() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final Position position = await locationService.getCurrentLocation();

//       if (!mounted) return;

//       setState(() {
//         currentPosition = position;
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         errorMessage = e.toString();
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Current GPS Location")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (isLoading) const CircularProgressIndicator(),

//             if (currentPosition != null) ...[
//               Text("Latitude: ${currentPosition!.latitude}"),
//               Text("Longitude: ${currentPosition!.longitude}"),
//               Text("Accuracy: ${currentPosition!.accuracy} m"),
//             ],

//             if (errorMessage != null)
//               Text(errorMessage!, textAlign: TextAlign.center),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: isLoading ? null : fetchLocation,
//               child: const Text("Get Current Location"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
