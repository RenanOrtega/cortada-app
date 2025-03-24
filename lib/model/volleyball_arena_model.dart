class VolleyballArena {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isIndoor;
  final int courtCount;

  VolleyballArena({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isIndoor,
    required this.courtCount,
  });
}
