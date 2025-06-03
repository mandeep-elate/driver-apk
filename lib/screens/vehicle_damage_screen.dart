import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/vehicle_damage.dart';
import 'add_vehicle_damage_screen.dart';

class VehicleDamageScreen extends StatefulWidget {
  const VehicleDamageScreen({super.key});

  @override
  _VehicleDamageScreenState createState() => _VehicleDamageScreenState();
}

class _VehicleDamageScreenState extends State<VehicleDamageScreen> {
  List<VehicleDamage> vehicleDamages = [];

  @override
  void initState() {
    super.initState();
    fetchDamages();
  }

  Future<void> fetchDamages() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('vehicle_damages')
            .orderBy('date', descending: true)
            .get();

    setState(() {
      vehicleDamages =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return VehicleDamage(
              vehicleId: data['vehicleId'] ?? '',
              vehicleModel: data['vehicleModel'] ?? '',
              date: data['date'] ?? '',
              description: data['description'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
            );
          }).toList();
    });
  }

  void _addVehicleDamage(VehicleDamage damage) {
    setState(() {
      vehicleDamages.insert(0, damage);
    });
  }

  void _navigateToNewDamageScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVehicleDamageScreen()),
    );

    if (result != null && result is VehicleDamage) {
      _addVehicleDamage(result);
    }

    fetchDamages(); // Refresh the list after adding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Damages')),
      body:
          vehicleDamages.isEmpty
              ? const Center(child: Text('No damages reported yet.'))
              : ListView.builder(
                itemCount: vehicleDamages.length,
                itemBuilder: (context, index) {
                  final damage = vehicleDamages[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading:
                          damage.imageUrl.isNotEmpty
                              ? Image.network(
                                damage.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                    ),
                              )
                              : const Icon(Icons.image_not_supported, size: 60),
                      title: Text(
                        'Vehicle: ${damage.vehicleModel}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${damage.date.split('T').first}'),
                          Text('Description: ${damage.description}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewDamageScreen(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
