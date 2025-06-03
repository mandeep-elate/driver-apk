import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/penalty.dart';
import '../models/driver.dart';
import 'add_penalty_screen.dart';

class PenaltyScreen extends StatefulWidget {
  final List<Driver> drivers;
  final Function(Penalty) onAddPenalty;

  const PenaltyScreen({
    super.key,
    required this.drivers,
    required this.onAddPenalty,
    required List<Penalty> penalties,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PenaltyScreenState createState() => _PenaltyScreenState();
}

class _PenaltyScreenState extends State<PenaltyScreen> {
  Stream<List<Penalty>> _penaltiesStream() {
    return FirebaseFirestore.instance.collection('penalty').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Penalty(
          id: doc.id,
          driverId: data['driver_id'].toString(),
          date: data['date'],
          amount: data['amount'],
        );
      }).toList();
    });
  }

  Future<String> _getDriverName(String driverId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('drivers')
              .doc(driverId)
              .get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penalties')),
      body: StreamBuilder<List<Penalty>>(
        stream: _penaltiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final penalties = snapshot.data ?? [];

          if (penalties.isEmpty) {
            return const Center(child: Text('No penalties available.'));
          }

          return ListView.builder(
            itemCount: penalties.length,
            itemBuilder: (context, index) {
              final penalty = penalties[index];

              return FutureBuilder<String>(
                future: _getDriverName(penalty.driverId),
                builder: (context, snapshot) {
                  final driverName = snapshot.data ?? 'Loading...';
                  return ListTile(
                    title: Text(driverName),
                    subtitle: Text(
                      'Date: ${penalty.date.toString().split(' ')[0]} ',
                    ),
                    trailing: Text('Amount: £${penalty.amount}'),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AddPenaltyScreen(
                    drivers: widget.drivers,
                    onAddPenalty: widget.onAddPenalty,
                    onPenaltyAdded: (Penalty penalty) {},
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
