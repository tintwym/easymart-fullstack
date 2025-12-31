import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/listing/create_listing_screen.dart'; 
import '../screens/listing/listing_detail_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case "/login":
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case "/register":
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case "/home":
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/create-listing':
        return MaterialPageRoute(builder: (_) => const CreateListingScreen());
      case '/listing-detail':
        final listing = settings.arguments as ListingModel;
        return MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing));
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}