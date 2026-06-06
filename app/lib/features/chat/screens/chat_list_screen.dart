import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_session.dart';
import '../providers/chat_providers.dart';

/// 聊天会话列表页面
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(chatSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 对话'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewSession(context, ref),
            tooltip: '新建会话',
          ),
        ],
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Text(
                '暂无会话\n点击右上角 + 创建新会话',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(session.title),
                  subtitle: Text(
                    '${session.messageCount} 条消息 · ${_formatDate(session.updatedAt)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteSession(ref, session.id),
                    tooltip: '删除',
                  ),
                  onTap: () {
                    ref.read(currentSessionIdProvider.notifier).set(session.id);
                    context.push('/chat/${session.id}');
                  },
                );
              },
            ),
    );
  }

  void _createNewSession(BuildContext context, WidgetRef ref) {
    final sessionId = _uuid.v4();
    final session = ChatSession(
      id: sessionId,
      title: '新对话',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(chatSessionsProvider.notifier).add(session);
    ref.read(currentSessionIdProvider.notifier).set(sessionId);
    context.push('/chat/$sessionId');
  }

  void _deleteSession(WidgetRef ref, String sessionId) {
    ref.read(chatSessionsProvider.notifier).remove(sessionId);
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