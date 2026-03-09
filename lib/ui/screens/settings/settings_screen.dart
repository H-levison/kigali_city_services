import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; // Local simulation state

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Section
            Card(
              color: Colors.white,
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF0F1C36), child: Icon(Icons.person, color: Colors.white)),
                title: Text(user?.displayName ?? "User", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle: Text(user?.email ?? "No Email", style: const TextStyle(color: Colors.grey)),
              ),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<AuthService>().signOut();
                  // AuthWrapper in main.dart will automatically take them to Login
                },
                child: const Text("Log Out", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}