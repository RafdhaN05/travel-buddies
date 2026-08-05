class TravelPlan {
  String id;
  String destination;
  String date;
  String description;
  String postedBy;
  String imageUrl; // Stores the Firebase Storage image URL

  TravelPlan({
    required this.id,
    required this.destination,
    required this.date,
    required this.description,
    required this.postedBy,
    required this.imageUrl,
  });

  // Converts Firebase JSON data into a TravelPlan object
  factory TravelPlan.fromJson(Map<String, dynamic> json, String id) {
    return TravelPlan(
      id: id,
      destination: json['destination'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      postedBy: json['postedBy'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // Converts a TravelPlan object into JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'date': date,
      'description': description,
      'postedBy': postedBy,
      'imageUrl': imageUrl,
    };
  }
}