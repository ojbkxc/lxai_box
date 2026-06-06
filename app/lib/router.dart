import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shared/widgets/home_shell.dart';
import 'features/chat/views/chat_page.dart';
import 'features/market/views/market_page.dart';
import 'features/strategy/views/strategy_page.dart';
import 'features/adb/views/adb_page.dart';
import 'features/settings/views/settings_page.dart';

/// 应用路由配置
/// 包含所有页面路由定义和底部导航
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/chat',
    routes: [
      // 底部导航 Shell 路由
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          // AI 对话
          StatefulShellBranch(routes: [
            GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
          ]),
          // 行情
          StatefulShellBranch(routes: [
            GoRoute(path: '/market', builder: (context, state) => const MarketPage()),
          ]),
          // 策略
          StatefulShellBranch(routes: [
            GoRoute(path: '/strategy', builder: (context, state) => const StrategyPage()),
          ]),
          // ADB 工具
          StatefulShellBranch(routes: [
            GoRoute(path: '/adb', builder: (context, state) => const AdbPage()),
          ]),
          // 设置
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      if (state.matchedLocation == '/') return '/chat';
      return null;
    },
  );
});
