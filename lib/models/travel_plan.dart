class TravelPlan {
  final String id;
  final String destination;
  final String date;
  final String description;
  final String postedBy; // Kept this so the Delete/Bin icon logic works
  final String imageUrl; 
  final List<String> buddies; 
  final int maxBuddies; 

  TravelPlan({
    required this.id,
    required this.destination,
    required this.date,
    required this.description,
    required this.postedBy,
    required this.imageUrl,
    required this.buddies,
    required this.maxBuddies,
  });

  // --- FROM JSON: Converts Firebase data into this Dart Object ---
  factory TravelPlan.fromJson(Map<String, dynamic> json, String id) {
    return TravelPlan(
      id: id,
      // The ?? ensures that if a field is missing in Firebase, the app won't crash
      destination: json['destination'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      postedBy: json['postedBy'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      // Correctly maps the list of users from Firebase
      buddies: List<String>.from(json['buddies'] ?? []),
      // If maxBuddies is missing in older database entries, it defaults to 10
      maxBuddies: json['maxBuddies'] ?? 10,
    );
  }

  // --- TO JSON: Converts this Object into a format Firebase understands ---
  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'date': date,
      'description': description,
      'postedBy': postedBy,
      'imageUrl': imageUrl,
      'buddies': buddies,
      'maxBuddies': maxBuddies,
    };
  }
}