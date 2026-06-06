import '../strategy.dart';

/// 双均线交叉策略
class MACrossStrategy implements IStrategy {
  /// 短期均线周期
  int shortPeriod;

  /// 长期均线周期
  int longPeriod;

  MACrossStrategy({
    this.shortPeriod = 5,
    this.longPeriod = 20,
  });

  @override
  String get name => '双均线交叉策略';

  @override
  String get description => '短期均线上穿长期均线时买入，下穿时卖出';

  @override
  void init() {
    // 初始化策略
  }

  @override
  Signal onBar(StrategyContext context) {
    if (context.currentIndex < longPeriod) {
      return Signal.hold;
    }

    final shortMa = _calculateMA(context.klines, context.currentIndex, shortPeriod);
    final longMa = _calculateMA(context.klines, context.currentIndex, longPeriod);
    final prevShortMa = _calculateMA(context.klines, context.currentIndex - 1, shortPeriod);
    final prevLongMa = _calculateMA(context.klines, context.currentIndex - 1, longPeriod);

    // 金叉：短期均线上穿长期均线
    if (prevShortMa <= prevLongMa && shortMa > longMa) {
      return Signal.buy;
    }

    // 死叉：短期均线下穿长期均线
    if (prevShortMa >= prevLongMa && shortMa < longMa) {
      return Signal.sell;
    }

    return Signal.hold;
  }

  double _calculateMA(List<KLine> klines, int index, int period) {
    double sum = 0;
    for (int i = index - period + 1; i <= index; i++) {
      sum += klines[i].close;
    }
    return sum / period;
  }

  @override
  Map<String, dynamic> get params => {
        'shortPeriod': shortPeriod,
        'longPeriod': longPeriod,
      };

  @override
  void updateParams(Map<String, dynamic> newParams) {
    if (newParams.containsKey('shortPeriod')) {
      shortPeriod = newParams['shortPeriod'] as int;
    }
    if (newParams.containsKey('longPeriod')) {
      longPeriod = newParams['longPeriod'] as int;
    }
  }
}