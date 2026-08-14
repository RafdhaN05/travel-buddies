import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/travel_plan.dart';
import '../services/firestore_service.dart';

class PlanDetailsScreen extends StatelessWidget {
  final TravelPlan plan;
  PlanDetailsScreen({super.key, required this.plan});

  final FirestoreService _firestoreService = FirestoreService();
  final String myId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  @override
  Widget build(BuildContext context) {
    bool alreadyJoined = plan.buddies.contains(myId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. BEAUTIFUL HEADER IMAGE
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(plan.destination, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: Hero(
                tag: plan.id, // THE MAGIC: Matches the ID on Home Screen
                child: Image.network(plan.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),

          // 2. TRIP DETAILS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blueAccent),
                      const SizedBox(width: 10),
                      Text(plan.date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("About this trip", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    plan.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.5),
                  ),
                  const Divider(height: 50),
                  
                  // 3. BUDDY LIST SECTION
                  const Text("Buddies Joining", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  if (plan.buddies.isEmpty)
                    const Text("No buddies yet. Be the first to join!")
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: plan.buddies.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white)),
                          title: Text("User: ${plan.buddies[index].substring(0, 5)}..."), // Shows partial ID
                          subtitle: const Text("Ready to explore!"),
                        );
                      },
                    ),
                  const SizedBox(height: 100), // Space for the bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      
      // 4. FIXED JOIN BUTTON AT BOTTOM
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
             _firestoreService.toggleJoinPlan(plan.id, myId, !alreadyJoined);
             Navigator.pop(context); // Go back after joining
          },
          icon: Icon(alreadyJoined ? Icons.check : Icons.group_add),
          label: Text(alreadyJoined ? "Already Joined" : "Join This Trip"),
          style: ElevatedButton.styleFrom(
            backgroundColor: alreadyJoined ? Colors.green : Colors.blueAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }
}