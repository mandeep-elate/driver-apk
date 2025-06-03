import 'package:flutter/foundation.dart';
import '../models/penalty.dart';

// instruction: Create a PenaltyProvider class. This will be a class that extends ChangeNotifier. This class should have a list of penalties, and methods to add a new penalty. Add the necessary imports.
class PenaltyProvider extends ChangeNotifier {
  final List<Penalty> _penalties = [];

  List<Penalty> get penalties => _penalties;

  void addPenalty(Penalty penalty) {
    _penalties.add(penalty); // Add penalty to the list
    notifyListeners(); // Notify listeners of the change
  }
}