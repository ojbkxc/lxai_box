import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:lxai_box/core/constants.dart';

/// WebSocket 连接状态
enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// WebSocket 服务
/// 管理与 QuantDinger 后端的实时连接
/// 支持心跳保活和断线自动重连
class WebSocketService {
  WebSocketService(this._url);

  final String _url;

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  final _stateController = StreamController<WsConnectionState>.broadcast();
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  /// 连接状态流
  Stream<WsConnectionState> get stateStream => _stateController.stream;

  /// 消息流（已解析 JSON）
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  /// 当前状态
  WsConnectionState _state = WsConnectionState.disconnected;
  WsConnectionState get state => _state;

  /// 建立连接
  Future<void> connect() async {
    if (_state == WsConnectionState.connecting ||
        _state == WsConnectionState.connected) {
      return;
    }

    _updateState(WsConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));
      await _channel!.ready;

      _updateState(WsConnectionState.connected);
      _reconnectAttempts = 0;

      _startHeartbeat();

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      _onError(e);
    }
  }

  /// 发送订阅请求
  void subscribe(String symbol) {
    _send({
      'type': 'subscribe',
      'symbol': symbol,
    });
  }

  /// 取消订阅
  void unsubscribe(String symbol) {
    _send({
      'type': 'unsubscribe',
      'symbol': symbol,
    });
  }

  /// 发送消息
  void _send(Map<String, dynamic> data) {
    if (_channel != null && _state == WsConnectionState.connected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      if (json['type'] == 'pong') return;
      _messageController.add(json);
    } catch (_) {}
  }

  void _onError(Object error) {
    print('[WebSocket] Error: $error');
    _updateState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onDone() {
    print('[WebSocket] Connection closed');
    _updateState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: WsConstants.heartbeatIntervalSeconds),
      (_) => _send({'type': 'ping'}),
    );
  }

  void _scheduleReconnect() {
    _heartbeatTimer?.cancel();

    if (_reconnectAttempts >= WsConstants.maxReconnectAttempts) {
      print('[WebSocket] Max reconnect attempts reached');
      return;
    }

    _updateState(WsConnectionState.reconnecting);
    _reconnectAttempts++;

    final delay = Duration(seconds: WsConstants.reconnectDelaySeconds);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      print('[WebSocket] Reconnecting (attempt $_reconnectAttempts)...');
      connect();
    });
  }

  void _updateState(WsConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// 断开连接并释放资源
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _stateController.close();
    _messageController.close();
  }
}

/// WebSocket 服务提供者
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService(ApiConstants.defaultQuantWsUrl);
  service.connect();

  ref.onDispose(() => service.dispose());
  return service;
});

/// 行情数据流提供者
/// 按股票代码过滤 WebSocket 消息
final quoteStreamProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, symbol) {
  final ws = ref.watch(webSocketServiceProvider);
  ws.subscribe(symbol);
  ref.onDispose(() => ws.unsubscribe(symbol));

  return ws.messageStream.where((msg) =>
      msg['symbol'] == symbol || msg['type'] == 'quote');
});
