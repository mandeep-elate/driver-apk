import 'package:flutter/material.dart';
import 'package:myapp/models/driver.dart';
// import 'package:myapp/providers/deposit_provider.dart';
import 'package:myapp/providers/driver_provider.dart';
import 'package:provider/provider.dart';


class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddDriverScreenState createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _perStopRateController = TextEditingController();
  final _fixedDailyRateController = TextEditingController();

  String _selectedPaymentType = 'per_stop';
void _saveDriver() async {
  if (_formKey.currentState!.validate()) {
    final driverProvider = Provider.of<DriverProvider>(context, listen: false);
    final newDriver = Driver(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      contactInfo: _contactInfoController.text,
      paymentType: _selectedPaymentType,
      perStopRate: _selectedPaymentType == 'per_stop'
          ? double.tryParse(_perStopRateController.text) ?? 0.0
          : 0.0,
      fixedDailyRate: _selectedPaymentType == 'fixed'
          ? double.tryParse(_fixedDailyRateController.text) ?? 0.0
          : 0.0,
    );

    await driverProvider.addDriver(newDriver); // Use await
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Driver')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactInfoController,
                decoration: InputDecoration(labelText: 'Contact Info'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter contact info';
                  }
                  return null;
                },
              ),
              DropdownButton<String>(
                value: _selectedPaymentType,
                items: ['per_stop', 'fixed']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentType = value!;
                  });
                },
              ),
              if (_selectedPaymentType == 'per_stop')
                TextFormField(
                  controller: _perStopRateController,
                  decoration: InputDecoration(labelText: 'Per Stop Rate'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a per stop rate';
                    }
                    return null;
                  },
                ),
              if (_selectedPaymentType == 'fixed')
                TextFormField(
                  controller: _fixedDailyRateController,
                  decoration: InputDecoration(labelText: 'Fixed Daily Rate'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a fixed daily rate';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDriver,
                child: Text('Save Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
