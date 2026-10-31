import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> checkLocationPermission() async {
    //Step1: Check whether GPS/Location service are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception("Please enable location service!");
    }

    //Step2: Check existing permission
    LocationPermission permission = await Geolocator.checkPermission();

    //Step3: Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    //Step4: Handle denied permission
    if (permission == LocationPermission.denied) {
      throw Exception("Location Permission denied");
    }

    //Step5: Handle permanentaly denied permission
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        "Location Permission permanently denied. "
        "Please enable it from app settings",
      );
    }

    return true;
  }

  Future<Position> getCurrentLocation() async {
    // Check GPS and location permissions first.
    await checkLocationPermission();

    //Get device current position
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    return position;
  }
}
