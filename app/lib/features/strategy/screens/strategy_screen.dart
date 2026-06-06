import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/strategy_providers.dart';

class StrategyScreen extends ConsumerWidget {
  const StrategyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(availableStrategiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('量化策略'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateStrategyDialog(context, ref);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: strategies.length,
        itemBuilder: (context, index) {
          final strategy = strategies[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(strategy.name),
              subtitle: Text('类型: ${strategy.type}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: strategy.enabled,
                    onChanged: (value) {
                      // TODO: 启用/禁用策略
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () {
                      _runBacktest(context, ref, strategy);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateStrategyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建策略'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '策略类型'),
              items: const [
                DropdownMenuItem(value: 'ma_cross', child: Text('双均线交叉')),
                DropdownMenuItem(value: 'rsi', child: Text('RSI 策略')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: '策略名称'),
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
              Navigator.pop(context);
              // TODO: 创建策略
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _runBacktest(BuildContext context, WidgetRef ref, dynamic strategy) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始回测...')),
    );
    // TODO: 运行回测
  }
}