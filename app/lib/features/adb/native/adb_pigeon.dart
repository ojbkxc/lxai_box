/// ADB 原生桥接数据模型定义
/// 实际的 API 实现在 adb_pigeon.g.dart 中

/// ADB 命令执行结果
class AdbCommandResult {
  AdbCommandResult({
    required this.success,
    required this.output,
    this.errorCode,
    this.errorMessage,
  });

  final bool success;
  final String output;
  final int? errorCode;
  final String? errorMessage;
}

/// 设备信息
class DeviceInfo {
  DeviceInfo({
    required this.deviceId,
    required this.model,
    required this.androidVersion,
    required this.sdkVersion,
    this.isConnected = false,
  });

  final String deviceId;
  final String model;
  final String androidVersion;
  final int sdkVersion;
  final bool isConnected;
}

/// 应用信息
class AppInfo {
  AppInfo({
    required this.packageName,
    required this.appName,
    required this.versionName,
    required this.versionCode,
    this.isSystemApp = false,
    this.isInstalled = true,
  });

  final String packageName;
  final String appName;
  final String versionName;
  final int versionCode;
  final bool isSystemApp;
  final bool isInstalled;
}
