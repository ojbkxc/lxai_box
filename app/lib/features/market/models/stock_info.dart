/// 股票信息模型
class StockInfo {
  /// 股票代码
  final String symbol;

  /// 股票名称
  final String name;

  /// 市场(SH/SZ/US)
  final String market;

  /// 股票类型
  final StockType type;

  /// 是否关注
  final bool isFavorite;

  const StockInfo({
    required this.symbol,
    required this.name,
    required this.market,
    this.type = StockType.stock,
    this.isFavorite = false,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      market: json['market'] as String? ?? 'SZ',
      type: StockType.fromString(json['type'] as String? ?? 'stock'),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'name': name,
    'market': market,
    'type': type.value,
    'isFavorite': isFavorite,
  };

  StockInfo copyWith({
    String? symbol,
    String? name,
    String? market,
    StockType? type,
    bool? isFavorite,
  }) {
    return StockInfo(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      market: market ?? this.market,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// 股票类型
enum StockType {
  stock('stock'),
  option('option'),
  etf('etf'),
  future('future');

  final String value;
  const StockType(this.value);

  static StockType fromString(String value) {
    return StockType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StockType.stock,
    );
  }
}