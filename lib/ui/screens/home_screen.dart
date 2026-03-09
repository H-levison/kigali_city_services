import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../../models/kigali_service_model.dart';
import 'package:kigali_city_services/ui/screens/listing/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1C36), // Deep Navy
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Kigali City", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () {}),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Categories Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip("All", provider),
                  _buildCategoryChip("Cafés", provider),
                  _buildCategoryChip("Pharmacies", provider),
                  _buildCategoryChip("Co-working", provider),
                  _buildCategoryChip("Tourist Attraction", provider),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Search Bar
            TextField(
              onChanged: (value) => provider.searchServices(value),
              style: const TextStyle(color: Colors.black), // Fix invisible text
              decoration: InputDecoration(
                hintText: "Search for a service...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. "Near You" Section Title
            const Text(
              "Places Directory",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 4. List of Services
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFF4C446)))
                  : ListView.builder(
                itemCount: provider.services.length,
                itemBuilder: (context, index) {
                  final service = provider.services[index];
                  return _buildServiceCard(context, service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, ServiceProvider provider) {
    bool isSelected = provider.selectedCategory == label;
    if (label == "All" && provider.selectedCategory == 'All') isSelected = true;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          provider.setCategory(label);
        },
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFF4C446),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, KigaliService service) {
    return GestureDetector(
      // Add Navigation to Detail Screen
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: service.imageUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(service.imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: service.imageUrl.isEmpty ? const Icon(Icons.image, color: Colors.grey) : null,
            ),
            const SizedBox(width: 16),

            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        service.rating.toStringAsFixed(1), // Updated to handle double formatting
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const Spacer(),
                      // FIX: Replaced 'distance' (which doesn't exist) with 'category'
                      Text(
                        service.category,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}