import '../strategy.dart';

/// RSI 策略
class RSIStrategy implements IStrategy {
  /// RSI 周期
  int period;

  /// 超卖阈值
  double oversoldThreshold;

  /// 超买阈值
  double overboughtThreshold;

  RSIStrategy({
    this.period = 14,
    this.oversoldThreshold = 30.0,
    this.overboughtThreshold = 70.0,
  });

  @override
  String get name => 'RSI 相对强弱指标策略';

  @override
  String get description => 'RSI 低于超卖线买入，高于超买线卖出';

  @override
  void init() {}

  @override
  Signal onBar(StrategyContext context) {
    if (context.currentIndex < period) {
      return Signal.hold;
    }

    final rsi = _calculateRSI(context.klines, context.currentIndex, period);

    if (rsi < oversoldThreshold && context.position == 0) {
      return Signal.buy;
    }

    if (rsi > overboughtThreshold && context.position > 0) {
      return Signal.sell;
    }

    return Signal.hold;
  }

  double _calculateRSI(List<KLine> klines, int index, int period) {
    double gains = 0;
    double losses = 0;

    for (int i = index - period + 1; i <= index; i++) {
      final change = klines[i].close - klines[i - 1].close;
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    final avgGain = gains / period;
    final avgLoss = losses / period;

    if (avgLoss == 0) return 100.0;

    final rs = avgGain / avgLoss;
    return 100.0 - (100.0 / (1.0 + rs));
  }

  @override
  Map<String, dynamic> get params => {
        'period': period,
        'oversoldThreshold': oversoldThreshold,
        'overboughtThreshold': overboughtThreshold,
      };

  @override
  void updateParams(Map<String, dynamic> newParams) {
    if (newParams.containsKey('period')) {
      period = newParams['period'] as int;
    }
    if (newParams.containsKey('oversoldThreshold')) {
      oversoldThreshold = (newParams['oversoldThreshold'] as num).toDouble();
    }
    if (newParams.containsKey('overboughtThreshold')) {
      overboughtThreshold = (newParams['overboughtThreshold'] as num).toDouble();
    }
  }
}