import 'package:drift/drift.dart';

/// 聊天会话表
/// 存储 AI 对话的会话元数据
class ChatSessions extends Table {
  /// 会话 ID（主键）
  TextColumn get id => text()();

  /// 会话标题
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// 使用的模型名称
  TextColumn get model => text().nullable()();

  /// 系统提示词
  TextColumn get systemPrompt => text().nullable()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 最后更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 聊天消息表
/// 存储每条对话消息
class ChatMessages extends Table {
  /// 消息 ID（主键）
  TextColumn get id => text()();

  /// 所属会话 ID
  TextColumn get sessionId => text().references(ChatSessions, #id)();

  /// 角色：user / assistant / system
  TextColumn get role => text().withLength(min: 1, max: 20)();

  /// 消息内容
  TextColumn get content => text()();

  /// 消息序号（用于排序）
  IntColumn get sequence => integer().autoIncrement()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 自选股表
/// 存储用户关注的股票代码
class WatchlistItems extends Table {
  /// 自增 ID
  IntColumn get id => integer().autoIncrement()();

  /// 股票代码，如 QQQ, AAPL
  TextColumn get symbol => text().withLength(min: 1, max: 20)();

  /// 股票名称
  TextColumn get name => text().nullable()();

  /// 数据源标识
  TextColumn get dataSource => text().withLength(min: 1, max: 50).withDefault(const Constant('quantdinger'))();

  /// 排序权重
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 添加时间
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [{symbol, dataSource}];
}

/// ADB 自定义命令表
class AdbCommands extends Table {
  /// 自增 ID
  IntColumn get id => integer().autoIncrement()();

  /// 命令名称
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// ADB shell 命令
  TextColumn get command => text()();

  /// 是否为收藏/预置命令
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))();

  /// 命令分类
  TextColumn get category => text().nullable()();

  /// 是否需要二次确认（高危操作）
  BoolColumn get requireConfirm => boolean().withDefault(const Constant(true))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 策略配置表
class StrategyConfigs extends Table {
  /// 策略 ID
  TextColumn get id => text()();

  /// 策略名称
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// 策略类型（如 ma_cross）
  TextColumn get type => text().withLength(min: 1, max: 50)();

  /// 策略参数（JSON 格式）
  TextColumn get params => text()();

  /// 关联的股票代码
  TextColumn get symbol => text().withLength(min: 1, max: 20)();

  /// 服务器返回的机器人 ID（部署后）
  TextColumn get botId => text().nullable()();

  /// 运行状态：idle / running / stopped
  TextColumn get status => text().withDefault(const Constant('idle'))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
