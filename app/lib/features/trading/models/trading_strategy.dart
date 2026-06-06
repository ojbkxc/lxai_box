/// 量化交易策略模型
class TradingStrategy {
  /// 策略 ID
  final String id;

  /// 策略名称
  final String name;

  /// 策略描述
  final String description;

  /// 策略类型（如：均线、网格、动量等）
  final String type;

  /// 策略配置（JSON 格式）
  final Map<String, dynamic> config;

  /// 是否启用
  final bool isEnabled;

  /// 创建时间
  final DateTime createdAt;

  /// 最后运行时间
  final DateTime? lastRunAt;

  /// 累计收益
  final double totalProfit;

  /// 胜率
  final double winRate;

  const TradingStrategy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.config,
    this.isEnabled = false,
    required this.createdAt,
    this.lastRunAt,
    this.totalProfit = 0.0,
    this.winRate = 0.0,
  });

  /// 从 JSON 创建
  factory TradingStrategy.fromJson(Map<String, dynamic> json) {
    return TradingStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String,
      config: json['config'] as Map<String, dynamic>? ?? {},
      isEnabled: json['isEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastRunAt: json['lastRunAt'] != null
          ? DateTime.parse(json['lastRunAt'] as String)
          : null,
      totalProfit: (json['totalProfit'] as num?)?.toDouble() ?? 0.0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'config': config,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastRunAt': lastRunAt?.toIso8601String(),
      'totalProfit': totalProfit,
      'winRate': winRate,
    };
  }

  /// 复制并修改
  TradingStrategy copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    Map<String, dynamic>? config,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? lastRunAt,
    double? totalProfit,
    double? winRate,
  }) {
    return TradingStrategy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      config: config ?? this.config,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      totalProfit: totalProfit ?? this.totalProfit,
      winRate: winRate ?? this.winRate,
    );
  }
}