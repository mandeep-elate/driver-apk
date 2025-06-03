import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/driver.dart';
import '../models/deposit.dart';
import 'add_deposit_screen.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({
    super.key,
    required List<Deposit> deposits,
    required List<Driver> drivers,
    required void Function(Deposit deposit) onDepositAdded,
  });

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  List<Deposit> deposits = [];
  List<Map<String, dynamic>> drivers = []; // Only id and name for dropdown

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // ✅ Use correct collection name: "deposites"
      final depositSnapshot =
          await FirebaseFirestore.instance.collection('deposites').get();

      final fetchedDeposits = depositSnapshot.docs.map((doc) {
        final data = doc.data();
        return Deposit(
          id: doc.id,
          driverId: data['driverId']?.toString() ?? '',
          date: data['date']?.toString() ?? '',
          amount: data['amount']?.toString() ?? '',
        );
      }).toList();

      // Load driver id and name for dropdown
      final driverSnapshot =
          await FirebaseFirestore.instance.collection('drivers').get();

      final driverList = driverSnapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': data['id'], 'name': data['name']};
      }).toList();

      setState(() {
        deposits = fetchedDeposits;
        drivers = driverList;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  Future<void> _addDeposit(Deposit deposit) async {
    // ✅ Save to the correct collection
    await FirebaseFirestore.instance.collection('deposites').add({
      'driverId': deposit.driverId,
      'date': deposit.date,
      'amount': deposit.amount.toString(),
    });
    await _loadData();
  }

  Future<String> _getDriverName(String driverId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .where('id', isEqualTo: int.tryParse(driverId))
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['name'] ?? 'Unknown';
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deposits')),
      body: deposits.isEmpty
          ? const Center(child: Text('No deposits found.'))
          : ListView.builder(
              itemCount: deposits.length,
              itemBuilder: (context, index) {
                final deposit = deposits[index];

                return FutureBuilder<String>(
                  future: _getDriverName(deposit.driverId),
                  builder: (context, snapshot) {
                    final name = snapshot.data ?? 'Loading...';
                    return ListTile(
                      title: Text(name),
                      subtitle: Text('Date: ${deposit.date}'),
                      trailing: Text('£${deposit.amount}'),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddDepositScreen(
                drivers: drivers
                    .map((d) => Driver(
                          id: d['id'],
                          name: d['name'],
                          contactInfo: '',
                          paymentType: '',
                          perStopRate: 0.0,
                          fixedDailyRate: 0.0,
                        ))
                    .toList(),
                onDepositAdded: _addDeposit,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
