import 'package:flutter/material.dart';
import 'package:myapp/providers/driver_provider.dart';
import 'package:provider/provider.dart';

class DriverDetailsScreen extends StatelessWidget {
  final int driverId;

  const DriverDetailsScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    // Fetch the driver by id from the provider
    final driverProvider = Provider.of<DriverProvider>(context);
    // Using `firstWhere` to fetch the driver based on the driverId
    final driver = driverProvider.drivers.firstWhere(
      (driver) => driver.id == driverId,
      orElse: () => throw Exception('Driver not found!'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${driver.name}', style: TextStyle(fontSize: 18)),
            Text('Contact Info: ${driver.contactInfo}', style: TextStyle(fontSize: 18)),
            Text('Payment Type: ${driver.paymentType}', style: TextStyle(fontSize: 18)),
            if (driver.paymentType == 'per_stop')
              Text('Per Stop Rate: ${driver.perStopRate}', style: TextStyle(fontSize: 18)),
            if (driver.paymentType == 'fixed')
              Text('Fixed Daily Rate: ${driver.fixedDailyRate}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Show confirmation dialog for deleting the driver
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Delete"),
                          content: Text("Are you sure you want to delete this driver?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                driverProvider.deleteDriver(driver.id);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
