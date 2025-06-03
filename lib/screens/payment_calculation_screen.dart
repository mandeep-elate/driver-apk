import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverPaymentScreen extends StatefulWidget {
  const DriverPaymentScreen({super.key});

  @override
  State<DriverPaymentScreen> createState() => _DriverPaymentScreenState();
}

class _DriverPaymentScreenState extends State<DriverPaymentScreen> {
  String? selectedDriverId;
  Map<String, dynamic>? selectedDriverData;

  List<Map<String, dynamic>> vehicles = [];
  int routeStopCount = 0;
  double totalPenalty = 0.0;
  double totalDeposit = 0.0;
  double perStopRate = 0.0;

  Future<void> _fetchDataForDriver(String driverId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Fetch driver document
      final driverDoc =
          await firestore.collection('drivers').doc(driverId).get();
      if (!driverDoc.exists) {
        _resetDriverData();
        return;
      }

      final driverData = driverDoc.data()!;
      double driverPerStopRate = _toDouble(driverData['perStopRate']);

      // Fetch vehicles where driverId == selected driverId
      final vehiclesSnapshot =
          await FirebaseFirestore.instance
              .collection('vehicles')
              .where('assignedDriverId', isEqualTo: driverId.trim())
              .get();

      final vehicleList = vehiclesSnapshot.docs.map((e) => e.data()).toList();

      setState(() {
        vehicles = vehicleList;
      });

      // Fetch route stops count
      final routeStopsSnapshot =
          await firestore
              .collection('route_stops')
              .where(
                'driverId',
                isEqualTo: int.parse(driverId.toString()),
              ) // Ensure it's a number
              .get();

      int routeStopsCount = 0;

      if (routeStopsSnapshot.docs.isNotEmpty) {
        final stops = routeStopsSnapshot.docs.first.data()['stops'];
        if (stops is int) {
          routeStopsCount = stops;
        } else if (stops is double) {
          routeStopsCount = stops.toInt();
        }
      }

      // Fetch penalties and sum
      final penaltiesSnapshot =
          await firestore
              .collection('penalty')
              .where('driver_id', isEqualTo: driverId)
              .get();

      double penaltiesSum = penaltiesSnapshot.docs.fold(
        0.0,
        // ignore: avoid_types_as_parameter_names
        (sum, doc) => sum + _toDouble(doc['amount']),
      );

      // Fetch deposits and sum
      final depositsSnapshot =
          await firestore
              .collection('deposits')
              .where('driverId', isEqualTo: driverId)
              .get();

      double depositsSum = depositsSnapshot.docs.fold(
        0.0,
        // ignore: avoid_types_as_parameter_names
        (sum, doc) => sum + _toDouble(doc['amount']),
      );

      setState(() {
        selectedDriverData = driverData;
        vehicles = vehicleList;
        routeStopCount = routeStopsCount;
        totalPenalty = penaltiesSum;
        totalDeposit = depositsSum;
        perStopRate = driverPerStopRate;
      });
    } catch (e) {
      print('Error fetching data: $e');
      _resetDriverData();
    }
  }

  void _resetDriverData() {
    setState(() {
      selectedDriverData = null;
      vehicles = [];
      routeStopCount = 0;
      totalPenalty = 0.0;
      totalDeposit = 0.0;
      perStopRate = 0.0;
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  double get finalPayment {
    if (selectedDriverData == null) return 0.0;

    final paymentType = selectedDriverData!['paymentType'];
    final fixedRate = _toDouble(selectedDriverData!['fixedDailyRate']);

    if (paymentType == 'fixed') {
      return fixedRate - totalPenalty - totalDeposit;
    } else {
      return (perStopRate * routeStopCount) - totalPenalty - totalDeposit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Payment Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('drivers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final drivers = snapshot.data!.docs;

                return DropdownButton<String>(
                  hint: const Text('Select a Driver'),
                  value: selectedDriverId,
                  isExpanded: true,
                  items:
                      drivers.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(data['name'] ?? 'Unnamed'),
                        );
                      }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedDriverId = val;
                      _resetDriverData();
                    });
                    if (val != null) _fetchDataForDriver(val);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            if (selectedDriverId != null) ...[
              const Text(
                'Vehicles Assigned:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (vehicles.isEmpty)
                const Text('No vehicles assigned')
              else
                ...vehicles.map((v) => Text('${v['model'] ?? 'Unknown'}')),

              const SizedBox(height: 16),
              Text('Route Stops: $routeStopCount'),
              Text('Total Penalties: £${totalPenalty.toStringAsFixed(2)}'),
              Text('Total Deposits: £${totalDeposit.toStringAsFixed(2)}'),
              Text('Per Stop Rate: £${perStopRate.toStringAsFixed(2)}'),
              Text(
                'Payment Type: ${selectedDriverData?['paymentType'] ?? 'N/A'}',
              ),
              if (selectedDriverData?['paymentType'] == 'fixed')
                Text(
                  'Fixed Daily Rate: £${_toDouble(selectedDriverData?['fixedDailyRate']).toStringAsFixed(2)}',
                ),

              const Divider(height: 32),
              Text(
                'Final Payable Amount: £${finalPayment.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
