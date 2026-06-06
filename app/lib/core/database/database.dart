import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables.dart';

part 'database.g.dart';

/// 应用数据库定义
@DriftDatabase(tables: [
  ChatSessions,
  ChatMessages,
  WatchlistItems,
  AdbCommands,
  StrategyConfigs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );

  // ---- 会话操作 ----
  Future<List<ChatSession>> getAllSessions() {
    return (select(chatSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  Future<void> createSession(ChatSessionsCompanion session) {
    return into(chatSessions).insert(session);
  }

  Future<void> deleteSession(String sessionId) {
    return transaction(() async {
      await (delete(chatMessages)..where((t) => t.sessionId.equals(sessionId))).go();
      await (delete(chatSessions)..where((t) => t.id.equals(sessionId))).go();
    });
  }

  // ---- 消息操作 ----
  Future<List<ChatMessage>> getMessages(String sessionId) {
    return (select(chatMessages)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
  }

  Future<void> insertMessage(ChatMessagesCompanion message) {
    return into(chatMessages).insert(message);
  }

  // ---- 自选股操作 ----
  Future<List<WatchlistItem>> getWatchlist() {
    return (select(watchlistItems)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> addToWatchlist(WatchlistItemsCompanion item) {
    return into(watchlistItems).insert(item);
  }

  Future<void> removeFromWatchlist(int id) {
    return (delete(watchlistItems)..where((t) => t.id.equals(id))).go();
  }

  // ---- ADB 命令操作 ----
  Future<List<AdbCommand>> getAllAdbCommands() {
    return select(adbCommands).get();
  }

  Future<void> insertAdbCommand(AdbCommandsCompanion cmd) {
    return into(adbCommands).insert(cmd);
  }

  Future<void> deleteAdbCommand(int id) {
    return (delete(adbCommands)..where((t) => t.id.equals(id))).go();
  }

  // ---- 策略操作 ----
  Future<List<StrategyConfig>> getAllStrategies() {
    return select(strategyConfigs).get();
  }

  Future<void> upsertStrategy(StrategyConfigsCompanion config) {
    return into(strategyConfigs).insertOnConflictUpdate(config);
  }
}

/// 数据库提供者，由 main.dart 中的 ProviderScope 注入
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be overridden in ProviderScope');
});

/// 创建数据库连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'lxai_box.db'));
    return NativeDatabase.createInBackground(file);
  });
}
