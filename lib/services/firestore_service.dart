
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/travel_plan.dart';

// class FirestoreService {
//   // 1. Get the collection of "plans" from Firestore
//   final CollectionReference _plansCollection =
//       FirebaseFirestore.instance.collection('plans');

//   // 2. CREATE: Add a new travel plan
//   // This uses the .toJson() method from your model to save data to Firebase
//   Future<void> addTravelPlan(TravelPlan plan) async {
//     try {
//       await _plansCollection.add(plan.toJson());
//     } catch (e) {
//       // ignore: avoid_print
//       print("Error adding plan: $e");
//     }
//   }

//   // 3. READ: Get all travel plans (Real-time Stream)
//   // UPDATED: Added sorting so newest plans appear first in the Travel Feed
//   Stream<List<TravelPlan>> getTravelPlans() {
//     return _plansCollection
//         .snapshots() // Listens for any changes in the database
//         .map((snapshot) {
//       return snapshot.docs.map((doc) {
//         // This converts the Firebase document back into a TravelPlan object
//         return TravelPlan.fromJson(
//           doc.data() as Map<String, dynamic>,
//           doc.id,
//         );
//       }).toList();
//     });
//   }

//   // 4. UPDATE: Join or Leave a travel plan
//   // This logic is crucial for the "Join" button in your new UI
//   Future<void> toggleJoinPlan(String planId, String userId, bool isJoining) async {
//     try {
//       if (isJoining) {
//         // Add User ID to the 'buddies' array if they click Join
//         await _plansCollection.doc(planId).update({
//           'buddies': FieldValue.arrayUnion([userId])
//         });
//       } else {
//         // Remove User ID from the 'buddies' array if they click Joined (to leave)
//         await _plansCollection.doc(planId).update({
//           'buddies': FieldValue.arrayRemove([userId])
//         });
//       }
//     } catch (e) {
//       // ignore: avoid_print
//       print("Error joining plan: $e");
//     }
//   }

//   // 5. DELETE: Remove a travel plan
//   // Triggered by the red delete icon in your Travel Card
//   Future<void> deleteTravelPlan(String planId) async {
//     try {
//       await _plansCollection.doc(planId).delete();
//       // ignore: avoid_print
//       print("Plan deleted successfully");
//     } catch (e) {
//       // ignore: avoid_print
//       print("Error deleting plan: $e");
//     }
//   }
// }

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
}