import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lxai_box/features/trading/providers/trading_providers.dart';

/// 量化交易主屏幕
class TradingScreen extends ConsumerWidget {
  const TradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategies = ref.watch(strategiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('量化策略'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/trading/create'),
            tooltip: '新建策略',
          ),
        ],
      ),
      body: strategies.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_graph, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无策略', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('点击右上角 + 创建第一个量化策略', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(strategiesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final strategy = data[index];
                return _StrategyCard(strategy: strategy);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('加载失败: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(strategiesProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/trading/create'),
        icon: const Icon(Icons.add),
        label: const Text('新建策略'),
      ),
    );
  }
}

class _StrategyCard extends ConsumerWidget {
  final dynamic strategy;

  const _StrategyCard({required this.strategy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRunning = strategy.status == 'running';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/trading/${strategy.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strategy.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isRunning ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isRunning ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isRunning ? '运行中' : '已停止',
                          style: TextStyle(
                            color: isRunning ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                strategy.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.trending_up,
                    label: '收益',
                    value: '${strategy.totalReturn.toStringAsFixed(2)}%',
                    color: strategy.totalReturn >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.swap_horiz,
                    label: '交易',
                    value: '${strategy.totalTrades}次',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.calendar_today,
                    label: '创建',
                    value: strategy.createdAt.toString().split(' ')[0],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                    color: isRunning ? Colors.red : Colors.green,
                    onPressed: () {
                      ref.read(tradingServiceProvider(strategy.id).notifier).toggleRunning();
                    },
                    tooltip: isRunning ? '停止' : '启动',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 2),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }
}