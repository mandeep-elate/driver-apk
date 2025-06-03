import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/deposit.dart';
import '../models/driver.dart';

class AddDepositScreen extends StatefulWidget {
  final List<Driver> drivers;
  final void Function(Deposit deposit) onDepositAdded;

  const AddDepositScreen({
    super.key,
    required this.drivers,
    required this.onDepositAdded,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddDepositScreenState createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends State<AddDepositScreen> {
  final _formKey = GlobalKey<FormState>();

  // Store selected driver's id as int (not String)
  int? _selectedDriverId;

  // Date string in yyyy-MM-dd format
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Amount as string
  String _amount = '';

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDriverId != null) {
      _formKey.currentState!.save();

      final deposit = Deposit(
        id: '',
        driverId: _selectedDriverId!.toString(), // convert int to String
        date: _selectedDate,
        amount: _amount,
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('deposits').add({
        'driverId': deposit.driverId,
        'date': deposit.date,
        'amount': deposit.amount,
      });

      widget.onDepositAdded(deposit);
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
      appBar: AppBar(title: const Text('Add Deposit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedDriverId,
                decoration: const InputDecoration(labelText: 'Driver'),
                items:
                    widget.drivers.map((driver) {
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
                validator:
                    (value) => value == null ? 'Please select a driver' : null,
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
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
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
