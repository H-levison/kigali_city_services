import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'providers/service_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/map/map_screen.dart';
import 'ui/screens/listing/my_listings_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ServiceProvider>(create: (_) => ServiceProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kigali City Services',
        theme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          // If no user is logged in, show Login
          // If user is logged in, show the Main Tabs
          return user == null ? const LoginScreen() : const MainTabController();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

// Controls the Bottom Navigation Tabs
class MainTabController extends StatefulWidget {
  const MainTabController({super.key});

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _index = 0;

  // Define the 4 Screens required by the assignment
  final List<Widget> _screens = [
    const HomeScreen(),         // 1. Directory (Browse)
    const MyListingsScreen(),   // 2. My Listings (CRUD)
    const MapScreen(),          // 3. Map View
    const SettingsScreen(),     // 4. Settings (Profile/Logout)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFF0F1C36),
        selectedItemColor: const Color(0xFFF4C446),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Directory"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "My Listings"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}