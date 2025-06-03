import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/driver.dart';

class DriverProvider with ChangeNotifier {
  final List<Driver> _drivers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;
  bool _loading = false;

  List<Driver> get drivers => _drivers;
  bool get isLoading => _loading;

  /// Call this once (e.g., in main.dart) to preload data
  Future<void> initialize() async {
    if (!_initialized) {
      await fetchDrivers();
      _initialized = true;
    }
  }

  // ignore: unintended_html_in_doc_comment
  /// Fetch drivers from Firestore and return a List<Driver>
  Future<List<Driver>> fetchDrivers() async {
    try {
      _loading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('drivers').get();

      // Clear existing drivers and fetch new ones
      _drivers.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Ensure fromMap is correctly converting Firestore data to Driver object
        _drivers.add(Driver.fromMap(data));
      }

      _loading = false;
      notifyListeners();

      return _drivers;  // Return the list of drivers
    } catch (e) {
      _loading = false;
      notifyListeners();
      print('🔥 fetchDrivers error: $e');
      Fluttertoast.showToast(msg: "Failed to fetch drivers ❌");
      return [];  // Return an empty list on error
    }
  }

  /// Add a new driver to Firestore
  Future<void> addDriver(Driver driver) async {
    try {
      await _firestore
          .collection('drivers')
          .doc(driver.id.toString()) // Assuming the driver id is converted to a string
          .set(driver.toMap()); // Save driver data to Firestore

      _drivers.add(driver);
      notifyListeners();

      Fluttertoast.showToast(msg: "Driver added successfully 🚗");
    } catch (e) {
      print('🔥 addDriver error: $e');
      Fluttertoast.showToast(msg: "Failed to add driver ❌");
    }
  }

  /// Edit an existing driver's details in Firestore
  Future<void> editDriver(Driver updatedDriver) async {
    try {
      await _firestore
          .collection('drivers')
          .doc(updatedDriver.id.toString())
          .set(updatedDriver.toMap()); // Update driver data

      final index = _drivers.indexWhere((d) => d.id == updatedDriver.id);
      if (index != -1) {
        _drivers[index] = updatedDriver; // Replace the driver in the list
        notifyListeners();
      }

      Fluttertoast.showToast(msg: "Driver updated ✏️");
    } catch (e) {
      print('🔥 editDriver error: $e');
      Fluttertoast.showToast(msg: "Failed to update driver ❌");
    }
  }

  /// Delete a driver from Firestore
  Future<void> deleteDriver(int driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId.toString()).delete();
      _drivers.removeWhere((d) => d.id == driverId); // Remove from local list
      notifyListeners();

      Fluttertoast.showToast(msg: "Driver deleted 🗑️");
    } catch (e) {
      print('🔥 deleteDriver error: $e');
      Fluttertoast.showToast(msg: "Failed to delete driver ❌");
    }
  }
}
