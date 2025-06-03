import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/driver.dart';
import '../models/penalty.dart';

class AddPenaltyScreen extends StatefulWidget {
  final void Function(Penalty penalty) onPenaltyAdded;

  const AddPenaltyScreen({
    super.key,
    required this.onPenaltyAdded, required List<Driver> drivers, required Function(Penalty p1) onAddPenalty,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddPenaltyScreenState createState() => _AddPenaltyScreenState();
}

class _AddPenaltyScreenState extends State<AddPenaltyScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Driver> _drivers = [];
  int? _selectedDriverId;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _amount = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    final snapshot = await FirebaseFirestore.instance.collection('drivers').get();
    final drivers = snapshot.docs.map((doc) {
      final data = doc.data();
      return Driver(
        id: data['id'], // Assumes 'id' is an int in Firestore
        name: data['name'] ?? 'Unnamed', contactInfo: '', paymentType: '',
      );
    }).toList();

    setState(() {
      _drivers = drivers;
      _isLoading = false;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDriverId != null) {
      _formKey.currentState!.save();

      final penalty = Penalty(
        id: '',
        driverId: _selectedDriverId.toString(),
        date: _selectedDate,
        amount: _amount,
      );

      await FirebaseFirestore.instance.collection('penalty').add({
        'driver_id': penalty.driverId,
        'date': penalty.date,
        'amount': penalty.amount,
      });

      widget.onPenaltyAdded(penalty);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Penalty')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _selectedDriverId,
                      decoration: const InputDecoration(labelText: 'Driver'),
                      items: _drivers.map((driver) {
                        return DropdownMenuItem<int>(
                          value: driver.id,
                          child: Text(driver.name),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedDriverId = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a driver' : null,
                      hint: const Text('Select Driver'),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Date: $_selectedDate"),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Select Date'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Amount'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) => _amount = value ?? '',
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _selectedDriverId == null ? null : _submitForm,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
