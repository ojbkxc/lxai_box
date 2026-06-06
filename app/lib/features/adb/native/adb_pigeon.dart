import 'package:pigeon/pigeon.dart';

/// ADB 原生桥接接口定义
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/features/adb/native/adb_pigeon.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/app/src/main/kotlin/com/lxai/box/adb/AdbPigeon.g.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Runner/AdbPigeon.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)

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

/// ADB 原生 API 接口
@HostApi()
abstract class AdbNativeApi {
  /// 检查 Shizuku 是否可用
  @async
  bool isShizukuAvailable();

  /// 请求 Shizuku 权限
  @async
  bool requestShizukuPermission();

  /// 执行 ADB 命令
  @async
  AdbCommandResult executeCommand(String command);

  /// 执行 ADB shell 命令
  @async
  AdbCommandResult executeShellCommand(String command);

  /// 获取已连接的设备信息
  @async
  List<DeviceInfo> getConnectedDevices();

  /// 获取当前连接的设备
  @async
  DeviceInfo? getCurrentDevice();

  /// 连接设备
  @async
  AdbCommandResult connectDevice(String deviceId);

  /// 断开设备
  @async
  AdbCommandResult disconnectDevice(String deviceId);
}

/// 应用管理 API
@HostApi()
abstract class AppManagerApi {
  /// 获取已安装应用列表
  @async
  List<AppInfo> getInstalledApps();

  /// 安装应用
  @async
  AdbCommandResult installApp(String apkPath);

  /// 卸载应用
  @async
  AdbCommandResult uninstallApp(String packageName);

  /// 启动应用
  @async
  AdbCommandResult launchApp(String packageName);

  /// 停止应用
  @async
  AdbCommandResult stopApp(String packageName);

  /// 清除应用数据
  @async
  AdbCommandResult clearAppData(String packageName);

  /// 检查应用是否安装
  @async
  bool isAppInstalled(String packageName);
}

/// 屏幕操作 API
@HostApi()
abstract class ScreenApi {
  /// 截取屏幕
  @async
  String takeScreenshot(String outputPath);

  /// 开始录屏
  @async
  AdbCommandResult startScreenRecording(String outputPath, int durationSeconds);

  /// 停止录屏
  @async
  AdbCommandResult stopScreenRecording();

  /// 获取屏幕分辨率
  @async
  String getScreenResolution();

  /// 获取屏幕密度
  @async
  String getScreenDensity();

  /// 点击屏幕坐标
  @async
  AdbCommandResult tapScreen(int x, int y);

  /// 滑动屏幕
  @async
  AdbCommandResult swipeScreen(int startX, int startY, int endX, int endY, int durationMs);

  /// 输入文本
  @async
  AdbCommandResult inputText(String text);

  /// 按按键
  @async
  AdbCommandResult pressKey(int keyCode);
}