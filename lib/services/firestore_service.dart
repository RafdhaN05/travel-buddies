import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_plan.dart';

class FirestoreService {
  // 1. Get the collection of "plans" from Firestore
  final CollectionReference _plansCollection =
      FirebaseFirestore.instance.collection('plans');

  // 2. CREATE: Add a new travel plan
  Future<void> addTravelPlan(TravelPlan plan) async {
    try {
      await _plansCollection.add(plan.toJson());
    } catch (e) {
      print("Error adding plan: $e");
    }
  }

  // 3. READ: Get all travel plans (Real-time Stream)
  Stream<List<TravelPlan>> getTravelPlans() {
    return _plansCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        print("REAL-TIME DATA RECEIVED: ${doc.data()}");

        return TravelPlan.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // 4. UPDATE: Join or Leave a travel plan
  Future<void> toggleJoinPlan(String planId, String userId, bool isJoining) async {
    try {
      if (isJoining) {
        // Add User ID to the array
        await _plansCollection.doc(planId).update({
          'buddies': FieldValue.arrayUnion([userId])
        });
      } else {
        // Remove User ID from the array
        await _plansCollection.doc(planId).update({
          'buddies': FieldValue.arrayRemove([userId])
        });
      }
    } catch (e) {
      print("Error joining plan: $e");
    }
  }

  // 5. DELETE: Remove a travel plan (ADDED THIS)
  Future<void> deleteTravelPlan(String planId) async {
    try {
      await _plansCollection.doc(planId).delete();
      print("Plan deleted successfully");
    } catch (e) {
      print("Error deleting plan: $e");
    }
  }
}