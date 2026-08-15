// ignore_for_file: no_leading_underscores_for_local_identifiers, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; 
import '../services/firestore_service.dart';
import '../models/travel_plan.dart';
import '../services/cloudinary_service.dart';

import 'plan_details_screen.dart';
import 'profile_screen.dart';
import 'my_trips_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // 1. Current index for navigation
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // HELPER FUNCTION: This builds your "Travel Feed"
  Widget _buildTravelFeed(String myId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search destination...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Color(0xFF0D47A1)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<TravelPlan>>(
            stream: _firestoreService.getTravelPlans(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final allPlans = snapshot.data ?? [];
              final filteredPlans = allPlans.where((plan) => plan.destination.toLowerCase().contains(_searchQuery)).toList();
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: filteredPlans.length,
                itemBuilder: (context, index) {
                  final plan = filteredPlans[index];
                  bool alreadyJoined = plan.buddies.contains(myId);
                  bool isOwner = plan.postedBy == myId;
                  return _buildTravelCard(context, plan, alreadyJoined, isOwner, myId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String myId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    // 2. FINAL UPDATED SCREEN LIST (3 items now)
    final List<Widget> _screens = [
      _buildTravelFeed(myId),   // Index 0: Home Feed
      MyTripsScreen(),          // Index 1: Real My Trips Screen
      const ProfileScreen(),    // Index 2: Real Profile Screen
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF0D47A1),
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        // Dynamic Title based on selected tab
        title: Text(
          _selectedIndex == 0 ? "Travel Feed" : _selectedIndex == 1 ? "My Trips" : "My Profile",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      
      body: _screens[_selectedIndex],

      // 3. FAB logic maintained: Only show on Feed
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0D47A1),
        onPressed: () => _showAddPlanDialog(context),
        label: const Text("New Trip", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ) : null,
      
      // 4. FINAL UPDATED NAVIGATION BAR (3 items now)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, 
        onTap: (index) {
          setState(() {
            _selectedIndex = index; 
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: "My Trips"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildTravelCard(BuildContext context, TravelPlan plan, bool alreadyJoined, bool isOwner, String myId) {
    double progress = plan.buddies.isEmpty ? 0.0 : plan.buddies.length / plan.maxBuddies;
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PlanDetailsScreen(plan: plan)));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (plan.imageUrl.isNotEmpty)
                  Hero(
                    tag: plan.id,
                    child: Image.network(plan.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                if (isOwner)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, plan.id),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(plan.destination, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month, color: Colors.blue, size: 16),
                          const SizedBox(width: 5),
                          Text(plan.date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(plan.description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text("${plan.buddies.length} Buddies Joined", style: const TextStyle(fontWeight: FontWeight.w600)), 
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress, 
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      color: Colors.blue,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alreadyJoined ? Colors.green : const Color(0xFF0D47A1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _firestoreService.toggleJoinPlan(plan.id, myId, !alreadyJoined),
                      child: Text(alreadyJoined ? "Joined ✓" : "Join Trip", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlanDialog(BuildContext context) {
    final destController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Plan a New Adventure"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (img != null) setDialogState(() => selectedImage = img);
                  },
                  child: Container(
                    height: 120, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
                    child: selectedImage == null 
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                      : const Icon(Icons.check_circle, color: Colors.green, size: 40),
                  ),
                ),
                TextField(controller: destController, decoration: const InputDecoration(labelText: "Destination")),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(selectedDate == null ? "Select Date" : DateFormat('dd MMM yyyy').format(selectedDate!)),
                  trailing: const Icon(Icons.calendar_month, color: Color(0xFF0D47A1)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (selectedImage == null || selectedDate == null) return;
                showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
                String? url = await _cloudinaryService.uploadImage(selectedImage!);
                if (url != null) {
                  final newPlan = TravelPlan(
                    id: '',
                    destination: destController.text,
                    date: DateFormat('dd MMM yyyy').format(selectedDate!),
                    description: descController.text,
                    postedBy: FirebaseAuth.instance.currentUser?.uid ?? "unknown",
                    imageUrl: url,
                    buddies: [],
                    maxBuddies: 10, 
                  );
                  await _firestoreService.addTravelPlan(newPlan);
                }
                Navigator.pop(context); 
                Navigator.pop(context); 
              },
              child: const Text("Post Trip"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Trip?"),
        content: const Text("Are you sure you want to remove this trip?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () async {
            await _firestoreService.deleteTravelPlan(planId);
            Navigator.pop(context);
          }, child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}