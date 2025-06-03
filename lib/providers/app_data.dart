import 'package:flutter/material.dart';

class Driver {
  final String name;
  final int id;

  Driver({required this.name, required this.id});
}

class AppData with ChangeNotifier {
  final List<Driver> _drivers = [
  ];

  List<Driver> get drivers => _drivers;

  // A method that calculates payments for drivers based on startDate and endDate
  double calculateDriverPayment(Driver driver, DateTime startDate, DateTime endDate) {
    // Example logic: returns a random amount for simplicity
    // Replace this with actual payment calculation logic
    return (endDate.difference(startDate).inDays * 10.0); // e.g., $10 per day
  }
}
