import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

/// 当前会话 ID
final currentSessionIdProvider = StateProvider<String?>((ref) => null);

/// 会话列表
class ChatSessionsNotifier extends Notifier<List<ChatSession>> {
  @override
  List<ChatSession> build() => [];

  void add(ChatSession session) {
    state = [...state, session];
  }

  void update(ChatSession session) {
    state = [
      for (final s in state)
        if (s.id == session.id) session else s,
    ];
  }

  void remove(String sessionId) {
    state = state.where((s) => s.id != sessionId).toList();
  }

  void clear() {
    state = [];
  }
}

final chatSessionsProvider =
    NotifierProvider<ChatSessionsNotifier, List<ChatSession>>(
  ChatSessionsNotifier.new,
);

/// 当前会话的消息列表（按 sessionId 分组）
final chatMessagesProvider = StateNotifierProvider.family<
    ChatMessagesNotifier, List<ChatMessage>, String>(
  (sessionId) => ChatMessagesNotifier(),
);

class ChatMessagesNotifier extends StateNotifier<List<ChatMessage>> {
  ChatMessagesNotifier() : super(const []);

  void add(ChatMessage message) {
    state = [...state, message];
  }

  void update(ChatMessage message) {
    state = [
      for (final m in state)
        if (m.id == message.id) message else m,
    ];
  }

  void clear() {
    state = [];
  }
}

/// 流式消息控制器
final streamingControllerProvider =
    StateProvider<Stream<ChatMessage>?>((ref) => null);
