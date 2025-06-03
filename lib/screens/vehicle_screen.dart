import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';
import '../providers/vehicle_provider.dart';
import '../screens/add_vehicle_screen.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final provider = VehicleProvider();
  List<Vehicle> vehicles = [];
  List<Driver> drivers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final fetchedVehicles = await provider.fetchVehicles();
    final fetchedDrivers = await provider.fetchDrivers();
    setState(() {
      vehicles = fetchedVehicles;
      drivers = fetchedDrivers;
    });
  }

  Future<void> _addVehicle(Vehicle newVehicle) async {
    await provider.addVehicle(newVehicle);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final v = vehicles[index];
          return ListTile(
            title: Text(v.model),
            subtitle: Text(v.registration),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddVehicleScreen(
                  vehicles: vehicles,
                  drivers: drivers,
                  onVehicleAdded: (updatedVehicle) async {
                    await provider.updateVehicle(v.id, updatedVehicle);
                    await _loadData();
                  },
                  vehicleToEdit: v,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVehicleScreen(
                vehicles: vehicles,
                drivers: drivers,
                onVehicleAdded: _addVehicle,
              ),
            ),
          );
        },
      ),
    );
  }
}
