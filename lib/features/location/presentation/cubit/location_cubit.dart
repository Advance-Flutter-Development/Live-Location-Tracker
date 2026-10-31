import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/location_repository.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final LocationRepository locationRepository;

  LocationCubit(this.locationRepository) : super(const LocationState());

  Future<void> getCurrentLocation() async {
    emit(state.copyWith(status: LocationStatus.loading));
    try {
      final position = await locationRepository.getCurrentLocation();

      if (isClosed) return;

      emit(state.copyWith(status: LocationStatus.success, position: position));
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: LocationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
