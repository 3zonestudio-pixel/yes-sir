import 'package:uuid/uuid.dart';

enum ChatRole { commander, soldier }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final int tokensUsed;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.tokensUsed = 0,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.index,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'tokensUsed': tokensUsed,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      role: ChatRole.values[map['role'] as int],
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      tokensUsed: map['tokensUsed'] as int? ?? 0,
    );
  }
}
