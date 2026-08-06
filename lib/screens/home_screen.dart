import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/travel_plan.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _auth = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  Widget build(BuildContext context) {
    // Get the real ID of the logged-in user
    final String myId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back navigation arrow
        title: const Text("Travel Feed 🌍", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TravelPlan>>(
        stream: _firestoreService.getTravelPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final plans = snapshot.data ?? [];
          if (plans.isEmpty) {
            return const Center(child: Text("No travel plans yet. Be the first!"));
          }

          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              bool alreadyJoined = plan.buddies.contains(myId);
              bool isOwner = plan.postedBy == myId; // Check if I posted this

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE SECTION
                    if (plan.imageUrl.isNotEmpty)
                      Image.network(
                        plan.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    
                    // TEXT SECTION
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(plan.destination, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              
                              // DELETE BUTTON (Only visible to owner)
                              if (isOwner)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(context, plan.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text("📅 ${plan.date}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Text(plan.description, style: TextStyle(color: Colors.grey[700])),
                          
                          const Divider(height: 30),

                          // SOCIAL SECTION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan.buddies.length == 1 
                                  ? "1 Buddy joined" 
                                  : "${plan.buddies.length} Buddies joined",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _firestoreService.toggleJoinPlan(plan.id, myId, !alreadyJoined);
                                },
                                icon: Icon(alreadyJoined ? Icons.check : Icons.person_add, size: 18),
                                label: Text(alreadyJoined ? "Joined" : "Join"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: alreadyJoined ? Colors.green : Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanDialog(context),
        label: const Text("New Trip"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // DIALOG TO CONFIRM DELETE
  void _showDeleteDialog(BuildContext context, String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Trip?"),
        content: const Text("Are you sure you want to remove this travel plan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _firestoreService.deleteTravelPlan(planId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddPlanDialog(BuildContext context) {
    final destController = TextEditingController();
    final dateController = TextEditingController();
    final descController = TextEditingController();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Share a Travel Plan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => selectedImage = image);
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: selectedImage == null 
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.camera_alt, size: 40), Text("Add Photo")],
                        )
                      : const Center(child: Icon(Icons.check_circle, color: Colors.green, size: 50)),
                  ),
                ),
                TextField(controller: destController, decoration: const InputDecoration(hintText: "Destination")),
                TextField(controller: dateController, decoration: const InputDecoration(hintText: "Date")),
                TextField(controller: descController, decoration: const InputDecoration(hintText: "Description")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (selectedImage == null) return;
                
                showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));

                String? uploadedUrl = await _cloudinaryService.uploadImage(selectedImage!);

                if (uploadedUrl != null) {
                  final newPlan = TravelPlan(
                    id: '',
                    destination: destController.text,
                    date: dateController.text,
                    description: descController.text,
                    postedBy: FirebaseAuth.instance.currentUser?.uid ?? "unknown",
                    imageUrl: uploadedUrl,
                    buddies: [], 
                  );
                  await _firestoreService.addTravelPlan(newPlan);
                }

                Navigator.pop(context); // Close loading
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Post"),
            ),
          ],
        ),
      ),
    );
  }
}