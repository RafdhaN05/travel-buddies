import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_plan.dart';

class FirestoreService {
  // 1. Get the collection of "plans" from Firestore
  final CollectionReference _plansCollection =
      FirebaseFirestore.instance.collection('plans');

  // 2. ADD a new travel plan
  Future<void> addTravelPlan(TravelPlan plan) async {
    try {
      await _plansCollection.add(plan.toJson());
    } catch (e) {
      print("Error adding plan: $e");
    }
  }

  // 3. GET all travel plans (Real-time Stream)
  Stream<List<TravelPlan>> getTravelPlans() {
    return _plansCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Print each document received from Firestore
        print("REAL-TIME DATA RECEIVED: ${doc.data()}");

        return TravelPlan.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }
}