import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxai_box/core/constants.dart';

/// Dio 网络客户端提供者
/// 全局单例，配置拦截器和默认选项
final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // 日志拦截器（仅 Debug 模式）
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('[Dio] $obj'),
  ));

  ref.onDispose(() => dio.close());
  return dio;
});

/// AI API 客户端提供者
final aiApiClientProvider = Provider<AiApiClient>((ref) {
  return AiApiClient(
    ref.watch(dioClientProvider),
    ApiConstants.defaultAiBaseUrl,
    ApiConstants.defaultAiApiKey,
    ApiConstants.defaultAiModel,
  );
});

/// AI 大模型 API 客户端
/// 封装 OpenAI 兼容接口的调用
class AiApiClient {
  AiApiClient(this._dio, this._baseUrl, this._apiKey, this._model);

  final Dio _dio;
  final String _baseUrl;
  final String _apiKey;
  final String _model;

  /// 流式调用 AI 对话接口（SSE）
  /// 返回 Stream<String>，逐 token 输出
  Stream<String> chatStream({
    required List<Map<String, String>> messages,
    String? model,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '$_baseUrl/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'text/event-stream',
        },
        responseType: ResponseType.stream,
      ),
      data: {
        'model': model ?? _model,
        'messages': messages,
        'stream': true,
      },
    );

    final stream = response.data!.stream;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += String.fromCharCodes(chunk);
      while (buffer.contains('\n')) {
        final index = buffer.indexOf('\n');
        final line = buffer.substring(0, index).trim();
        buffer = buffer.substring(index + 1);

        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') return;
          try {
            final json = _parseStreamChunk(data);
            if (json != null) yield json;
          } catch (_) {}
        }
      }
    }
  }

  String? _parseStreamChunk(String data) {
    final contentMatch = RegExp(r'"content"\s*:\s*"([^"]*)"').firstMatch(data);
    if (contentMatch != null) {
      return contentMatch.group(1)
          ?.replaceAll('\\n', '\n')
          ?.replaceAll('\\t', '\t')
          ?.replaceAll('\\"', '"');
    }
    return null;
  }

  /// 非流式调用（用于翻译、摘要等简单任务）
  Future<String> chat({
    required List<Map<String, String>> messages,
    String? model,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      options: Options(
        headers: {'Authorization': 'Bearer $_apiKey'},
      ),
      data: {
        'model': model ?? _model,
        'messages': messages,
        'stream': false,
      },
    );

    return response.data['choices'][0]['message']['content'] as String;
  }
}
