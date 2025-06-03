class VehicleDamage {
  final String vehicleId;
  final String vehicleModel;
  final String date;
  final String description;
  final String imageUrl;

  VehicleDamage({
    required this.vehicleId,
    required this.vehicleModel,
    required this.date,
    required this.description,
    required this.imageUrl,
  });

  // get imagePath => null;

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'vehicleModel': vehicleModel,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
