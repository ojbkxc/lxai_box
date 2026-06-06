/// 量化机器人模型
class Bot {
  /// 机器人 ID
  final String id;

  /// 机器人名称
  final String name;

  /// 使用的策略名称
  final String strategy;

  /// 关联的股票代码
  final String symbol;

  /// 是否正在运行
  final bool isRunning;

  /// 盈亏金额
  final double pnl;

  /// 盈亏百分比
  final double pnlPercent;

  /// 创建时间
  final DateTime createdAt;

  /// 最后更新时间
  final DateTime updatedAt;

  /// 机器人配置参数
  final Map<String, dynamic> params;

  /// 运行状态描述
  final String statusMessage;

  const Bot({
    required this.id,
    required this.name,
    required this.strategy,
    required this.symbol,
    this.isRunning = false,
    this.pnl = 0.0,
    this.pnlPercent = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.params = const {},
    this.statusMessage = '',
  });

  /// 从 JSON 解析
  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      strategy: json['strategy'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      isRunning: json['isRunning'] as bool? ?? false,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      pnlPercent: (json['pnlPercent'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      params: json['params'] as Map<String, dynamic>? ?? {},
      statusMessage: json['statusMessage'] as String? ?? '',
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'strategy': strategy,
        'symbol': symbol,
        'isRunning': isRunning,
        'pnl': pnl,
        'pnlPercent': pnlPercent,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'params': params,
        'statusMessage': statusMessage,
      };

  /// 复制并更新
  Bot copyWith({
    String? id,
    String? name,
    String? strategy,
    String? symbol,
    bool? isRunning,
    double? pnl,
    double? pnlPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? params,
    String? statusMessage,
  }) {
    return Bot(
      id: id ?? this.id,
      name: name ?? this.name,
      strategy: strategy ?? this.strategy,
      symbol: symbol ?? this.symbol,
      isRunning: isRunning ?? this.isRunning,
      pnl: pnl ?? this.pnl,
      pnlPercent: pnlPercent ?? this.pnlPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      params: params ?? this.params,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  /// 盈亏是否为正
  bool get isProfit => pnl >= 0;
}
