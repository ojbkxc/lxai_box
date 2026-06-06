import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/market_quote.dart';
import '../providers/market_providers.dart';
import '../services/market_service.dart';

/// 行情主页面
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('行情'),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(text: '自选股'),
          Tab(text: '期权'),
        ]),
      ),
      body: TabBarView(controller: _tabController, children: [
        _buildStockList(),
        _buildOptionsList(),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSymbolDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStockList() {
    final watchlist = ref.watch(watchlistProvider);
    final quotesAsync = ref.watch(watchlistQuotesProvider);

    return quotesAsync.when(
      data: (quotes) {
        if (watchlist.isEmpty) {
          return const Center(child: Text('暂无自选股'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(watchlistQuotesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final symbol = watchlist[index];
              final quote = quotes[symbol];
              return _buildQuoteCard(symbol, quote);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildOptionsList() {
    return const Center(child: Text('期权功能开发中'));
  }

  Widget _buildQuoteCard(String symbol, MarketQuote? quote) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: quote != null
            ? Text(
                '${quote.changePercent >= 0 ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%',
                style: TextStyle(color: quote.isUp ? Colors.red : Colors.green),
              )
            : const Text('加载中...'),
        trailing: quote != null
            ? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(quote.lastPrice.toStringAsFixed(2),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: quote.isUp ? Colors.red : Colors.green)),
                Text('${quote.changeAmount >= 0 ? '+' : ''}${quote.changeAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 12, color: quote.isUp ? Colors.red : Colors.green)),
              ])
            : null,
        onTap: () => context.push('/market/detail/$symbol'),
      ),
    );
  }

  void _showAddSymbolDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('添加自选股'),
        content: TextField(controller: controller,
          decoration: const InputDecoration(labelText: '股票代码', hintText: '600519.SH, AAPL', border: OutlineInputBorder()),
          autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () {
            final symbol = controller.text.trim();
            if (symbol.isNotEmpty) ref.read(watchlistProvider.notifier).add(symbol);
            Navigator.pop(context);
          }, child: const Text('添加')),
        ],
      );
    });
  }
}
