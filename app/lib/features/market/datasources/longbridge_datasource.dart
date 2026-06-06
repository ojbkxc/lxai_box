import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:lxai_box/core/constants.dart';
import 'package:lxai_box/features/market/datasources/market_datasource.dart';
import 'package:lxai_box/features/market/models/market_quote.dart';

/// 长桥数据源
/// 对接长桥 OpenAPI
class LongbridgeDatasource extends MarketDatasource {
  WebSocketChannel? _channel;
  final Map<String, StreamController<MarketQuote>> _quoteStreams = {};
  Timer? _heartbeatTimer;
  String? _appKey;
  String? _appSecret;
  String? _accessToken;

  @override
  String get name => '长桥';

  @override
  Future<void> initialize() async {
    // 初始化长桥 OpenAPI
    await _authenticate();
    await _connect();
  }

  Future<void> _authenticate() async {
    // 长桥认证
    // TODO: 实现长桥 OAuth 认证流程
    // 1. 使用 appKey 和 appSecret 获取 accessToken
  }

  Future<void> _connect() async {
    final uri = Uri.parse(AppConstants.longbridgeWsUrl);
    _channel = WebSocketChannel.connect(uri);

    // 心跳保活
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _sendHeartbeat(),
    );

    // 监听消息
    _channel!.stream.listen(
      (message) => _handleMessage(message),
      onError: (error) => _handleError(error),
      onDone: () => _handleDisconnect(),
    );
  }

  void _sendHeartbeat() {
    _channel?.sink.add(jsonEncode({'type': 'ping'}));
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'quote') {
        final quote = MarketQuote.fromJson(data['data']);
        _quoteStreams[quote.symbol]?.add(quote);
      }
    } catch (e) {
      // 忽略解析错误
    }
  }

  void _handleError(dynamic error) {
    // 重连逻辑
    Future.delayed(const Duration(seconds: 5), () => _connect());
  }

  void _handleDisconnect() {
    _heartbeatTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () => _connect());
  }

  @override
  Stream<MarketQuote> subscribeQuotes(List<String> symbols) {
    final controller = StreamController<MarketQuote>();
    
    for (final symbol in symbols) {
      _quoteStreams[symbol] = controller;
      
      // 发送订阅消息（长桥协议）
      _channel?.sink.add(jsonEncode({
        'type': 'subscribe',
        'symbols': symbols,
        'fields': ['last_price', 'open', 'high', 'low', 'volume'],
      }));
    }

    return controller.stream;
  }

  @override
  Future<void> unsubscribe(List<String> symbols) async {
    for (final symbol in symbols) {
      await _quoteStreams[symbol]?.close();
      _quoteStreams.remove(symbol);
    }

    _channel?.sink.add(jsonEncode({
      'type': 'unsubscribe',
      'symbols': symbols,
    }));
  }

  @override
  Future<List<dynamic>> getKlineData(
    String symbol,
    String interval, {
    int limit = 100,
  }) async {
    // 长桥 K 线接口
    // TODO: 实现长桥 K 线查询
    return [];
  }

  @override
  Future<List<dynamic>> searchStock(String keyword) async {
    // 长桥股票搜索
    // TODO: 实现长桥股票搜索
    return [];
  }

  @override
  Future<void> dispose() async {
    _heartbeatTimer?.cancel();
    await _channel?.sink.close();
    
    for (final controller in _quoteStreams.values) {
      await controller.close();
    }
    _quoteStreams.clear();
  }
}