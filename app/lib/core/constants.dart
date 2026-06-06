/// 应用全局常量

/// API 默认配置
class ApiConstants {
  /// AI 大模型 API 基础地址
  static const defaultAiBaseUrl = 'https://your-api-endpoint/v1';

  /// AI 大模型 API Key
  static const defaultAiApiKey = '';

  /// AI 大模型默认模型名
  static const defaultAiModel = 'gpt-4o-mini';

  /// QuantDinger 后端 HTTP 地址
  static const defaultQuantHttpUrl = 'http://localhost:8000';

  /// QuantDinger 后端基础 URL (兼容旧字段名)
  static const defaultQuantBaseUrl = 'http://localhost:8000/api';

  /// QuantDinger 后端 WebSocket 地址
  static const defaultQuantWsUrl = 'ws://localhost:8765';

  /// 策略部署接口
  static const botCreatePath = '/api/bot/create';
}

/// 数据源配置常量
class AppConstants {
  /// 自建后端 WebSocket 地址
  static const selfHostedWsUrl = 'ws://localhost:8765/ws';

  /// 自建后端 HTTP API 地址
  static const selfHostedApiUrl = 'http://localhost:8000/api';

  /// 富途 OpenD WebSocket 地址
  static const futuWsUrl = 'ws://127.0.0.1:11111';

  /// 长桥 OpenAPI WebSocket 地址
  static const longbridgeWsUrl = 'wss://openapi.longbridge.com/ws';

  /// 长桥 OpenAPI HTTP 地址
  static const longbridgeApiUrl = 'https://openapi.longbridge.com/v1';
}

/// 数据库常量
class DbConstants {
  /// 内存中保留的最近消息数
  static const maxMessagesInMemory = 100;

  /// 数据库文件名
  static const dbName = 'lxai_box.db';
}

/// UI 常量
class UiConstants {
  /// 消息气泡最大宽度比例
  static const messageBubbleMaxWidthRatio = 0.85;

  /// K 线图默认显示根数
  static const defaultKlineBars = 200;

  /// 价格更新动画时长
  static const priceAnimationDuration = Duration(milliseconds: 300);
}

/// WebSocket 心跳间隔
class WsConstants {
  /// 心跳发送间隔（秒）
  static const heartbeatIntervalSeconds = 30;

  /// 重连延迟（秒）
  static const reconnectDelaySeconds = 5;

  /// 最大重连次数
  static const maxReconnectAttempts = 10;
}
