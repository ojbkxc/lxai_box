/// 行情警报模型
class Alert {
  /// 严重程度：low, medium, high, critical
  final String severity;

  /// 警报消息内容
  final String message;

  /// 关联的股票代码
  final String? symbol;

  /// 触发时间
  final DateTime timestamp;

  /// 是否已读
  final bool isRead;

  const Alert({
    required this.severity,
    required this.message,
    this.symbol,
    required this.timestamp,
    this.isRead = false,
  });

  /// 从 JSON 解析
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      severity: json['severity'] as String? ?? 'medium',
      message: json['message'] as String? ?? '',
      symbol: json['symbol'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() => {
        'severity': severity,
        'message': message,
        'symbol': symbol,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isRead': isRead,
      };

  /// 复制并更新
  Alert copyWith({
    String? severity,
    String? message,
    String? symbol,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Alert(
      severity: severity ?? this.severity,
      message: message ?? this.message,
      symbol: symbol ?? this.symbol,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  /// 获取严重程度对应的图标
  String get severityIcon {
    switch (severity) {
      case 'low':
        return 'ℹ️';
      case 'medium':
        return '⚠️';
      case 'high':
        return '🔥';
      case 'critical':
        return '🚨';
      default:
        return '📢';
    }
  }
}
