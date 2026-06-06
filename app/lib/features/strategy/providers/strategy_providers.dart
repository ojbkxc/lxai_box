import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/backtest_engine.dart';
import '../engine/strategy.dart';
import '../engine/strategies/ma_cross_strategy.dart';
import '../engine/strategies/rsi_strategy.dart';
import '../models/strategy_config.dart';

/// 可用策略列表
final availableStrategiesProvider = Provider<List<StrategyConfig>>((ref) {
  return [
    StrategyConfig(
      id: 'ma_cross_default',
      name: '双均线交叉 (5,20)',
      type: 'ma_cross',
      params: const {'shortPeriod': 5, 'longPeriod': 20},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    StrategyConfig(
      id: 'rsi_default',
      name: 'RSI 策略 (14)',
      type: 'rsi',
      params: const {
        'period': 14,
        'oversoldThreshold': 30.0,
        'overboughtThreshold': 70.0,
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

/// 当前选中的策略
final selectedStrategyProvider = StateProvider<StrategyConfig?>((ref) => null);

/// 回测引擎
final backtestEngineProvider = Provider<BacktestEngine>((ref) {
  return BacktestEngine(
    initialCapital: 1000000.0,
    feeRate: 0.0003,
    slippage: 0.0,
    lotSize: 100.0,
  );
});

/// 回测结果
final backtestResultProvider = StateProvider<BacktestResult?>((ref) => null);

/// 回测进度
final backtestProgressProvider = StateProvider<double>((ref) => 0.0);
