import 'package:lxai_box/features/market/models/market_quote.dart';

/// 市场数据源抽象接口
/// 支持多数据源切换：自建后端、富途、长桥
abstract class MarketDatasource {
  /// 数据源名称
  String get name;

  /// 初始化数据源
  Future<void> initialize();

  /// 释放资源
  Future<void> dispose();

  /// 订阅行情
  /// [symbols] 股票代码列表
  /// 返回行情流
  Stream<MarketQuote> subscribeQuotes(List<String> symbols);

  /// 取消订阅
  Future<void> unsubscribe(List<String> symbols);

  /// 获取历史 K 线数据
  /// [symbol] 股票代码
  /// [interval] 时间周期（1m, 5m, 15m, 1h, 1d）
  /// [limit] 数据条数
  Future<List<dynamic>> getKlineData(
    String symbol,
    String interval, {
    int limit = 100,
  });

  /// 搜索股票
  Future<List<dynamic>> searchStock(String keyword);
}