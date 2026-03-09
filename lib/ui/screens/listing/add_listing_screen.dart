import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/service_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/places_service.dart';
import '../../../models/kigali_service_model.dart';

class AddListingScreen extends StatefulWidget {
  final KigaliService? serviceToEdit;

  const AddListingScreen({super.key, this.serviceToEdit});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _contactCtrl;
  final _locationSearchCtrl = TextEditingController(); // Search Bar Controller

  // Logic Variables
  final PlacesService _placesService = PlacesService();
  List<PlaceSuggestion> _suggestions = [];
  GeoPoint? _selectedLocation;
  String? _selectedAddress;
  Timer? _debounce;
  String _category = 'Café';

  @override
  void initState() {
    super.initState();
    // Initialize Controllers (Pre-fill if editing)
    _nameCtrl = TextEditingController(text: widget.serviceToEdit?.name ?? '');
    _descCtrl = TextEditingController(text: widget.serviceToEdit?.description ?? '');
    _contactCtrl = TextEditingController(text: widget.serviceToEdit?.contact ?? '');

    if (widget.serviceToEdit != null) {
      _category = widget.serviceToEdit!.category;
      _selectedLocation = widget.serviceToEdit!.location;
      _selectedAddress = widget.serviceToEdit!.address;
      _locationSearchCtrl.text = widget.serviceToEdit!.address;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    _locationSearchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // SEARCH LOGIC
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        debugPrint("Searching for: $query"); // DEBUG: Check console for this
        final results = await _placesService.fetchSuggestions(query);
        debugPrint("Found ${results.length} results"); // DEBUG: Check console
        setState(() => _suggestions = results);
      } else {
        setState(() => _suggestions = []);
      }
    });
  }

  void _selectLocation(PlaceSuggestion suggestion) async {
    final details = await _placesService.getPlaceDetails(suggestion.placeId);
    if (details.isNotEmpty) {
      setState(() {
        _selectedLocation = GeoPoint(details['lat'], details['lng']);
        _selectedAddress = details['address'];
        _locationSearchCtrl.text = _selectedAddress!;
        _suggestions = []; // Hide the list after selection
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a location from the list")));
        return;
      }

      final user = context.read<AuthService>().currentUser;
      if (user == null) return;

      final service = KigaliService(
        id: widget.serviceToEdit?.id ?? '',
        name: _nameCtrl.text,
        category: _category,
        description: _descCtrl.text,
        address: _selectedAddress!,
        contact: _contactCtrl.text,
        createdBy: user.uid,
        creatorName: user.displayName ?? "Unknown",
        location: _selectedLocation!,
        imageUrl: widget.serviceToEdit?.imageUrl ?? '',
      );

      final provider = context.read<ServiceProvider>();

      try {
        if (widget.serviceToEdit == null) {
          await provider.addService(service);
        } else {
          await provider.updateService(service);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Operation failed")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceToEdit == null ? "Add Listing" : "Edit Listing")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. NAME INPUT
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.black), // Force black text
                decoration: const InputDecoration(labelText: "Service Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // 2. LOCATION SEARCH (Updated)
              Column(
                children: [
                  TextFormField(
                    controller: _locationSearchCtrl,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Search Location (e.g., Kigali Heights)",
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: _onSearchChanged,
                    validator: (v) => _selectedLocation == null ? "Please select a location" : null,
                  ),
                  // Suggestion List
                  if (_suggestions.isNotEmpty)
                    Container(
                      color: Colors.white,
                      height: 200, // Limit height
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ListTile(
                            title: Text(suggestion.description, style: const TextStyle(color: Colors.black)),
                            onTap: () => _selectLocation(suggestion),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. CATEGORY DROPDOWN (Fixed Contrast)
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: Colors.white, // FIX: Force background white
                style: const TextStyle(color: Colors.black, fontSize: 16), // FIX: Force text black
                items: ["Café", "Hospital", "Park", "Police", "Pharmacy", "Library", "Restaurant", "Tourist Attraction"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.black)), // FIX: Item text black
                ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v.toString()),
                decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Category"
                ),
              ),
              const SizedBox(height: 16),

              // 4. CONTACT & DESC
              TextFormField(
                controller: _contactCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: "Contact Number"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // 5. SUBMIT BUTTON
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.serviceToEdit == null ? "Create Listing" : "Update Listing"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}