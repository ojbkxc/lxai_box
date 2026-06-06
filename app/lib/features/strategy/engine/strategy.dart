import 'package:flutter/foundation.dart';

/// K线数据点
@immutable
class KLine {
  /// 时间戳
  final DateTime timestamp;

  /// 开盘价
  final double open;

  /// 最高价
  final double high;

  /// 最低价
  final double low;

  /// 收盘价
  final double close;

  /// 成交量
  final double volume;

  const KLine({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory KLine.fromJson(Map<String, dynamic> json) {
    return KLine(
      timestamp: DateTime.parse(json['timestamp'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': volume,
      };
}

/// 交易信号
enum Signal { buy, sell, hold }

/// 策略上下文
@immutable
class StrategyContext {
  /// 当前K线数据
  final List<KLine> klines;

  /// 当前索引
  final int currentIndex;

  /// 持仓数量
  final double position;

  /// 可用资金
  final double cash;

  const StrategyContext({
    required this.klines,
    required this.currentIndex,
    required this.position,
    required this.cash,
  });

  KLine get currentKline => klines[currentIndex];
}

/// 量化策略抽象接口
abstract class IStrategy {
  /// 策略名称
  String get name;

  /// 策略描述
  String get description;

  /// 初始化策略
  void init();

  /// 处理每根K线，返回交易信号
  Signal onBar(StrategyContext context);

  /// 策略参数
  Map<String, dynamic> get params;

  /// 更新参数
  void updateParams(Map<String, dynamic> newParams);
}