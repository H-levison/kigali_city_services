import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';
import '../../../models/kigali_service_model.dart';

class ServiceDetailScreen extends StatelessWidget {
  final KigaliService service;

  const ServiceDetailScreen({super.key, required this.service});

  // Launch Google Maps for Turn-by-Turn Navigation
  Future<void> _launchMaps() async {
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=${service.location.latitude},${service.location.longitude}&mode=d");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      debugPrint("Could not launch maps");
    }
  }

  // Show Rating Popup
  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A4D),
        title: const Text("Rate this Service", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("How was your experience?", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 2, 3, 4, 5].map((star) {
                return IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber, size: 30),
                  onPressed: () {
                    // Call the provider to update the rating
                    context.read<ServiceProvider>().rateService(service.id, star.toDouble());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You rated it $star stars!")));
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format the date safely
    final dateString = service.timestamp != null
        ? DateFormat('MMM d, y').format(service.timestamp!)
        : "Recently";

    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: Column(
        children: [
          // Top Image
          Container(
            height: 200, width: double.infinity, color: Colors.grey[300],
            child: service.imageUrl.isNotEmpty
                ? Image.network(service.imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 100, color: Colors.grey),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Title & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(service.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(" ${service.rating.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white, fontSize: 18)),
                            ],
                          ),
                          Text("(${service.ratingCount} reviews)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  // Rate Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showRatingDialog(context),
                      icon: const Icon(Icons.star_outline, color: Color(0xFFF4C446)),
                      label: const Text("Rate this Service", style: TextStyle(color: Color(0xFFF4C446))),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Posted by: ${service.creatorName}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("On: $dateString", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Chip
                  Wrap(
                    children: [
                      Chip(
                        label: Text(service.category),
                        backgroundColor: const Color(0xFFF4C446),
                        labelStyle: const TextStyle(color: Color(0xFF0F1C36), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(service.description, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 20),

                  // Address
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFF4C446)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(service.address, style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Directions Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.directions, color: Color(0xFF0F1C36)),
                      label: const Text("Get Directions", style: TextStyle(color: Color(0xFF0F1C36))),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4C446), padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: _launchMaps,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Static Map Preview
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(service.location.latitude, service.location.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(service.id),
                            position: LatLng(service.location.latitude, service.location.longitude),
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}