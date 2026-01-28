import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("EasyMart Home"),
        actions: [
          IconButton(
            onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, ${user?.name ?? 'User'}", style: const TextStyle(fontSize: 20)),
            Text("ID: ${user?.id ?? ''}", style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}