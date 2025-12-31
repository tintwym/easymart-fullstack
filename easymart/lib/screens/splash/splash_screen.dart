import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    // Wait for the provider to check storage
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await auth.tryAutoLogin();

    if (mounted) {
      if (isLoggedIn) {
        // Token found -> Go to Home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // No token -> Go to Login
        Navigator.pushReplacementNamed(context, '/login'); // Make sure this matches your login route
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading while checking
      ),
    );
  }
}