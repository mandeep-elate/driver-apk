import 'package:flutter/foundation.dart';
import '../models/vehicle_damage.dart';


class VehicleDamageProvider with ChangeNotifier {
  final List<VehicleDamage> _vehicleDamages = [];

 List<VehicleDamage> get vehicleDamages => [..._vehicleDamages];

  void addVehicleDamage(VehicleDamage vehicleDamage) {
    _vehicleDamages.add(vehicleDamage);
    notifyListeners();
  }
  
 
}