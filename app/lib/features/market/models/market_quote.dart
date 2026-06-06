/// 行情报价模型
class MarketQuote {
  /// 股票代码
  final String symbol;

  /// 最新价
  final double lastPrice;

  /// 开盘价
  final double openPrice;

  /// 最高价
  final double highPrice;

  /// 最低价
  final double lowPrice;

  /// 昨收价
  final double prevClose;

  /// 成交量
  final int volume;

  /// 成交额
  final double turnover;

  /// 涨跌幅 (%)
  final double changePercent;

  /// 涨跌额
  final double changeAmount;

  /// 买入价
  final double bidPrice;

  /// 卖出价
  final double askPrice;

  /// 更新时间
  final DateTime timestamp;

  const MarketQuote({
    required this.symbol,
    required this.lastPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.prevClose,
    required this.volume,
    required this.turnover,
    required this.changePercent,
    required this.changeAmount,
    required this.bidPrice,
    required this.askPrice,
    required this.timestamp,
  });

  /// 从 JSON 解析
  factory MarketQuote.fromJson(Map<String, dynamic> json) {
    return MarketQuote(
      symbol: json['symbol'] as String? ?? '',
      lastPrice: (json['lastPrice'] ?? json['price'] ?? 0).toDouble(),
      openPrice: (json['openPrice'] ?? json['open'] ?? 0).toDouble(),
      highPrice: (json['highPrice'] ?? json['high'] ?? 0).toDouble(),
      lowPrice: (json['lowPrice'] ?? json['low'] ?? 0).toDouble(),
      prevClose: (json['prevClose'] ?? json['preClose'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toInt(),
      turnover: (json['turnover'] ?? json['amount'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? json['chgPct'] ?? 0).toDouble(),
      changeAmount: (json['changeAmount'] ?? json['chg'] ?? 0).toDouble(),
      bidPrice: (json['bidPrice'] ?? json['bid'] ?? 0).toDouble(),
      askPrice: (json['askPrice'] ?? json['ask'] ?? 0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as int))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'lastPrice': lastPrice,
    'openPrice': openPrice,
    'highPrice': highPrice,
    'lowPrice': lowPrice,
    'prevClose': prevClose,
    'volume': volume,
    'turnover': turnover,
    'changePercent': changePercent,
    'changeAmount': changeAmount,
    'bidPrice': bidPrice,
    'askPrice': askPrice,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  /// 涨色判断(红涨绿跌)
  bool get isUp => changePercent >= 0;

  /// 涨跌额（兼容旧字段名）
  double get change => changeAmount;

  /// 复制并更新
  MarketQuote copyWith({
    String? symbol,
    double? lastPrice,
    double? openPrice,
    double? highPrice,
    double? lowPrice,
    double? prevClose,
    int? volume,
    double? turnover,
    double? changePercent,
    double? changeAmount,
    double? bidPrice,
    double? askPrice,
    DateTime? timestamp,
  }) {
    return MarketQuote(
      symbol: symbol ?? this.symbol,
      lastPrice: lastPrice ?? this.lastPrice,
      openPrice: openPrice ?? this.openPrice,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      prevClose: prevClose ?? this.prevClose,
      volume: volume ?? this.volume,
      turnover: turnover ?? this.turnover,
      changePercent: changePercent ?? this.changePercent,
      changeAmount: changeAmount ?? this.changeAmount,
      bidPrice: bidPrice ?? this.bidPrice,
      askPrice: askPrice ?? this.askPrice,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}