import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/driver_provider.dart';
import '../screens/edit_driver_screen.dart';
import '../screens/add_driver_screen.dart';

class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverProvider = Provider.of<DriverProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      body: driverProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : driverProvider.drivers.isEmpty
              ? const Center(child: Text('No drivers found.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await driverProvider.fetchDrivers();
                  },
                  child: ListView.builder(
                    itemCount: driverProvider.drivers.length,
                    itemBuilder: (ctx, index) {
                      final driver = driverProvider.drivers[index];

                      return ListTile(
                        title: Text(driver.name),
                        subtitle: Text(driver.paymentType == 'per_stop'
                            ? 'Per Stop Rate: ${driver.perStopRate}'
                            : 'Fixed Daily Rate: ${driver.fixedDailyRate}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => EditDriverScreen(driver: driver),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDriverScreen()),
          );
          await driverProvider.fetchDrivers(); // Refresh after add
        },
        tooltip: 'Add Driver',
        child: const Icon(Icons.add),
      ),
    );
  }
}
