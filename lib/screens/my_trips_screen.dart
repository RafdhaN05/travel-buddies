import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/travel_plan.dart';

class MyTripsScreen extends StatelessWidget {
  MyTripsScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();
  final String myId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true, // Ensures the image touches the top navigation bar
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFF),
          body: Column(
            children: [
              // --- SECTION 1: IMAGE HEADER ---
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.asset(
                        'assets/Profile_Image.png', // THE IMAGE YOU SENT
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Dark overlay to make the white text readable
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Center(
                      child: Text(
                        "My Trips",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // --- SECTION 2: THE TABS ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFF0D47A1).withOpacity(0.1),
                  ),
                  labelColor: const Color(0xFF0D47A1),
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(icon: Icon(Icons.send), text: "Posted"),
                    Tab(icon: Icon(Icons.group), text: "Joined"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- SECTION 3: TAB VIEWS ---
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTripList(_firestoreService.getMyPostedTrips(myId)),
                    _buildTripList(_firestoreService.getMyJoinedTrips(myId)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripList(Stream<List<TravelPlan>> stream) {
    return StreamBuilder<List<TravelPlan>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final plans = snapshot.data ?? [];

        if (plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.luggage_outlined, size: 80, color: const Color(0xFF0D47A1).withOpacity(0.2)),
                const SizedBox(height: 10),
                const Text("No trips yet!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildProfessionalCard(plan);
          },
        );
      },
    );
  }

  Widget _buildProfessionalCard(TravelPlan plan) {
    double progress = plan.buddies.isEmpty ? 0.0 : plan.buddies.length / plan.maxBuddies;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: plan.imageUrl.isNotEmpty 
              ? Image.network(plan.imageUrl, width: 90, height: 90, fit: BoxFit.cover)
              : Container(width: 90, height: 90, color: Colors.grey[200]),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.destination, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                    const SizedBox(width: 5),
                    Text(plan.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(plan.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Colors.blue),
                    const SizedBox(width: 5),
                    Text("${plan.buddies.length} Buddies Joined", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress, 
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    color: Colors.blue,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }
}