import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/listing/listing_detail_screen.dart';
import '../screens/listing/create_listing_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../models/listing_model.dart';
import '../services/api_service.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case '/':
        final hasToken = ApiService.authToken != null && ApiService.authToken!.isNotEmpty;
        return MaterialPageRoute(
          builder: (_) => hasToken ? const HomeScreen() : const LoginScreen(),
        );

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/home':
        if (ApiService.authToken == null || ApiService.authToken!.isEmpty) {
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/listing-detail':
        final args = settings.arguments;
        if (args is ListingModel) {
          return MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listing: args),
          );
        }
        return _errorRoute('Invalid listing argument');

      case '/create-listing':
        return MaterialPageRoute(builder: (_) => const CreateListingScreen());

      case '/chat-list':
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case '/chat-detail':
        final chatUser = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => ChatDetailScreen(user: chatUser),
        );

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return _errorRoute('Route not found');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text(message)),
      ),
    );
  }
}
