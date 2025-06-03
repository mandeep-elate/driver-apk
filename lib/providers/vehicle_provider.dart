import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';

class VehicleProvider extends ChangeNotifier {
  final _vehicleCollection = FirebaseFirestore.instance.collection('vehicles');
  final _driverCollection = FirebaseFirestore.instance.collection('drivers');

  Future<List<Vehicle>> fetchVehicles() async {
  final snapshot = await _vehicleCollection.get();
  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Vehicle.fromMap(data, doc.id); // Pass doc.id as the second argument
  }).toList();
}


  Future<void> addVehicle(Vehicle vehicle) async {
    await _vehicleCollection.add(vehicle.toMap());
    notifyListeners();
  }

  Future<void> updateVehicle(String id, Vehicle vehicle) async {
    await _vehicleCollection.doc(id).update(vehicle.toMap());
    notifyListeners();
  }

  Future<void> deleteVehicle(String id) async {
    await _vehicleCollection.doc(id).delete();
    notifyListeners();
  }

  Future<List<Driver>> fetchDrivers() async {
    final snapshot = await _driverCollection.get();
    return snapshot.docs.map((doc) => Driver.fromMap(doc.data())).toList();
  }
}
