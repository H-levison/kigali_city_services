import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final error = await context.read<AuthService>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text("Login to access Kigali services", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              TextField(controller: _emailController, style: const TextStyle(color: Colors.black), decoration: const InputDecoration(hintText: "Email")),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, style: const TextStyle(color: Colors.black),obscureText: true, decoration: const InputDecoration(hintText: "Password")),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator() : const Text("Login"),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Color(0xFFF4C446))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}