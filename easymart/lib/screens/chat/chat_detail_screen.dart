import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/message_model.dart';

class ChatDetailScreen extends StatefulWidget {
  final dynamic thread;
  const ChatDetailScreen({super.key, this.thread, Object? user});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final threadId = widget.thread['id'].toString();
    Provider.of<ChatProvider>(context, listen: false).loadMessages(threadId);
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<ChatProvider>(context);
    final threadId = widget.thread['id'].toString();
    final msgs = cp.messages[threadId] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(widget.thread['title'] ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: msgs.length,
              itemBuilder: (ctx, i) {
                final MessageModel m = msgs[i];
                return ListTile(
                  title: Text(m.content),
                  subtitle: Text(m.createdAt.toLocal().toString()),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _ctrl)),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = _ctrl.text.trim();
                  if (text.isEmpty) return;
                  final ok = await cp.sendMessage(threadId, text);
                  if (ok) _ctrl.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
