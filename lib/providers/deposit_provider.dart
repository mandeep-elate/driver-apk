import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/deposit.dart';

class DepositProvider with ChangeNotifier {
  final List<Deposit> _deposits = [];

  // ignore: unused_field
  final CollectionReference<Map<String, dynamic>> _depositsCollection =
      FirebaseFirestore.instance.collection('deposits');

  List<Deposit> getDeposits() {
    return _deposits;
  }

  void addDeposit(Deposit deposit) {
    _deposits.add(deposit);
    notifyListeners();
  }

}
