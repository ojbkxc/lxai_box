import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lxai_box/app.dart';
import 'package:lxai_box/core/database/database.dart';

/// 应用入口
/// 使用 [ProviderScope] 包裹整个应用，启用 Riverpod 状态管理
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        // 将数据库实例注入到 Provider 中
        databaseProvider.overrideWithValue(database),
      ],
      child: const MyApp(),
    ),
  );
}
