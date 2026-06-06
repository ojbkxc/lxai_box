import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../providers/chat_providers.dart';
import '../services/chat_service.dart';

/// AI 对话页面入口
/// 包含会话列表和聊天详情
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  static const _uuid = Uuid();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  String? _activeSessionId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(chatSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_activeSessionId != null ? 'AI 对话' : '会话列表'),
        leading: _activeSessionId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _activeSessionId = null);
                  ref.read(currentSessionIdProvider.notifier).set(null);
                },
              )
            : null,
        actions: [
          if (_activeSessionId == null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _createNewSession,
              tooltip: '新建会话',
            ),
        ],
      ),
      body: _activeSessionId != null
          ? _buildChatDetail(_activeSessionId!)
          : _buildSessionList(sessions),
    );
  }

  /// 构建会话列表
  Widget _buildSessionList(List<ChatSession> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无会话',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角 + 创建新会话',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Dismissible(
          key: Key(session.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Theme.of(context).colorScheme.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteSession(session.id),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              session.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${session.messageCount} 条消息 · ${_formatDate(session.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => _openSession(session.id),
          ),
        );
      },
    );
  }

  /// 构建聊天详情
  Widget _buildChatDetail(String sessionId) {
    final messages = ref.watch(chatMessagesProvider(sessionId));
    final stream = ref.watch(streamingControllerProvider);

    // 监听流式消息
    if (stream != null) {
      stream.listen(
        (message) {
          ref.read(chatMessagesProvider(sessionId).notifier).update(message);
          if (message.role == 'assistant' && !message.isStreaming) {
            setState(() => _isLoading = false);
          }
          _scrollToBottom();
        },
        onDone: () {
          setState(() => _isLoading = false);
          ref.read(streamingControllerProvider.notifier).clear();
        },
      );
    }

    return Column(
      children: [
        // 消息列表
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    '开始新的对话吧',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(message: message);
                  },
                ),
        ),

        // 输入区域
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _createNewSession() {
    final sessionId = _uuid.v4();
    final session = ChatSession(
      id: sessionId,
      title: '新对话',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(chatSessionsProvider.notifier).add(session);
    _openSession(sessionId);
  }

  void _openSession(String sessionId) {
    setState(() => _activeSessionId = sessionId);
    ref.read(currentSessionIdProvider.notifier).set(sessionId);
  }

  void _deleteSession(String sessionId) {
    ref.read(chatSessionsProvider.notifier).remove(sessionId);
    if (_activeSessionId == sessionId) {
      setState(() => _activeSessionId = null);
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isLoading || _activeSessionId == null) return;

    setState(() => _isLoading = true);
    _messageController.clear();

    final messages = ref.read(chatMessagesProvider(_activeSessionId!));

    final stream = ref.read(chatServiceProvider).sendMessage(
          sessionId: _activeSessionId!,
          content: content,
          history: messages,
        );

    ref.read(streamingControllerProvider.notifier).setStream(stream);

    // 添加用户消息到列表
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      sessionId: _activeSessionId!,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
    ref.read(chatMessagesProvider(_activeSessionId!).notifier).add(userMsg);
    _scrollToBottom();
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} 天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} 小时前';
    } else {
      return '${diff.inMinutes} 分钟前';
    }
  }
}

/// 消息气泡组件
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content.isEmpty ? '...' : message.content,
              style: TextStyle(
                color: isUser
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (message.isStreaming)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isUser
                        ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
