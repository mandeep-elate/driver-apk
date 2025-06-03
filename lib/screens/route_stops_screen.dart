import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/add_route_stop_screen.dart';
import '../models/driver.dart';
import '../providers/vehicle_provider.dart'; // To fetch drivers and get names

class RouteStopsScreen extends StatefulWidget {
  const RouteStopsScreen({super.key});

  @override
  State<RouteStopsScreen> createState() => _RouteStopsScreenState();
}

class _RouteStopsScreenState extends State<RouteStopsScreen> {
  final _provider = VehicleProvider();
  List<Driver> _drivers = [];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    final fetchedDrivers = await _provider.fetchDrivers();
    setState(() {
      _drivers = fetchedDrivers;
    });
  }

  String _getDriverNameById(int id) {
    final driver = _drivers.firstWhere(
      (d) => d.id == id,
      orElse:
          () =>
              Driver(id: id, name: 'Unknown', contactInfo: '', paymentType: ''),
    );
    return driver.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Stop Screen'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('route_stops').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No route stops found'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data()! as Map<String, dynamic>;

              // Convert driverId to int safely
              final dynamic rawDriverId = data['driverId'];
              int? driverId;

              if (rawDriverId is int) {
                driverId = rawDriverId;
              } else if (rawDriverId is String) {
                driverId = int.tryParse(rawDriverId);
              }

              if (driverId == null) {
                return ListTile(
                  title: const Text('Invalid driver ID'),
                  subtitle: Text('Raw ID: $rawDriverId'),
                );
              }

              final driverName = _getDriverNameById(driverId);
              final numberOfStops = data['stops'] ?? 0;

              return ListTile(
                title: Text(driverName),
                subtitle: Text('Number Of Stop: $numberOfStops'),
                // You can add more details or trailing icons here
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 254, 254),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRouteScreen()),
          );
        },
      ),
    );
  }
}
