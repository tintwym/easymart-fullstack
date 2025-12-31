import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_router.dart'; // ✅ make sure path matches
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/offer_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EasyMart App',

        // ✅ ROUTER (from old code)
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,

        // ✅ Theme is OK to keep
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}
