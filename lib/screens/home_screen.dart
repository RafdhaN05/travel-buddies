import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';
import '../models/travel_plan.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _auth = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Travel Feed 🌍", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
              Navigator.pop(context);
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                clipBehavior: Clip.antiAlias, // This rounds the image corners
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
                        // Shows a loading spinner while image downloads
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
                          Text(plan.destination, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text("📅 ${plan.date}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Text(plan.description, style: TextStyle(color: Colors.grey[700])),
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

  void _showAddPlanDialog(BuildContext context) {
    final destController = TextEditingController();
    final dateController = TextEditingController();
    final descController = TextEditingController();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // StatefulBuilder allows the dialog to update when an image is picked
        builder: (context, setState) => AlertDialog(
          title: const Text("Share a Travel Plan"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Picker Button
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
                if (selectedImage == null) return; // Basic validation
                
                // Show a loading circle
                showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));

                // 1. Upload to Cloudinary
                String? uploadedUrl = await _cloudinaryService.uploadImage(selectedImage!);

                if (uploadedUrl != null) {
                  // 2. Save to Firestore
                  final newPlan = TravelPlan(
                    id: '',
                    destination: destController.text,
                    date: dateController.text,
                    description: descController.text,
                    postedBy: 'User123',
                    imageUrl: uploadedUrl,
                  );
                  await _firestoreService.addTravelPlan(newPlan);
                }

                Navigator.pop(context); // Close loading circle
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