import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';
import '../providers/vehicle_provider.dart';
import '../providers/driver_provider.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  // ignore: library_private_types_in_public_api
  _EditVehicleScreenState createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _model;
  late String _registration;
  Driver? _selectedDriver;

  List<Driver> _drivers = [];
  final VehicleProvider _vehicleProvider = VehicleProvider();
  final DriverProvider _driverProvider = DriverProvider();

  @override
  void initState() {
    super.initState();
    _model = widget.vehicle.model;
    _registration = widget.vehicle.registration;
    _loadDrivers();
  }

 Future<void> _loadDrivers() async {
  try {
    final drivers = await _driverProvider.fetchDrivers();
    setState(() {
      _drivers = drivers;
      _selectedDriver = drivers.firstWhere(
        (d) => d.id.toString() == widget.vehicle.assignedDriverId,
      ) as Driver?; // Cast the result to nullable Driver
    });
  } catch (e) {
    print('Error loading drivers: $e');
  }
}


  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedVehicle = Vehicle(
        id: widget.vehicle.id,
        model: _model,
        registration: _registration,
        assignedDriverId: _selectedDriver?.id.toString() ?? '',
      );

      try {
        await _vehicleProvider.updateVehicle(
          updatedVehicle.id.toString(),
          updatedVehicle,
        );
        if (mounted) Navigator.of(context).pop(updatedVehicle);
      } catch (e) {
        print('Error updating vehicle: $e');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update vehicle')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vehicle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _drivers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _model,
                      decoration: const InputDecoration(labelText: 'Model'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter model' : null,
                      onSaved: (value) => _model = value ?? '',
                    ),
                    TextFormField(
                      initialValue: _registration,
                      decoration: const InputDecoration(labelText: 'Registration'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please enter registration' : null,
                      onSaved: (value) => _registration = value ?? '',
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
                      validator: (value) =>
                          value == null ? 'Please select a driver' : null,
                      onSaved: (value) => _selectedDriver = value,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
