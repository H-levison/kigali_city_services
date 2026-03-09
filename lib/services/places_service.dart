import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // To get API Key

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      placeId: json['place_id'],
      description: json['description'],
    );
  }
}

class PlacesService {
  // We use the key from .env (make sure it's loaded!)
  final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<PlaceSuggestion>> fetchSuggestions(String input) async {
    if (apiKey.isEmpty) return [];

    final request = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&components=country:rw';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        return (result['predictions'] as List)
            .map((p) => PlaceSuggestion.fromJson(p))
            .toList();
      }
    }
    return [];
  }

  // Get Lat/Lng from the selected Place ID
  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final request = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,formatted_address&key=$apiKey';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final location = result['result']['geometry']['location'];
        final address = result['result']['formatted_address'];
        return {
          'lat': location['lat'],
          'lng': location['lng'],
          'address': address,
        };
      }
    }
    return {};
  }
}