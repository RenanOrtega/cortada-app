import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final userLocationProvider =
    StateNotifierProvider<UserLocationNotifier, Position?>((ref) {
  return UserLocationNotifier();
});

class UserLocationNotifier extends StateNotifier<Position?> {
  UserLocationNotifier() : super(null) {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);

      state = position;
    } catch (e) {
      print('Erro ao obter localização: $e');
    }
  }

  void refreshLocation() async {
    await _getCurrentLocation();
  }
}
