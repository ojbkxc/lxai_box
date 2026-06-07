import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../providers/chat_providers.dart';
import '../services/chat_service.dart';

/// AI 对话页面
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    // 确保有一个默认会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureDefaultSession();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ensureDefaultSession() {
    final sessions = ref.read(chatSessionsProvider);
    if (sessions.isEmpty) {
      final session = ChatSession(
        id: _uuid.v4(),
        title: '新对话',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      ref.read(chatSessionsProvider.notifier).add(session);
      ref.read(currentSessionIdProvider.notifier).state = session.id;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final sessionId = ref.read(currentSessionIdProvider);
    if (sessionId == null) return;

    _inputController.clear();

    final messages = ref.read(chatMessagesProvider(sessionId));
    final service = ref.read(chatServiceProvider);

    try {
      await for (final message in service.sendMessage(
        sessionId: sessionId,
        content: text,
        history: messages,
      )) {
        final notifier = ref.read(chatMessagesProvider(sessionId).notifier);
        final existing = ref.read(chatMessagesProvider(sessionId));
        final index = existing.indexWhere((m) => m.id == message.id);

        if (index >= 0) {
          notifier.update(message);
        } else {
          notifier.add(message);
        }
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = ref.watch(currentSessionIdProvider);
    final messages = sessionId != null
        ? ref.watch(chatMessagesProvider(sessionId))
        : <ChatMessage>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final session = ChatSession(
                id: _uuid.v4(),
                title: '新对话',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              ref.read(chatSessionsProvider.notifier).add(session);
              ref.read(currentSessionIdProvider.notifier).state = session.id;
            },
            tooltip: '新建对话',
          ),
        ],
      ),
      body: Column(children: [
        Expanded(child: _buildMessageList(messages)),
        _buildInputArea(),
      ]),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.chat_bubble_outline, size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('开始对话吧', style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ]),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(message.content, style: TextStyle(
                color: isUser ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 15,
              )),
              if (message.isStreaming) ...[
                const SizedBox(height: 4),
                SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2,
                    color: isUser ? Colors.white70 : theme.colorScheme.primary)),
              ],
            ]),
          )),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
      ),
      child: SafeArea(child: Row(children: [
        Expanded(child: TextField(
          controller: _inputController,
          decoration: InputDecoration(
            hintText: '输入消息...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          maxLines: null,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _sendMessage(),
        )),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send),
        ),
      ])),
    );
  }
}
