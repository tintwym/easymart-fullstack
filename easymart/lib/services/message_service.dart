import 'api_service.dart';

class MessageService {
  final ApiService api = ApiService();

  Future<List<dynamic>> fetchThreads() async {
    // Backend uses /messages, not /threads
    // For now, return empty list - implement thread listing if backend adds it
    return [];
  }

  Future<List<dynamic>> fetchMessages(String receiverId) async {
    final res = await api.get('/messages/$receiverId');
    return (res is List) ? res : [];
  }

  Future<dynamic> sendMessage(String receiverId, Map<String, dynamic> data) async {
    return api.post('/messages', {
      'receiver_id': receiverId,
      'content': data['content'] ?? '',
    });
  }
}
