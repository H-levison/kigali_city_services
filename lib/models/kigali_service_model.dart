import 'package:cloud_firestore/cloud_firestore.dart';

class KigaliService {
  final String id;
  final String name;
  final String category;
  final String description;
  final String address;
  final String contact;
  final double rating;
  final int ratingCount; // New: To calculate average
  final String imageUrl;
  final String createdBy; // User UID
  final String creatorName; // New: Display Name (e.g., "John Doe")
  final GeoPoint location; // Real Coordinates
  final DateTime? timestamp; // New: When it was created

  KigaliService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.address,
    required this.contact,
    required this.createdBy,
    required this.creatorName,
    this.rating = 0.0, // Default to 0
    this.ratingCount = 0,
    this.imageUrl = '',
    required this.location,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'address': address,
      'contact': contact,
      'rating': rating,
      'ratingCount': ratingCount,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(), // Server handles time
    };
  }

  factory KigaliService.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return KigaliService(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'General',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      contact: data['contact'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
      creatorName: data['creatorName'] ?? 'Anonymous',
      location: data['location'] ?? const GeoPoint(-1.9441, 30.0619),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}