import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/driver.dart';
import '../providers/vehicle_provider.dart'; // Used here to fetch drivers

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _provider = VehicleProvider(); // Reusing to fetch drivers
  final _stopsController = TextEditingController();

  Driver? _selectedDriver;
  DateTime? _selectedDate;
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

  Future<void> _saveRouteStop() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDriver == null ||
        _selectedDate == null) {
      return;
    }

    final routeStopData = {
      'driverId': _selectedDriver!.id,
      'stops': int.parse(_stopsController.text),
      'date': _selectedDate!.toIso8601String(),
    };

    await FirebaseFirestore.instance
        .collection('route_stops')
        .add(routeStopData);

    ScaffoldMessenger.of(
      // ignore: use_build_context_synchronously
      context,
    ).showSnackBar(const SnackBar(content: Text('Route stop saved')));

    setState(() {
      _selectedDriver = null;
      _selectedDate = null;
      _stopsController.clear();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _stopsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Route Stop'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDriver?.id.toString(),
                decoration: const InputDecoration(labelText: 'Select Driver'),
                items:
                    _drivers.map((driver) {
                      return DropdownMenuItem<String>(
                        value: driver.id.toString(),
                        child: Text(driver.name),
                      );
                    }).toList(),
                onChanged: (String? driverIdStr) {
                  if (driverIdStr == null) return;
                  final driverId = int.parse(driverIdStr);
                  setState(() {
                    _selectedDriver = _drivers.firstWhere(
                      (d) => d.id == driverId,
                    );
                  });
                },
                validator:
                    (value) => value == null ? 'Please select a driver' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _stopsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Number of Stops',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter number of stops'
                            : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    // Inside your widget:
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveRouteStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
