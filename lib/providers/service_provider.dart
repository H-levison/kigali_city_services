import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kigali_service_model.dart';

class ServiceProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<KigaliService> _services = [];
  List<KigaliService> _filteredServices = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<KigaliService> get services => _filteredServices;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // 1. FETCH SERVICES (This was missing!)
  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('services')
          .orderBy('timestamp', descending: true) // Sort by newest first
          .get();

      _services = snapshot.docs.map((doc) => KigaliService.fromFirestore(doc)).toList();
      _filterData(); // Apply category/search filters immediately
    } catch (e) {
      debugPrint("Error fetching services: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // 2. RATE A SERVICE
  Future<void> rateService(String serviceId, double newRating) async {
    try {
      final docRef = _db.collection('services').doc(serviceId);

      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) throw Exception("Service does not exist!");

        final data = snapshot.data() as Map<String, dynamic>;
        final currentRating = (data['rating'] ?? 0.0).toDouble();
        final currentCount = (data['ratingCount'] ?? 0) as int;

        // Calculate new average
        final totalScore = (currentRating * currentCount) + newRating;
        final newCount = currentCount + 1;
        final newAverage = totalScore / newCount;

        transaction.update(docRef, {
          'rating': newAverage,
          'ratingCount': newCount,
        });
      });

      await fetchServices(); // Refresh UI to show new rating
    } catch (e) {
      debugPrint("Error rating service: $e");
      rethrow;
    }
  }

  // 3. ADD LISTING
  Future<void> addService(KigaliService service) async {
    try {
      await _db.collection('services').add(service.toMap());
      await fetchServices();
    } catch (e) {
      debugPrint("Error adding service: $e");
      rethrow;
    }
  }

  // 4. UPDATE LISTING
  Future<void> updateService(KigaliService service) async {
    try {
      await _db.collection('services').doc(service.id).update(service.toMap());
      await fetchServices();
    } catch (e) {
      debugPrint("Error updating service: $e");
      rethrow;
    }
  }

  // 5. DELETE LISTING
  Future<void> deleteService(String serviceId) async {
    try {
      await _db.collection('services').doc(serviceId).delete();
      await fetchServices();
    } catch (e) {
      debugPrint("Error deleting service: $e");
      rethrow;
    }
  }

  // 6. FILTER & SEARCH LOGIC
  List<KigaliService> getMyListings(String userId) {
    return _services.where((s) => s.createdBy == userId).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _filterData();
    notifyListeners();
  }

  void searchServices(String query) {
    if (query.isEmpty) {
      _filterData();
    } else {
      _filteredServices = _services.where((service) {
        return service.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void _filterData() {
    if (_selectedCategory == 'All') {
      _filteredServices = List.from(_services);
    } else {
      _filteredServices = _services.where((s) => s.category == _selectedCategory).toList();
    }
  }
}