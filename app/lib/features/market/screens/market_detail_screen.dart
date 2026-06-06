import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_quote.dart';
import '../providers/market_providers.dart';

/// 行情详情页面
class MarketDetailScreen extends ConsumerStatefulWidget {
  final String symbol;
  
  const MarketDetailScreen({super.key, required this.symbol});

  @override
  ConsumerState<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends ConsumerState<MarketDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(stockQuoteProvider(widget.symbol));

    return Scaffold(
      appBar: AppBar(title: Text(widget.symbol)),
      body: quoteAsync.when(
        data: (quote) {
          if (quote == null) return const Center(child: Text('暂无数据'));
          return _buildDetailContent(quote);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildDetailContent(MarketQuote quote) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildPriceSection(quote),
        const SizedBox(height: 24),
        _buildKLinePlaceholder(),
        const SizedBox(height: 24),
        _buildDetailInfo(quote),
      ]),
    );
  }

  Widget _buildPriceSection(MarketQuote quote) {
    final priceColor = quote.isUp ? Colors.red : Colors.green;
    final changeStr = '${quote.changeAmount >= 0 ? '+' : ''}${quote.changeAmount.toStringAsFixed(2)}';
    final pctStr = '${quote.changePercent >= 0 ? '+' : ''}${quote.changePercent.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: priceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('最新价', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Text(quote.lastPrice.toStringAsFixed(2),
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: priceColor)),
        const SizedBox(height: 8),
        Row(children: [
          Text(changeStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: priceColor)),
          const SizedBox(width: 16),
          Text(pctStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: priceColor)),
        ]),
      ]),
    );
  }

  Widget _buildKLinePlaceholder() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.show_chart, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('K 线图', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 4),
          Text('（需要集成图表库）', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildDetailInfo(MarketQuote quote) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('详细信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(),
        _buildInfoRow('开盘价', quote.openPrice.toStringAsFixed(2)),
        _buildInfoRow('最高价', quote.highPrice.toStringAsFixed(2)),
        _buildInfoRow('最低价', quote.lowPrice.toStringAsFixed(2)),
        _buildInfoRow('昨收价', quote.prevClose.toStringAsFixed(2)),
        _buildInfoRow('成交量', _formatVolume(quote.volume)),
        _buildInfoRow('成交额', _formatTurnover(quote.turnover)),
        _buildInfoRow('买入价', quote.bidPrice.toStringAsFixed(2)),
        _buildInfoRow('卖出价', quote.askPrice.toStringAsFixed(2)),
      ]),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  String _formatVolume(int volume) {
    if (volume >= 100000000) return '${(volume / 100000000).toStringAsFixed(2)}亿';
    if (volume >= 10000) return '${(volume / 10000).toStringAsFixed(2)}万';
    return volume.toString();
  }

  String _formatTurnover(double turnover) {
    if (turnover >= 100000000) return '${(turnover / 100000000).toStringAsFixed(2)}亿';
    if (turnover >= 10000) return '${(turnover / 10000).toStringAsFixed(2)}万';
    return turnover.toStringAsFixed(2);
  }
}
