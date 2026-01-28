import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart'; // Create a basic home screen file

void main() {
  // Ensure Flutter is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provide AuthService to the entire widget tree
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'EasyMart',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        // Use a Consumer to decide which screen to show based on Auth state
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const HomeScreen(); // Show Home if logged in
            }
            return const LoginScreen(); // Show Login if not logged in
          },
        ),
      ),
    );
  }
}