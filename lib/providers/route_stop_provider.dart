import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_stop.dart';

class RouteStopProvider with ChangeNotifier {
  final CollectionReference _routeStopsCollection = FirebaseFirestore.instance
      .collection('route_stops');

  final List<RouteStop> _items = [];

  List<RouteStop> get items => [..._items];

  // Add RouteStop to Firestore and local list
  Future<void> addRouteStop(RouteStop routeStop) async {
    try {
      await _routeStopsCollection.add(routeStop.toMap());
      _items.add(routeStop);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding route stop: $e');
    }
  }

  // Fetch RouteStops from Firestore
  Future<List<RouteStop>> fetchRouteStops() async {
    try {
      final snapshot = await _routeStopsCollection.get();
      final fetchedStops =
          snapshot.docs.map((doc) {
            // final data = doc.data();
            final data = doc.data() as Map<String, dynamic>;
            return RouteStop.fromMap(data, doc.id);
          }).toList();

      _items
        ..clear()
        ..addAll(fetchedStops);

      notifyListeners();
      return fetchedStops;
    } catch (e) {
      debugPrint('Error fetching route stops: $e');
      return [];
    }
  }

  // Optional: Clear all items (local only)
  void clearStops() {
    _items.clear();
    notifyListeners();
  }
}
