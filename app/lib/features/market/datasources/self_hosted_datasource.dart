import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/market_quote.dart';
import '../../../core/constants.dart';
import 'market_datasource.dart';

/// 自建后端数据源实现
/// 使用 QuantDinger 后端的 WebSocket 和 REST API
class SelfHostedDatasource implements MarketDatasource {
  final Dio _dio;
  WebSocketChannel? _channel;
  final _quoteController = StreamController<MarketQuote>.broadcast();

  @override
  String get name => 'QuantDinger 自建后端';

  SelfHostedDatasource({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(
            baseUrl: AppConstants.selfHostedApiUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ));

  @override
  Future<void> initialize() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.selfHostedWsUrl));
      _channel!.stream.listen(
        (data) {
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            if (json['type'] == 'quote') {
              _quoteController.add(MarketQuote.fromJson(json));
            }
          } catch (_) {}
        },
        onError: (e) => print('[SelfHosted WS] Error: $e'),
        onDone: () => print('[SelfHosted WS] Connection closed'),
      );
    } catch (e) {
      print('[SelfHosted] 初始化失败: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _channel?.sink.close();
    await _quoteController.close();
  }

  @override
  Stream<MarketQuote> subscribeQuotes(List<String> symbols) {
    for (final symbol in symbols) {
      _channel?.sink.add(jsonEncode({'type': 'subscribe', 'symbol': symbol}));
    }
    return _quoteController.stream.where((q) => symbols.contains(q.symbol));
  }

  @override
  Future<void> unsubscribe(List<String> symbols) async {
    for (final symbol in symbols) {
      _channel?.sink.add(jsonEncode({'type': 'unsubscribe', 'symbol': symbol}));
    }
  }

  @override
  Future<List<dynamic>> getKlineData(String symbol, String interval, {int limit = 100}) async {
    try {
      final response = await _dio.get('/market/kline', queryParameters: {
        'symbol': symbol, 'period': interval, 'count': limit,
      });
      return response.data as List;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<dynamic>> searchStock(String keyword) async {
    try {
      final response = await _dio.get('/market/search', queryParameters: {'keyword': keyword});
      return response.data as List;
    } catch (e) {
      return [];
    }
  }
}
