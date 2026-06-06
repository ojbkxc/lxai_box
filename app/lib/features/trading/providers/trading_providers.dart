import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trading_strategy.dart';
import '../models/trade_order.dart';
import '../services/trading_service.dart';

/// 策略列表
final strategiesProvider = FutureProvider<List<TradingStrategy>>((ref) async {
  final tradingService = ref.watch(tradingServiceProvider);
  return await tradingService.getStrategies();
});

/// 单个策略
final strategyProvider =
    FutureProvider.family<TradingStrategy?, String>((ref, id) async {
  final tradingService = ref.watch(tradingServiceProvider);
  return await tradingService.getStrategy(id);
});

/// 订单列表
final ordersProvider =
    FutureProvider.family<List<TradeOrder>, String?>((ref, strategyId) async {
  final tradingService = ref.watch(tradingServiceProvider);
  return await tradingService.getOrders(strategyId: strategyId);
});

/// 持仓信息
final positionProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final tradingService = ref.watch(tradingServiceProvider);
  return await tradingService.getPosition();
});

/// 策略管理
class StrategyNotifier extends StateNotifier<List<TradingStrategy>> {
  final TradingService _service;
  StrategyNotifier(this._service) : super(const []);

  Future<void> loadAll() async {
    state = await _service.getStrategies();
  }

  Future<void> createStrategy(TradingStrategy strategy) async {
    final created = await _service.createStrategy(strategy);
    if (created != null) state = [...state, created];
  }

  Future<void> updateStrategy(TradingStrategy strategy) async {
    final updated = await _service.updateStrategy(strategy);
    if (updated != null) {
      state = [for (final s in state) if (s.id == updated.id) updated else s];
    }
  }

  Future<void> deleteStrategy(String id) async {
    final success = await _service.deleteStrategy(id);
    if (success) state = state.where((s) => s.id != id).toList();
  }

  Future<void> startStrategy(String id) async {
    final success = await _service.startStrategy(id);
    if (success) {
      state = [for (final s in state) if (s.id == id) s.copyWith(isEnabled: true) else s];
    }
  }

  Future<void> stopStrategy(String id) async {
    final success = await _service.stopStrategy(id);
    if (success) {
      state = [for (final s in state) if (s.id == id) s.copyWith(isEnabled: false) else s];
    }
  }
}

final strategyNotifierProvider =
    StateNotifierProvider<StrategyNotifier, List<TradingStrategy>>((ref) {
  final service = ref.watch(tradingServiceProvider);
  return StrategyNotifier(service);
});
