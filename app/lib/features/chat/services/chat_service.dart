import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants.dart';

/// AI 聊天服务
/// 负责与大模型 API 交互，支持流式 SSE
class ChatService {
  ChatService(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  /// 发送消息并接收流式响应
  Stream<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
    List<ChatMessage>? history,
  }) async* {
    final dio = _ref.read(dioClientProvider);

    // 构建消息历史
    final messages = <Map<String, String>>[
      if (history != null)
        for (final msg in history)
          {'role': msg.role, 'content': msg.content},
      {'role': 'user', 'content': content},
    ];

    // 创建用户消息
    yield ChatMessage(
      id: _uuid.v4(),
      sessionId: sessionId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );

    // 创建助手消息占位符
    final assistantId = _uuid.v4();
    final assistantBase = ChatMessage(
      id: assistantId,
      sessionId: sessionId,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isStreaming: true,
    );
    yield assistantBase;

    try {
      final response = await dio.post(
        '${ApiConstants.defaultAiBaseUrl}/chat/completions',
        data: jsonEncode({
          'model': ApiConstants.defaultAiModel,
          'messages': messages,
          'stream': true,
        }),
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Authorization': 'Bearer ${ApiConstants.defaultAiApiKey}',
            'Accept': 'text/event-stream',
          },
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      final buffer = StringBuffer();

      await for (final chunk in stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') {
              yield assistantBase.copyWith(
                content: buffer.toString(),
                isStreaming: false,
              );
              return;
            }
            try {
              final json = jsonDecode(data);
              final delta = json['choices']?[0]?['delta'];
              if (delta != null && delta['content'] != null) {
                buffer.write(delta['content']);
                yield assistantBase.copyWith(content: buffer.toString());
              }
            } catch (_) {}
          }
        }
      }

      yield assistantBase.copyWith(
        content: buffer.toString(),
        isStreaming: false,
      );
    } catch (e) {
      yield assistantBase.copyWith(
        content: '发生错误: $e',
        isStreaming: false,
      );
    }
  }
}

/// ChatService Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref);
});
