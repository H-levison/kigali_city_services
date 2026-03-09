import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';
import '../../../services/auth_service.dart';
import 'add_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final provider = context.watch<ServiceProvider>();

    // Safety check: ensure user is logged in
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to view your listings", style: TextStyle(color: Colors.white))),
      );
    }

    final myListings = provider.getMyListings(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("My Listings")),
      body: myListings.isEmpty
          ? const Center(
          child: Text(
              "You haven't posted any listings yet.",
              style: TextStyle(color: Colors.white)
          )
      )
          : ListView.builder(
        itemCount: myListings.length,
        itemBuilder: (context, index) {
          final service = myListings[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              subtitle: Text(service.category, style: const TextStyle(color: Colors.grey)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AddListingScreen(serviceToEdit: service)));
                    },
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          // FIX: Manually style the popup to be Dark Navy so text is visible
                          backgroundColor: const Color(0xFF1A2A4D),
                          title: const Text("Delete Listing?", style: TextStyle(color: Colors.white)),
                          content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel", style: TextStyle(color: Color(0xFFF4C446)))
                            ),
                            TextButton(
                              onPressed: () {
                                provider.deleteService(service.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF4C446),
        child: const Icon(Icons.add, color: Color(0xFF0F1C36)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen())),
      ),
    );
  }
}