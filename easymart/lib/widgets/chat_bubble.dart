import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  const ChatBubble({super.key, required this.text, this.mine = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: mine ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: mine ? Colors.white : Colors.black87)),
      ),
    );
  }
}
