import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxai_box/features/market/models/market_quote.dart';
import 'package:lxai_box/features/market/models/stock_info.dart';
import 'package:lxai_box/features/market/services/market_service.dart';

/// 自选股列表
class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super(const ['000001', '600519', '300750', '002594']);

  void add(String symbol) {
    if (!state.contains(symbol)) {
      state = [...state, symbol];
    }
  }

  void remove(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }

  bool contains(String symbol) => state.contains(symbol);
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<String>>(
  (ref) => WatchlistNotifier(),
);

/// 自选股行情列表
final watchlistQuotesProvider =
    FutureProvider<Map<String, MarketQuote>>((ref) async {
  final symbols = ref.watch(watchlistProvider);
  final service = ref.watch(marketServiceProvider);
  final initialQuotes = await service.getQuotes(symbols);
  return {for (final q in initialQuotes) q.symbol: q};
});

/// 股票搜索
final stockSearchProvider =
    FutureProvider.family<List<StockInfo>, String>((ref, keyword) async {
  if (keyword.isEmpty) return [];
  final service = ref.watch(marketServiceProvider);
  return service.searchStocks(keyword);
});

/// 单只股票实时行情
final stockQuoteProvider =
    FutureProvider.family<MarketQuote?, String>((ref, symbol) async {
  final service = ref.watch(marketServiceProvider);
  return await service.getQuote(symbol);
});

/// K线数据
final klineDataProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, symbol) async {
  final service = ref.watch(marketServiceProvider);
  return service.getKline(symbol, period: '1d');
});
