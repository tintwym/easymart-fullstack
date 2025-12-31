class MessageModel {
  final String id;
  final String threadId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'].toString(),
        threadId: json['thread_id']?.toString() ?? '',
        senderId: json['sender_id']?.toString() ?? '',
        content: json['content'] ?? '',
        createdAt:
            DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'thread_id': threadId,
        'sender_id': senderId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}
