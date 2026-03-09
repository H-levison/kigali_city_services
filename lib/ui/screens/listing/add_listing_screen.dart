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
  final _locationSearchCtrl = TextEditingController();

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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        final results = await _placesService.fetchSuggestions(query);
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
        _suggestions = [];
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a location from the list"))
        );
        return;
      }

      final user = context.read<AuthService>().currentUser;
      if (user == null) return;

      // Ensure we have a valid creator name
      String creatorName = user.displayName ?? "User";

      // If Auth name is missing, we could fetch from Firestore,
      // but since we updated signUp to updateDisplayName, it should be there.

      final service = KigaliService(
        id: widget.serviceToEdit?.id ?? '',
        name: _nameCtrl.text,
        category: _category,
        description: _descCtrl.text,
        address: _selectedAddress!,
        contact: _contactCtrl.text,
        createdBy: user.uid,
        creatorName: creatorName,
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Operation failed"))
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1C36),
      appBar: AppBar(
        title: Text(widget.serviceToEdit == null ? "Add Listing" : "Edit Listing"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Service Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  TextFormField(
                    controller: _locationSearchCtrl,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Search Location",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  if (_suggestions.isNotEmpty)
                    Container(
                      color: Colors.white,
                      height: 200,
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
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                items: ["Café", "Hospital", "Park", "Police", "Pharmacy", "Library", "Restaurant", "Tourist Attraction"]
                    .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.black)),
                )).toList(),
                onChanged: (v) => setState(() => _category = v.toString()),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Category",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Contact Number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: "Description",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4C446),
                  foregroundColor: const Color(0xFF0F1C36),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  widget.serviceToEdit == null ? "Create Listing" : "Update Listing",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}