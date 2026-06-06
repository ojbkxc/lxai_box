import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/strategy_config.dart';
import '../providers/strategy_providers.dart';
import '../engine/backtest_engine.dart';

/// 策略管理页面入口
class StrategyPage extends ConsumerStatefulWidget {
  const StrategyPage({super.key});

  @override
  ConsumerState<StrategyPage> createState() => _StrategyPageState();
}

class _StrategyPageState extends ConsumerState<StrategyPage> {
  @override
  Widget build(BuildContext context) {
    final strategies = ref.watch(availableStrategiesProvider);
    final backtestResult = ref.watch(backtestResultProvider);
    final progress = ref.watch(backtestProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('量化策略'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateStrategyDialog(context),
            tooltip: '创建策略',
          ),
        ],
      ),
      body: Column(
        children: [
          // 策略列表
          Expanded(
            child: strategies.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: strategies.length,
                    itemBuilder: (context, index) {
                      final strategy = strategies[index];
                      return _buildStrategyCard(strategy);
                    },
                  ),
          ),

          // 回测结果
          if (backtestResult != null) _buildBacktestResultCard(backtestResult),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无策略',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 创建新策略',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyCard(StrategyConfig strategy) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStrategyIcon(strategy.type),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strategy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '类型: ${_getStrategyTypeName(strategy.type)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: strategy.enabled,
                  onChanged: (value) {
                    // TODO: 启用/禁用策略
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 参数展示
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: strategy.params.entries.map((e) {
                return Chip(
                  label: Text('${e.key}: ${e.value}'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _runBacktest(strategy),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('回测'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deployStrategy(strategy),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('部署'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBacktestResultCard(BacktestResult result) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.analytics),
                const SizedBox(width: 8),
                Text(
                  '回测结果',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(backtestResultProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildResultRow('总收益率', '${(result.totalReturn * 100).toStringAsFixed(2)}%',
                    isPositive: result.totalReturn >= 0),
                _buildResultRow('年化收益', '${(result.annualizedReturn * 100).toStringAsFixed(2)}%',
                    isPositive: result.annualizedReturn >= 0),
                _buildResultRow('最大回撤', '${(result.maxDrawdown * 100).toStringAsFixed(2)}%',
                    isPositive: false),
                _buildResultRow('夏普比率', result.sharpeRatio.toStringAsFixed(2)),
                _buildResultRow('胜率', '${(result.winRate * 100).toStringAsFixed(1)}%'),
                _buildResultRow('交易次数', '${result.tradeCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool? isPositive}) {
    Color? valueColor;
    if (isPositive != null) {
      valueColor = isPositive ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getStrategyIcon(String type) {
    switch (type) {
      case 'ma_cross':
        return Icons.show_chart;
      case 'rsi':
        return Icons.waves;
      default:
        return Icons.smart_toy;
    }
  }

  String _getStrategyTypeName(String type) {
    switch (type) {
      case 'ma_cross':
        return '双均线交叉';
      case 'rsi':
        return 'RSI';
      default:
        return type;
    }
  }

  void _runBacktest(StrategyConfig strategy) {
    // TODO: 加载 K 线数据并运行回测
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在回测: ${strategy.name}...')),
    );
  }

  void _deployStrategy(StrategyConfig strategy) {
    // TODO: 部署到 QuantDinger 服务器
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在部署: ${strategy.name}...')),
    );
  }

  void _showCreateStrategyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedType = 'ma_cross';
        final nameController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('创建策略'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '策略名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: '策略类型',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ma_cross', child: Text('双均线交叉')),
                      DropdownMenuItem(value: 'rsi', child: Text('RSI 策略')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedType = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    // TODO: 创建策略
                    Navigator.pop(context);
                  },
                  child: const Text('创建'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
