class RouteStop {
  final String id; // Changed from int to String
  final int driverId;
  final int numberOfStops;
  final DateTime date;

  const RouteStop({
    required this.id,
    required this.driverId,
    required this.numberOfStops,
    required this.date,
  });

  /// Convert to Firestore map where all values are stored as strings
  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId.toString(),
      'numberOfStops': numberOfStops.toString(),
      'date': date.toIso8601String(), // already a string
    };
  }

  factory RouteStop.fromMap(Map<String, dynamic> map, String documentId) {
    return RouteStop(
      id: documentId, // Firestore doc ID
      driverId: map['driverId'] ?? '',
      numberOfStops: map['numberOfStops'] ?? '',
      date: map['date'],
    );
  }
}
