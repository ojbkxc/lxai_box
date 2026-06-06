// Auto-generated Pigeon API stubs - replace with actual generated code
// ignore_for_file: avoid_print, require_trailing_commas

import 'dart:async';
import 'package:flutter/services.dart';

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

  static AdbCommandResult fromList(List<dynamic> list) {
    return AdbCommandResult(
      success: list[0] as bool,
      output: list[1] as String,
      errorCode: list[2] as int?,
      errorMessage: list[3] as String?,
    );
  }

  List<dynamic> toList() {
    return [success, output, errorCode, errorMessage];
  }
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

  static DeviceInfo fromList(List<dynamic> list) {
    return DeviceInfo(
      deviceId: list[0] as String,
      model: list[1] as String,
      androidVersion: list[2] as String,
      sdkVersion: list[3] as int,
      isConnected: list[4] as bool? ?? false,
    );
  }

  List<dynamic> toList() {
    return [deviceId, model, androidVersion, sdkVersion, isConnected];
  }
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

  static AppInfo fromList(List<dynamic> list) {
    return AppInfo(
      packageName: list[0] as String,
      appName: list[1] as String,
      versionName: list[2] as String,
      versionCode: list[3] as int,
      isSystemApp: list[4] as bool? ?? false,
      isInstalled: list[5] as bool? ?? true,
    );
  }

  List<dynamic> toList() {
    return [packageName, appName, versionName, versionCode, isSystemApp, isInstalled];
  }
}

/// ADB 原生 API
class AdbNativeApi {
  static const MessageCodec<Object?> _channel = StandardMessageCodec();

  Future<bool> isShizukuAvailable() async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.isShizukuAvailable', _channel)
        .invokeMethod<bool>('isShizukuAvailable');
    return result ?? false;
  }

  Future<bool> requestShizukuPermission() async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.requestShizukuPermission', _channel)
        .invokeMethod<bool>('requestShizukuPermission');
    return result ?? false;
  }

  Future<AdbCommandResult> executeCommand(String command) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.executeCommand', _channel)
        .invokeMethod<List<dynamic>>('executeCommand', <Object?>[command]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> executeShellCommand(String command) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.executeShellCommand', _channel)
        .invokeMethod<List<dynamic>>('executeShellCommand', <Object?>[command]);
    return AdbCommandResult.fromList(result!);
  }

  Future<List<DeviceInfo>> getConnectedDevices() async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.getConnectedDevices', _channel)
        .invokeMethod<List<dynamic>>('getConnectedDevices');
    return result!.map((e) => DeviceInfo.fromList(e as List<dynamic>)).toList();
  }

  Future<DeviceInfo?> getCurrentDevice() async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.getCurrentDevice', _channel)
        .invokeMethod<List<dynamic>>('getCurrentDevice');
    return result != null ? DeviceInfo.fromList(result) : null;
  }

  Future<AdbCommandResult> connectDevice(String deviceId) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.connectDevice', _channel)
        .invokeMethod<List<dynamic>>('connectDevice', <Object?>[deviceId]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> disconnectDevice(String deviceId) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AdbNativeApi.disconnectDevice', _channel)
        .invokeMethod<List<dynamic>>('disconnectDevice', <Object?>[deviceId]);
    return AdbCommandResult.fromList(result!);
  }
}

/// 应用管理 API
class AppManagerApi {
  static const MessageCodec<Object?> _channel = StandardMessageCodec();

  Future<List<AppInfo>> getInstalledApps() async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.getInstalledApps', _channel)
        .invokeMethod<List<dynamic>>('getInstalledApps');
    return result!.map((e) => AppInfo.fromList(e as List<dynamic>)).toList();
  }

  Future<AdbCommandResult> installApp(String apkPath) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.installApp', _channel)
        .invokeMethod<List<dynamic>>('installApp', <Object?>[apkPath]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> uninstallApp(String packageName) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.uninstallApp', _channel)
        .invokeMethod<List<dynamic>>('uninstallApp', <Object?>[packageName]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> launchApp(String packageName) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.launchApp', _channel)
        .invokeMethod<List<dynamic>>('launchApp', <Object?>[packageName]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> stopApp(String packageName) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.stopApp', _channel)
        .invokeMethod<List<dynamic>>('stopApp', <Object?>[packageName]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> clearAppData(String packageName) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.clearAppData', _channel)
        .invokeMethod<List<dynamic>>('clearAppData', <Object?>[packageName]);
    return AdbCommandResult.fromList(result!);
  }

  Future<bool> isAppInstalled(String packageName) async {
    final result = await const MethodChannel('dev.flutter.pigeon.AppManagerApi.isAppInstalled', _channel)
        .invokeMethod<bool>('isAppInstalled', <Object?>[packageName]);
    return result ?? false;
  }
}

/// 屏幕操作 API
class ScreenApi {
  static const MessageCodec<Object?> _channel = StandardMessageCodec();

  Future<String> takeScreenshot(String outputPath) async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.takeScreenshot', _channel)
        .invokeMethod<String>('takeScreenshot', <Object?>[outputPath]);
    return result ?? '';
  }

  Future<AdbCommandResult> startScreenRecording(String outputPath, int durationSeconds) async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.startScreenRecording', _channel)
        .invokeMethod<List<dynamic>>('startScreenRecording', <Object?>[outputPath, durationSeconds]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> stopScreenRecording() async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.stopScreenRecording', _channel)
        .invokeMethod<List<dynamic>>('stopScreenRecording');
    return AdbCommandResult.fromList(result!);
  }

  Future<String> getScreenResolution() async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.getScreenResolution', _channel)
        .invokeMethod<String>('getScreenResolution');
    return result ?? '';
  }

  Future<String> getScreenDensity() async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.getScreenDensity', _channel)
        .invokeMethod<String>('getScreenDensity');
    return result ?? '';
  }

  Future<AdbCommandResult> tapScreen(int x, int y) async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.tapScreen', _channel)
        .invokeMethod<List<dynamic>>('tapScreen', <Object?>[x, y]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> swipeScreen(int startX, int startY, int endX, int endY, int durationMs) async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.swipeScreen', _channel)
        .invokeMethod<List<dynamic>>('swipeScreen', <Object?>[startX, startY, endX, endY, durationMs]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> inputText(String text) async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.inputText', _channel)
        .invokeMethod<List<dynamic>>('inputText', <Object?>[text]);
    return AdbCommandResult.fromList(result!);
  }

  Future<AdbCommandResult> pressKey(int keyCode) async {
    final result = await const MethodChannel('dev.flutter.pigeon.ScreenApi.pressKey', _channel)
        .invokeMethod<List<dynamic>>('pressKey', <Object?>[keyCode]);
    return AdbCommandResult.fromList(result!);
  }
}
