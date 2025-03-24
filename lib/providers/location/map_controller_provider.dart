import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final mapZoomProvider = StateProvider<double>((ref) {
  return 15.0; // Zoom inicial
});

// Provider para o centro atual do mapa
final mapCenterProvider = StateProvider<LatLng>((ref) {
  // Valor padrão (São Paulo)
  return LatLng(-23.550, -46.633);
});
