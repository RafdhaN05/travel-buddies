// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/travel_plan.dart';

class FirestoreService {
  final CollectionReference _plansCollection =
      FirebaseFirestore.instance.collection('plans');

  Future<void> addTravelPlan(TravelPlan plan) async {
    try {
      await _plansCollection.add(plan.toJson());
    } catch (e) {
      print("Error adding plan: $e");
    }
  }

  Stream<List<TravelPlan>> getTravelPlans() {
    // This print will tell us if the function is even being called
    print("!!! FIRESTORE: Stream requested from Home Screen !!!");

    return _plansCollection.snapshots().map((snapshot) {
      // This will tell us how many documents Firebase sent back
      print("!!! FIRESTORE: Received ${snapshot.docs.length} documents from Firebase !!!");

      return snapshot.docs.map((doc) {
        print("!!! FIRESTORE: Loading trip to ${doc['destination']} !!!");
        return TravelPlan.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  Future<void> toggleJoinPlan(String planId, String userId, bool isJoining) async {
    try {
      if (isJoining) {
        await _plansCollection.doc(planId).update({'buddies': FieldValue.arrayUnion([userId])});
      } else {
        await _plansCollection.doc(planId).update({'buddies': FieldValue.arrayRemove([userId])});
      }
    } catch (e) {
      print("Error joining plan: $e");
    }
  }

  Future<void> deleteTravelPlan(String planId) async {
    try {
      await _plansCollection.doc(planId).delete();
      print("Plan deleted successfully");
    } catch (e) {
      print("Error deleting plan: $e");
    }
  }

  // 5. GET ONLY my posted trips
  Stream<List<TravelPlan>> getMyPostedTrips(String userId) {
    return _plansCollection
        .where('postedBy', isEqualTo: userId) // Filter: I am the owner
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TravelPlan.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 6. GET ONLY my joined trips
  Stream<List<TravelPlan>> getMyJoinedTrips(String userId) {
    return _plansCollection
        .where('buddies', arrayContains: userId) // Filter: I am in the list
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TravelPlan.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}