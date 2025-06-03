class Vehicle {
  final String id; // Changed from int to String
  final String model;
  final String registration;
  final String? assignedDriverId;

  const Vehicle({
    required this.id,
    required this.model,
    required this.registration,
    this.assignedDriverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'registration': registration,
      'assignedDriverId': assignedDriverId,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map, String documentId) {
    return Vehicle(
      id: documentId, // Firestore doc ID
      model: map['model'] ?? '',
      registration: map['registration'] ?? '',
      assignedDriverId: map['assignedDriverId'],
    );
  }
}
