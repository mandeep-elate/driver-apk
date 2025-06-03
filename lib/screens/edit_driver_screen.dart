import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/driver.dart';
import '../providers/driver_provider.dart';

class EditDriverScreen extends StatefulWidget {
  final Driver driver;

  const EditDriverScreen({super.key, required this.driver});

  @override
  // ignore: library_private_types_in_public_api
  _EditDriverScreenState createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _contactInfo;
  late String _paymentType;
  late String _perStopRate;
  late String _fixedDailyRate;

  @override
  void initState() {
    super.initState();
    _name = widget.driver.name;
    _contactInfo = widget.driver.contactInfo;
    _paymentType = widget.driver.paymentType;
    _perStopRate = widget.driver.perStopRate.toString();
    _fixedDailyRate = widget.driver.fixedDailyRate.toString();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedDriver = Driver(
        id: widget.driver.id,
        name: _name,
        contactInfo: _contactInfo,
        paymentType: _paymentType,
        perStopRate:
            _paymentType == 'per_stop' ? double.tryParse(_perStopRate) ?? 0.0 : 0.0,
        fixedDailyRate:
            _paymentType == 'fixed' ? double.tryParse(_fixedDailyRate) ?? 0.0 : 0.0,
      );

      await Provider.of<DriverProvider>(context, listen: false)
          .editDriver(updatedDriver);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Driver'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value ?? '',
              ),
              TextFormField(
                initialValue: _contactInfo,
                decoration: const InputDecoration(labelText: 'Contact Info'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter contact info' : null,
                onSaved: (value) => _contactInfo = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: const InputDecoration(labelText: 'Payment Type'),
                items: ['per_stop', 'fixed'].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value == 'per_stop' ? 'Per Stop' : 'Fixed Daily'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentType = value!;
                  });
                },
                onSaved: (value) => _paymentType = value ?? 'per_stop',
              ),
              if (_paymentType == 'per_stop')
                TextFormField(
                  initialValue: _perStopRate,
                  decoration: const InputDecoration(labelText: 'Per Stop Rate'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_paymentType == 'per_stop') {
                      if (value == null || value.isEmpty) {
                        return 'Enter per stop rate';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) => _perStopRate = value ?? '',
                ),
              if (_paymentType == 'fixed')
                TextFormField(
                  initialValue: _fixedDailyRate,
                  decoration: const InputDecoration(labelText: 'Fixed Daily Rate'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_paymentType == 'fixed') {
                      if (value == null || value.isEmpty) {
                        return 'Enter fixed rate';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) => _fixedDailyRate = value ?? '',
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
