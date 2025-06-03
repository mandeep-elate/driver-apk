import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';
import '../providers/vehicle_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Future<void> Function(Vehicle newVehicle) onVehicleAdded;
  final List<Driver> drivers;
  final Vehicle? vehicleToEdit;

  const AddVehicleScreen({
    super.key,
    required this.vehicles,
    required this.onVehicleAdded,
    required this.drivers,
    this.vehicleToEdit,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _registrationController = TextEditingController();
  Driver? _selectedDriver;

  final _provider = VehicleProvider();
  List<Driver> _drivers = [];

  bool get isEditing => widget.vehicleToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    if (isEditing) {
      final v = widget.vehicleToEdit!;
      _modelController.text = v.model;
      _registrationController.text = v.registration;
      try {
        _selectedDriver = widget.drivers.firstWhere(
          (d) => d.id.toString() == v.assignedDriverId,
        );
      } catch (_) {
        _selectedDriver = null;
      }
    }
  }

  Future<void> _loadDrivers() async {
    final fetchedDrivers = await _provider.fetchDrivers();
    setState(() {
      _drivers = fetchedDrivers;
    });
  }

  @override
  void dispose() {
    _modelController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

Future<void> _saveVehicle() async {
  if (_formKey.currentState!.validate()) {
    final vehicle = Vehicle(
      id: isEditing
          ? widget.vehicleToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString(), // Convert to string if needed
      model: _modelController.text,
      registration: _registrationController.text,
      assignedDriverId: _selectedDriver?.id.toString(), // Ensure this is the correct format
    );

    await widget.onVehicleAdded(vehicle);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Vehicle' : 'Add Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator:
                    (value) => value!.isEmpty ? 'Please enter the model' : null,
              ),
              TextFormField(
                controller: _registrationController,
                decoration: const InputDecoration(labelText: 'Registration'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter the registration' : null,
              ),
              DropdownButtonFormField<Driver>(
                value: _selectedDriver,
                decoration: const InputDecoration(labelText: 'Assigned Driver'),
                items: [
                  const DropdownMenuItem<Driver>(
                    value: null,
                    child: Text('Select Driver'),
                  ),
                  ..._drivers.map(
                    (driver) => DropdownMenuItem<Driver>(
                      value: driver,
                      child: Text(driver.name),
                    ),
                  ),
                ],
                onChanged: (driver) {
                  setState(() {
                    _selectedDriver = driver;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVehicle,
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
