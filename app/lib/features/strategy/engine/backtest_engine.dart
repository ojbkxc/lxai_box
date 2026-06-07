import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'strategy.dart';

/// 回测交易记录
@immutable
class Trade {
  /// 交易时间
  final DateTime time;

  /// 交易方向
  final Signal signal;

  /// 价格
  final double price;

  /// 数量
  final double quantity;

  /// 手续费
  final double fee;

  /// 盈亏
  final double pnl;

  const Trade({
    required this.time,
    required this.signal,
    required this.price,
    required this.quantity,
    required this.fee,
    this.pnl = 0.0,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      time: DateTime.parse(json['time'] as String),
      signal: Signal.values.byName(json['signal'] as String),
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'signal': signal.name,
        'price': price,
        'quantity': quantity,
        'fee': fee,
        'pnl': pnl,
      };
}

/// 回测结果
@immutable
class BacktestResult {
  /// 策略名称
  final String strategyName;

  /// 初始资金
  final double initialCapital;

  /// 最终资金
  final double finalCapital;

  /// 总收益率
  final double totalReturn;

  /// 年化收益率
  final double annualizedReturn;

  /// 最大回撤
  final double maxDrawdown;

  /// 夏普比率
  final double sharpeRatio;

  /// 胜率
  final double winRate;

  /// 盈亏比
  final double profitLossRatio;

  /// 交易次数
  final int tradeCount;

  /// 交易记录
  final List<Trade> trades;

  /// 收益曲线
  final List<double> equityCurve;

  const BacktestResult({
    required this.strategyName,
    required this.initialCapital,
    required this.finalCapital,
    required this.totalReturn,
    required this.annualizedReturn,
    required this.maxDrawdown,
    required this.sharpeRatio,
    required this.winRate,
    required this.profitLossRatio,
    required this.tradeCount,
    required this.trades,
    required this.equityCurve,
  });

  Map<String, dynamic> toJson() => {
        'strategyName': strategyName,
        'initialCapital': initialCapital,
        'finalCapital': finalCapital,
        'totalReturn': totalReturn,
        'annualizedReturn': annualizedReturn,
        'maxDrawdown': maxDrawdown,
        'sharpeRatio': sharpeRatio,
        'winRate': winRate,
        'profitLossRatio': profitLossRatio,
        'tradeCount': tradeCount,
        'trades': trades.map((t) => t.toJson()).toList(),
      };
}

/// 回测引擎
class BacktestEngine {
  /// 初始资金
  final double initialCapital;

  /// 手续费率
  final double feeRate;

  /// 滑点
  final double slippage;

  /// 每手数量
  final double lotSize;

  BacktestEngine({
    this.initialCapital = 1000000.0,
    this.feeRate = 0.0003,
    this.slippage = 0.0,
    this.lotSize = 100.0,
  });

  /// 运行回测
  Future<BacktestResult> run({
    required IStrategy strategy,
    required List<KLine> klines,
    void Function(double progress)? onProgress,
  }) async {
    return compute((params) => _runBacktest(params, onProgress), {
      'strategy': strategy,
      'klines': klines,
      'initialCapital': initialCapital,
      'feeRate': feeRate,
      'slippage': slippage,
      'lotSize': lotSize,
    });
  }

  /// 在 Isolate 中运行回测
  BacktestResult _runBacktest(Map<String, dynamic> params, void Function(double)? onProgress) {
    final strategy = params['strategy'] as IStrategy;
    final klines = params['klines'] as List<KLine>;
    final initialCapital = params['initialCapital'] as double;
    final feeRate = params['feeRate'] as double;
    final slippage = params['slippage'] as double;
    final lotSize = params['lotSize'] as double;

    strategy.init();

    double cash = initialCapital;
    double position = 0.0;
    final List<Trade> trades = [];
    final List<double> equityCurve = [];
    final List<double> returns = [];
    double peakEquity = initialCapital;
    double maxDrawdown = 0.0;

    for (int i = 0; i < klines.length; i++) {
      final context = StrategyContext(
        klines: klines,
        currentIndex: i,
        position: position,
        cash: cash,
      );

      final signal = strategy.onBar(context);
      final kline = klines[i];
      final price = kline.close;

      if (signal == Signal.buy && position == 0) {
        // 买入
        final quantity = ((cash * 0.95) / price / lotSize).floor() * lotSize;
        if (quantity > 0) {
          final cost = quantity * price;
          final fee = cost * feeRate;
          cash -= (cost + fee);
          position = quantity;
          trades.add(Trade(
            time: kline.timestamp,
            signal: Signal.buy,
            price: price,
            quantity: quantity,
            fee: fee,
          ));
        }
      } else if (signal == Signal.sell && position > 0) {
        // 卖出
        final revenue = position * price;
        final fee = revenue * feeRate;
        final pnl = revenue - (trades.isNotEmpty ? trades.first.price * position : 0) - fee;
        cash += (revenue - fee);
        trades.add(Trade(
          time: kline.timestamp,
          signal: Signal.sell,
          price: price,
          quantity: position,
          fee: fee,
          pnl: pnl,
        ));
        position = 0.0;
      }

      final equity = cash + position * price;
      equityCurve.add(equity);

      if (equity > peakEquity) {
        peakEquity = equity;
      }
      final drawdown = (peakEquity - equity) / peakEquity;
      if (drawdown > maxDrawdown) {
        maxDrawdown = drawdown;
      }

      if (i > 0) {
        final ret = (equity - equityCurve[i - 1]) / equityCurve[i - 1];
        returns.add(ret);
      }

      if (onProgress != null && i % 10 == 0) {
        onProgress(i / klines.length);
      }
    }

    // 计算统计指标
    final finalCapital = equityCurve.last;
    final totalReturn = (finalCapital - initialCapital) / initialCapital;

    // 年化收益
    final days = klines.last.timestamp.difference(klines.first.timestamp).inDays;
    final years = days / 365.0;
    final annualizedReturn = years > 0 ? (pow(1 + totalReturn, 1 / years) - 1) : 0.0;

    // 夏普比率
    final avgReturn = returns.isNotEmpty
        ? returns.reduce((a, b) => a + b) / returns.length
        : 0.0;
    final stdReturn = returns.isNotEmpty
        ? sqrt(returns.map((r) => pow(r - avgReturn, 2)).reduce((a, b) => a + b) / returns.length)
        : 0.0;
    final sharpeRatio = stdReturn > 0 ? (avgReturn / stdReturn) * sqrt(252) : 0.0;

    // 胜率
    final profitTrades = trades.where((t) => t.signal == Signal.sell && t.pnl > 0).length;
    final sellTrades = trades.where((t) => t.signal == Signal.sell).length;
    final winRate = sellTrades > 0 ? profitTrades / sellTrades : 0.0;

    // 盈亏比
    final avgProfit = profitTrades > 0
        ? trades.where((t) => t.pnl > 0).map((t) => t.pnl).reduce((a, b) => a + b) / profitTrades
        : 0.0;
    final avgLoss = (sellTrades - profitTrades) > 0
        ? trades.where((t) => t.pnl < 0).map((t) => t.pnl.abs()).reduce((a, b) => a + b) /
            (sellTrades - profitTrades)
        : 0.0;
    final profitLossRatio = avgLoss > 0 ? avgProfit / avgLoss : 0.0;

    return BacktestResult(
      strategyName: strategy.name,
      initialCapital: initialCapital,
      finalCapital: finalCapital,
      totalReturn: totalReturn,
      annualizedReturn: annualizedReturn,
      maxDrawdown: maxDrawdown,
      sharpeRatio: sharpeRatio,
      winRate: winRate,
      profitLossRatio: profitLossRatio,
      tradeCount: trades.length,
      trades: trades,
      equityCurve: equityCurve,
    );
  }
}

/// 数学工具
double sqrt(double x) => x < 0 ? double.nan : _sqrt(x);
double _sqrt(double x) {
  if (x < 0) return double.nan;
  if (x == 0) return 0;
  double guess = x / 2;
  for (int i = 0; i < 20; i++) {
    guess = (guess + x / guess) / 2;
  }
  return guess;
}

double pow(double base, int exp) {
  if (exp == 0) return 1.0;
  double result = 1.0;
  for (int i = 0; i < exp.abs(); i++) {
    result *= base;
  }
  return exp < 0 ? 1 / result : result;
}