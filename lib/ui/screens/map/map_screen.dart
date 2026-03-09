import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.watch<ServiceProvider>().services;
    final Set<Marker> markers = services.map((s) {
      return Marker(
        markerId: MarkerId(s.id),
        position: LatLng(s.location.latitude, s.location.longitude),
        infoWindow: InfoWindow(title: s.name, snippet: s.category),
      );
    }).toSet();

    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-1.9441, 30.0619), // Kigali Center
          zoom: 13,
        ),
        markers: markers,
        myLocationEnabled: true,
      ),
    );
  }
}