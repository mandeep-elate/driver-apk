import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import 'edit_vehicle_screen.dart'; // <-- Corrected import

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;
  final _provider = VehicleProvider();

  VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.model),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedVehicle = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditVehicleScreen(vehicle: vehicle),
                ),
              );

              if (updatedVehicle != null) {
                await _provider.updateVehicle(
                  updatedVehicle,
                  updatedVehicle.id,
                ); // Assuming id is a String

                // ignore: use_build_context_synchronously
                Navigator.pop(context, updatedVehicle); // Return updated data
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _provider.deleteVehicle(vehicle.id.toString());
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${vehicle.model}'),
            Text('Registration: ${vehicle.registration}'),
            Text('Assigned Driver ID: ${vehicle.assignedDriverId ?? "None"}'),
          ],
        ),
      ),
    );
  }
}
