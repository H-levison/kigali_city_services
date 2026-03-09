import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';
import '../../../models/kigali_service_model.dart';
import '../listing/service_detail_screen.dart';
import '../listing/add_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kigali City Services"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFFF4C446)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["All", "Café", "Hospital", "Park", "Police", "Tourist Attraction"].map((c) => _buildChip(c, provider)).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Search
            TextField(
              onChanged: provider.searchServices,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Search services...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Places Near You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),

            // List
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: provider.services.length,
                itemBuilder: (context, index) {
                  return _buildCard(context, provider.services[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, ServiceProvider provider) {
    final isSelected = provider.selectedCategory == label || (label == "All" && provider.selectedCategory == 'All');
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.setCategory(label),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFF4C446),
        checkmarkColor: Colors.black,
      ),
    );
  }

  Widget _buildCard(BuildContext context, KigaliService service) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(service: service))),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.store, color: Colors.grey),
          ),
          title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          subtitle: Text(service.address, style: TextStyle(color: Colors.grey[600]), maxLines: 1),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
