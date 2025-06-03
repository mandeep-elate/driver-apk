import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class AddVehicleDamageScreen extends StatefulWidget {
  const AddVehicleDamageScreen({super.key});

  @override
  _AddVehicleDamageScreenState createState() => _AddVehicleDamageScreenState();
}

class _AddVehicleDamageScreenState extends State<AddVehicleDamageScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVehicleId;
  String? _selectedVehicleModel;
  String _description = '';
  File? _pickedImage;
  DateTime? _selectedDate;

  List<Map<String, String>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('vehicles').get();
    setState(() {
      _vehicles =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'model': (data['model'] ?? 'Unknown Model').toString(),
            };
          }).toList();
    });
  }

  Future<void> pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _pickedImage = File(picked.path);
        });
      }
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Permission Required'),
              content: Text(
                'Please enable photo access in settings to select images.',
              ),
              actions: [
                TextButton(
                  child: Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied to access gallery')),
      );
    }
  }

  Future<String?> uploadImageToServer(File imageFile) async {
    final uri = Uri.parse('https://drivercdn.elateagency.com/upload.php');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBody);

    if (jsonResponse['success'] == true) {
      return jsonResponse['url'];
    } else {
      print('Upload error: ${jsonResponse['error']}');
      return null;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        _selectedVehicleId != null &&
        _selectedVehicleModel != null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select a date')));
        return;
      }

      if (_pickedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select an image')));
        return;
      }

      _formKey.currentState!.save();

      try {
        final imageUrl = await uploadImageToServer(_pickedImage!);
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }

        final damageData = {
          'vehicleId': _selectedVehicleId!,
          'vehicleModel': _selectedVehicleModel!,
          'date': _selectedDate!.toIso8601String(),
          'description': _description,
          'imageUrl': imageUrl,
        };

        await FirebaseFirestore.instance
            .collection('vehicle_damages')
            .add(damageData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Damage record added successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit damage record')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Vehicle Damage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _vehicles.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleId,
                        items:
                            _vehicles.map((vehicle) {
                              return DropdownMenuItem(
                                value: vehicle['id'],
                                child: Text(vehicle['model'] ?? 'Unknown'),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleId = value;
                            _selectedVehicleModel =
                                _vehicles.firstWhere(
                                  (v) => v['id'] == value,
                                )['model'];
                          });
                        },
                        decoration: InputDecoration(labelText: 'Vehicle'),
                        validator:
                            (value) =>
                                value == null
                                    ? 'Please select a vehicle'
                                    : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onSaved: (value) => _description = value ?? '',
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter a description' : null,
                      ),
                      SizedBox(height: 10),
                      Text('Pick Image:'),
                      _pickedImage != null
                          ? Image.file(_pickedImage!, height: 150)
                          : Text('No image selected'),
                      TextButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Choose Image'),
                        onPressed: pickImage,
                      ),
                      SizedBox(height: 10),
                      Text('Select Date:'),
                      TextButton.icon(
                        icon: Icon(Icons.calendar_today),
                        label: Text(
                          _selectedDate == null
                              ? 'Pick Date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                        onPressed: () => _pickDate(context),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
