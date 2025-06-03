import 'package:flutter/material.dart';
import '../screens/driver_screen.dart'; // Import the correct DriverScreen
import '../screens/vehicle_screen.dart';
import '../screens/route_stops_screen.dart';
import '../screens/penalty_screen.dart';
import '../screens/deposit_screen.dart';
import '../screens/payment_calculation_screen.dart';
import '../screens/vehicle_damage_screen.dart';
import '../models/driver.dart'; // Import Driver model
import '../models/penalty.dart'; // Import Penalty model
import '../models/deposit.dart'; // Import Deposit model
import '../models/route_stop.dart'; // Import RouteStop model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Driver> drivers =
      []; // This can be updated to use the DriverProvider
  final List<Penalty> penalties = [];
  final List<Deposit> deposits = [];
  final List<RouteStop> routeStops = [];

  // Function to handle adding a deposit
  void _onDepositAdded(Deposit deposit) {
    setState(() {
      deposits.add(deposit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mandeep Elate App',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.1, // Adjust aspect ratio for better button sizing
          children: [
            _buildNavigationButton(
              context,
              'Drivers',
              Icons.person,
              const DriverScreen(), // Corrected navigation to DriverScreen
            ),
            _buildNavigationButton(
              context,
              'Vehicles',
              Icons.local_shipping,
              VehicleScreen(),
            ),
            _buildNavigationButton(
              context,
              'Route Stops',
              Icons.map,
              RouteStopsScreen(), // Use this class name, not RouteStopsScreen
            ),

            _buildNavigationButton(
              context,
              'Penalties',
              Icons.warning,
              PenaltyScreen(
                penalties: penalties, // Pass the penalties list
                drivers: drivers, // Pass the drivers list
                onAddPenalty: (penalty) {
                  setState(() {
                    penalties.add(penalty);
                  });
                },
              ),
            ),
            _buildNavigationButton(
              context,
              'Deposits',
              Icons.money,
              DepositScreen(
                deposits: deposits, // Pass the deposits list
                drivers: drivers, // Pass the drivers list
                onDepositAdded:
                    _onDepositAdded, // Pass the function to add deposits
              ),
            ),
            _buildNavigationButton(
              context,
              'Payment Calculation',
              Icons.calculate,
              const DriverPaymentScreen(), // No parameters needed now
            ),

            _buildNavigationButton(
              context,
              'Vehicle Damages',
              Icons.build,
              VehicleDamageScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.red,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
