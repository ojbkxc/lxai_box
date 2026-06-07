import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../native/adb_pigeon.dart';
import '../native/adb_pigeon_api.dart';
import '../services/adb_service.dart';

/// ADB 初始化状态
final adbInitializationProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(adbServiceProvider);
  return await service.initialize();
});

/// 已连接设备列表
final connectedDevicesProvider = FutureProvider<List<DeviceInfo>>((ref) async {
  final service = ref.watch(adbServiceProvider);
  return await service.getConnectedDevices();
});

/// 当前设备
final currentDeviceProvider = FutureProvider<DeviceInfo?>((ref) async {
  final service = ref.watch(adbServiceProvider);
  return await service.getCurrentDevice();
});

/// 已安装应用列表
final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final service = ref.watch(adbServiceProvider);
  return await service.getInstalledApps();
});

/// ADB 命令执行结果
final adbCommandResultProvider =
    StateProvider<AsyncValue<AdbCommandResult?>>((ref) => const AsyncData(null));

/// 屏幕截图结果
final screenshotResultProvider =
    StateProvider<AsyncValue<String?>>((ref) => const AsyncData(null));
