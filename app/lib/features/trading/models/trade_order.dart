/// 交易订单模型
class TradeOrder {
  /// 订单 ID
  final String id;

  /// 股票代码
  final String symbol;

  /// 订单方向（买入/卖出）
  final TradeDirection direction;

  /// 订单类型（市价/限价）
  final OrderType type;

  /// 委托价格
  final double price;

  /// 委托数量
  final int quantity;

  /// 成交价格
  final double? filledPrice;

  /// 成交数量
  final int? filledQuantity;

  /// 订单状态
  final OrderStatus status;

  /// 创建时间
  final DateTime createdAt;

  /// 成交时间
  final DateTime? filledAt;

  /// 策略 ID（关联的策略）
  final String? strategyId;

  /// 备注
  final String? remark;

  const TradeOrder({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.type,
    required this.price,
    required this.quantity,
    this.filledPrice,
    this.filledQuantity,
    required this.status,
    required this.createdAt,
    this.filledAt,
    this.strategyId,
    this.remark,
  });

  /// 从 JSON 创建
  factory TradeOrder.fromJson(Map<String, dynamic> json) {
    return TradeOrder(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      direction: TradeDirection.values.firstWhere(
        (e) => e.toString() == 'TradeDirection.${json['direction']}',
      ),
      type: OrderType.values.firstWhere(
        (e) => e.toString() == 'OrderType.${json['type']}',
      ),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      filledPrice: json['filledPrice'] != null
          ? (json['filledPrice'] as num).toDouble()
          : null,
      filledQuantity: json['filledQuantity'] as int?,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      filledAt: json['filledAt'] != null
          ? DateTime.parse(json['filledAt'] as String)
          : null,
      strategyId: json['strategyId'] as String?,
      remark: json['remark'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'direction': direction.toString().split('.').last,
      'type': type.toString().split('.').last,
      'price': price,
      'quantity': quantity,
      'filledPrice': filledPrice,
      'filledQuantity': filledQuantity,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'filledAt': filledAt?.toIso8601String(),
      'strategyId': strategyId,
      'remark': remark,
    };
  }
}

/// 交易方向
enum TradeDirection {
  /// 买入
  buy,

  /// 卖出
  sell,
}

/// 订单类型
enum OrderType {
  /// 市价单
  market,

  /// 限价单
  limit,
}

/// 订单状态
enum OrderStatus {
  /// 待提交
  pending,

  /// 已提交
  submitted,

  /// 部分成交
  partialFilled,

  /// 完全成交
  filled,

  /// 已取消
  cancelled,

  /// 失败
  failed,
}