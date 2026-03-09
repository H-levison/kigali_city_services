import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Section with Firestore Backup
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
              builder: (context, snapshot) {
                String displayName = "User";

                // 1. Try Firebase Auth DisplayName first
                if (user?.displayName != null && user!.displayName!.isNotEmpty) {
                  displayName = user.displayName!;
                }
                // 2. Backup: Try Firestore "name" field if Auth is blank
                else if (snapshot.hasData && snapshot.data!.exists) {
                  displayName = snapshot.data!['name'] ?? "User";
                }

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                        backgroundColor: Color(0xFF0F1C36),
                        child: Icon(Icons.person, color: Colors.white)
                    ),
                    title: Text(
                        displayName,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                    subtitle: Text(
                        user?.email ?? "No Email",
                        style: const TextStyle(color: Colors.grey)
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Notification Toggle
            SwitchListTile(
              title: const Text("Enable Location Notifications", style: TextStyle(color: Colors.white)),
              value: _notificationsEnabled,
              activeColor: const Color(0xFFF4C446),
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Notifications ${val ? 'Enabled' : 'Disabled'}"))
                );
              },
            ),

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.read<AuthService>().signOut();
                },
                child: const Text("Log Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}