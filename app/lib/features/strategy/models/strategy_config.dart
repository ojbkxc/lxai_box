import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../engine/strategy.dart';
import '../engine/strategies/ma_cross_strategy.dart';
import '../engine/strategies/rsi_strategy.dart';

/// 策略配置模型
@immutable
class StrategyConfig {
  /// 策略ID
  final String id;

  /// 策略名称
  final String name;

  /// 策略类型
  final String type;

  /// 策略参数
  final Map<String, dynamic> params;

  /// 是否启用
  final bool enabled;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const StrategyConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.params,
    this.enabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StrategyConfig.fromJson(Map<String, dynamic> json) {
    return StrategyConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      params: Map<String, dynamic>.from(json['params'] as Map),
      enabled: json['enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'params': params,
        'enabled': enabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// 创建策略实例
  IStrategy createStrategy() {
    switch (type) {
      case 'ma_cross':
        return MACrossStrategy(
          shortPeriod: params['shortPeriod'] as int? ?? 5,
          longPeriod: params['longPeriod'] as int? ?? 20,
        );
      case 'rsi':
        return RSIStrategy(
          period: params['period'] as int? ?? 14,
          oversoldThreshold: (params['oversoldThreshold'] as num?)?.toDouble() ?? 30.0,
          overboughtThreshold: (params['overboughtThreshold'] as num?)?.toDouble() ?? 70.0,
        );
      default:
        throw UnsupportedError('Unsupported strategy type: $type');
    }
  }
}