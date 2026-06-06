import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lxai_box/core/network/dio_client.dart';
import 'package:lxai_box/core/network/websocket_service.dart';
import 'package:lxai_box/core/constants.dart';
import 'package:lxai_box/features/market/models/market_quote.dart';
import 'package:lxai_box/features/market/models/stock_info.dart';

/// 行情服务
class MarketService {
  final Dio _dio;
  final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  MarketService({
    required Dio dio,
    required WebSocketService wsService,
  })  : _dio = dio,
        _wsService = wsService;

  Future<List<StockInfo>> searchStocks(String keyword) async {
    try {
      final response = await _dio.get(
        '${AppConstants.selfHostedApiUrl}/market/search',
        queryParameters: {'keyword': keyword},
      );
      final list = response.data as List;
      return list.map((e) => StockInfo.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<MarketQuote?> getQuote(String symbol) async {
    try {
      final response = await _dio.get(
        '${AppConstants.selfHostedApiUrl}/market/quote',
        queryParameters: {'symbol': symbol},
      );
      return MarketQuote.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<List<MarketQuote>> getQuotes(List<String> symbols) async {
    try {
      final response = await _dio.get(
        '${AppConstants.selfHostedApiUrl}/market/quotes',
        queryParameters: {'symbols': symbols.join(',')},
      );
      final list = response.data as List;
      return list.map((e) => MarketQuote.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  void subscribeQuotes(List<String> symbols, Function(MarketQuote) onData) {
    for (final symbol in symbols) {
      _wsService.subscribe(symbol);
    }
    _subscription?.cancel();
    _subscription = _wsService.messageStream.listen((message) {
      try {
        if (message['type'] == 'quote') {
          onData(MarketQuote.fromJson(message));
        }
      } catch (_) {}
    });
  }

  void unsubscribe(List<String> symbols) {
    for (final symbol in symbols) {
      _wsService.unsubscribe(symbol);
    }
    _subscription?.cancel();
    _subscription = null;
  }

  Future<List<Map<String, dynamic>>> getKline(
    String symbol, {
    String period = '1d',
    int count = 120,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.selfHostedApiUrl}/market/kline',
        queryParameters: {'symbol': symbol, 'period': period, 'count': count},
      );
      final list = response.data as List;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

/// MarketService Provider
final marketServiceProvider = Provider<MarketService>((ref) {
  final dio = ref.watch(dioClientProvider);
  final wsService = ref.watch(webSocketServiceProvider);
  final service = MarketService(dio: dio, wsService: wsService);
  ref.onDispose(service.dispose);
  return service;
});
