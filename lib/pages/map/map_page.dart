import 'package:cortada_app/providers/location/map_controller_provider.dart';
import 'package:cortada_app/providers/location/user_location_provider.dart';
import 'package:cortada_app/providers/location/volleyball_arena_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapWithUserLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeMapWithUserLocation() async {
    final userLocation = ref.read(userLocationProvider);
    if (userLocation != null) {
      final userLating = LatLng(userLocation.latitude, userLocation.longitude);

      ref.read(mapCenterProvider.notifier).state = userLating;
      _mapController.move(userLating, ref.read(mapZoomProvider));

      await ref.read(volleyballArenasProvider.notifier).fetchAreasNearLocation(
          userLocation.latitude, userLocation.longitude, 5.0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
