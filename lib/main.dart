import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/driver_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/app_data.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppData()),
        ChangeNotifierProvider(create: (_) {
          final provider = DriverProvider();
          provider.initialize(); // ✅ safely load data
          return provider;
        }),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ✅ optional but helpful
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class DriverPayment {
  String driverName;
  DateTime paymentDate;
  double paymentAmount;

  DriverPayment({
    required this.driverName,
    required this.paymentDate,
    required this.paymentAmount,
  });
}

class YourWidget extends StatelessWidget {
  const YourWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        DateTime now = DateTime.now();
        DateTime startDate = now.subtract(const Duration(days: 7));
        List<DriverPayment> driverPayments = [];
        var appData = Provider.of<AppData>(context, listen: false);

        for (var driver in appData.drivers) {
          double payment = appData.calculateDriverPayment(driver, startDate, now);

          driverPayments.add(DriverPayment(
            driverName: driver.name,
            paymentDate: now,
            paymentAmount: payment,
          ));
          // ignore: avoid_print
          print("Payment for ${driver.name}: $payment");
        }
      },
      child: const Text("Calculate Payments"),
    );
  }
}
