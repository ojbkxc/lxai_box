import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trading_strategy.dart';
import '../models/trade_order.dart';
import '../../../core/constants.dart';
import '../../../core/network/dio_client.dart';

/// 量化交易服务
class TradingService {
  final Dio _dio;

  TradingService(this._dio);

  Future<List<TradingStrategy>> getStrategies() async {
    try {
      final response = await _dio.get('${ApiConstants.defaultQuantBaseUrl}/strategies');
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => TradingStrategy.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('获取策略列表失败: $e');
      return [];
    }
  }

  Future<TradingStrategy?> getStrategy(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.defaultQuantBaseUrl}/strategies/$id');
      if (response.statusCode == 200) return TradingStrategy.fromJson(response.data);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<TradingStrategy?> createStrategy(TradingStrategy strategy) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.defaultQuantBaseUrl}/strategies',
        data: strategy.toJson(),
      );
      if (response.statusCode == 201) return TradingStrategy.fromJson(response.data);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<TradingStrategy?> updateStrategy(TradingStrategy strategy) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.defaultQuantBaseUrl}/strategies/${strategy.id}',
        data: strategy.toJson(),
      );
      if (response.statusCode == 200) return TradingStrategy.fromJson(response.data);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteStrategy(String id) async {
    try {
      final response = await _dio.delete('${ApiConstants.defaultQuantBaseUrl}/strategies/$id');
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startStrategy(String id) async {
    try {
      final response = await _dio.post('${ApiConstants.defaultQuantBaseUrl}/strategies/$id/start');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopStrategy(String id) async {
    try {
      final response = await _dio.post('${ApiConstants.defaultQuantBaseUrl}/strategies/$id/stop');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<TradeOrder>> getOrders({String? strategyId}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.defaultQuantBaseUrl}/orders',
        queryParameters: strategyId != null ? {'strategyId': strategyId} : null,
      );
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => TradeOrder.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<TradeOrder?> createOrder(TradeOrder order) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.defaultQuantBaseUrl}/orders',
        data: order.toJson(),
      );
      if (response.statusCode == 201) return TradeOrder.fromJson(response.data);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> cancelOrder(String id) async {
    try {
      final response = await _dio.post('${ApiConstants.defaultQuantBaseUrl}/orders/$id/cancel');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPosition() async {
    try {
      final response = await _dio.get('${ApiConstants.defaultQuantBaseUrl}/position');
      if (response.statusCode == 200) return response.data;
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// TradingService Provider
final tradingServiceProvider = Provider<TradingService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return TradingService(dio);
});
