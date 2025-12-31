import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).loadThreads();
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: cp.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cp.threads.length,
              itemBuilder: (ctx, i) {
                final t = cp.threads[i];
                final title = t['title'] ?? 'Conversation';
                return ListTile(
                  title: Text(title),
                  subtitle: Text(t['last_message']?.toString() ?? ''),
                  onTap: () => Navigator.pushNamed(context, '/chat/detail', arguments: t),
                );
              },
            ),
    );
  }
}
