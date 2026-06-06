/// AI 聊天消息模型
class ChatMessage {
  /// 消息唯一 ID
  final String id;

  /// 会话 ID
  final String sessionId;

  /// 消息角色（user/assistant/system）
  final String role;

  /// 消息内容
  final String content;

  /// 创建时间
  final DateTime createdAt;

  /// 是否正在流式传输
  final bool isStreaming;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isStreaming = false,
  });

  /// 从 JSON 创建实例
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isStreaming: json['isStreaming'] as bool? ?? false,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'role': role,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isStreaming': isStreaming,
    };
  }

  /// 复制并更新
  ChatMessage copyWith({
    String? id,
    String? sessionId,
    String? role,
    String? content,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}