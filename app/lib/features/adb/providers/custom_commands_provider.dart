import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';

/// 自定义命令模型
class CustomAdbCommand {
  final String id;
  final String name;
  final String command;
  final String? category;
  final bool isFavorite;
  final DateTime createdAt;

  const CustomAdbCommand({
    required this.id,
    required this.name,
    required this.command,
    this.category,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory CustomAdbCommand.fromDb(AdbCommand dbCommand) {
    return CustomAdbCommand(
      id: dbCommand.id.toString(),
      name: dbCommand.name,
      command: dbCommand.command,
      category: dbCommand.category,
      isFavorite: dbCommand.isPreset,
      createdAt: dbCommand.createdAt,
    );
  }
}

/// 自定义命令列表
final customCommandsProvider =
    FutureProvider<List<CustomAdbCommand>>((ref) async {
  final db = ref.read(databaseProvider);
  final commands = await db.getAllAdbCommands();
  return commands.map((cmd) => CustomAdbCommand.fromDb(cmd)).toList();
});

/// 收藏的命令
final favoriteCommandsProvider =
    FutureProvider<List<CustomAdbCommand>>((ref) async {
  final db = ref.read(databaseProvider);
  final commands = await (db.select(db.adbCommands)
        ..where((t) => t.isPreset.equals(true))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  return commands.map((cmd) => CustomAdbCommand.fromDb(cmd)).toList();
});
