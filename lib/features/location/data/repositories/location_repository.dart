import 'package:geolocator/geolocator.dart';

import '../datasources/location_service.dart';

class LocationRepository {
  final LocationService locationService;

  LocationRepository(this.locationService);

  Future<Position> getCurrentLocation() async {
    return await locationService.getCurrentLocation();
  }
}
