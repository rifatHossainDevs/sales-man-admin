class RouteHistoryPoint {
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final String placeName;

  const RouteHistoryPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.placeName,
  });
}
