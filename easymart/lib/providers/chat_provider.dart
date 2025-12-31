import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class ChatProvider extends ChangeNotifier {
  final MessageService _service = MessageService();
  List<dynamic> threads = [];
  Map<String, List<MessageModel>> messages = {};
  bool loading = false;

  Future<void> loadThreads() async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.fetchThreads();
      threads = data;
    } catch (e) {
      threads = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String receiverId) async {
    loading = true;
    notifyListeners();
    try {
      final data = await _service.fetchMessages(receiverId);
      messages[receiverId] =
          data.map((e) => MessageModel.fromJson(e)).toList().cast<MessageModel>();
    } catch (e) {
      messages[receiverId] = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String receiverId, String content) async {
    try {
      final res = await _service.sendMessage(receiverId, {'content': content});
      // push to local list
      final msg = MessageModel.fromJson(res);
      messages[receiverId] = [...(messages[receiverId] ?? []), msg];
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
