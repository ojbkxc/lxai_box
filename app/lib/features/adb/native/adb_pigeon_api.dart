// Auto-generated Pigeon API stubs
// ignore_for_file: avoid_print, require_trailing_commas

import 'package:flutter/services.dart';
import 'adb_pigeon.dart';

/// ADB 原生 API
class AdbNativeApi {
  static final _ch = MethodChannel('dev.flutter.pigeon.AdbNativeApi');

  Future<bool> isShizukuAvailable() async {
    final result = await _ch.invokeMethod<bool>('isShizukuAvailable');
    return result ?? false;
  }

  Future<bool> requestShizukuPermission() async {
    final result = await _ch.invokeMethod<bool>('requestShizukuPermission');
    return result ?? false;
  }

  Future<AdbCommandResult> executeCommand(String command) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('executeCommand', <Object?>[command]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> executeShellCommand(String command) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('executeShellCommand', <Object?>[command]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<List<DeviceInfo>> getConnectedDevices() async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('getConnectedDevices');
      if (result == null) return [];
      return result.map((e) {
        final list = e as List<dynamic>;
        return DeviceInfo(
          deviceId: list[0] as String,
          model: list[1] as String,
          androidVersion: list[2] as String,
          sdkVersion: list[3] as int,
          isConnected: list[4] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<DeviceInfo?> getCurrentDevice() async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('getCurrentDevice');
      if (result == null) return null;
      return DeviceInfo(
        deviceId: result[0] as String,
        model: result[1] as String,
        androidVersion: result[2] as String,
        sdkVersion: result[3] as int,
        isConnected: result[4] as bool? ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  Future<AdbCommandResult> connectDevice(String deviceId) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('connectDevice', <Object?>[deviceId]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> disconnectDevice(String deviceId) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('disconnectDevice', <Object?>[deviceId]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }
}

/// 应用管理 API
class AppManagerApi {
  static final _ch = MethodChannel('dev.flutter.pigeon.AppManagerApi');

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];
      return result.map((e) {
        final list = e as List<dynamic>;
        return AppInfo(
          packageName: list[0] as String,
          appName: list[1] as String,
          versionName: list[2] as String,
          versionCode: list[3] as int,
          isSystemApp: list[4] as bool? ?? false,
          isInstalled: list[5] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<AdbCommandResult> installApp(String apkPath) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('installApp', <Object?>[apkPath]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> uninstallApp(String packageName) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('uninstallApp', <Object?>[packageName]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> launchApp(String packageName) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('launchApp', <Object?>[packageName]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> stopApp(String packageName) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('stopApp', <Object?>[packageName]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> clearAppData(String packageName) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('clearAppData', <Object?>[packageName]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<bool> isAppInstalled(String packageName) async {
    try {
      final result = await _ch.invokeMethod<bool>('isAppInstalled', <Object?>[packageName]);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}

/// 屏幕操作 API
class ScreenApi {
  static final _ch = MethodChannel('dev.flutter.pigeon.ScreenApi');

  Future<String> takeScreenshot(String outputPath) async {
    try {
      final result = await _ch.invokeMethod<String>('takeScreenshot', <Object?>[outputPath]);
      return result ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<AdbCommandResult> startScreenRecording(String outputPath, int durationSeconds) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('startScreenRecording', <Object?>[outputPath, durationSeconds]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> stopScreenRecording() async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('stopScreenRecording');
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<String> getScreenResolution() async {
    try {
      final result = await _ch.invokeMethod<String>('getScreenResolution');
      return result ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<AdbCommandResult> tapScreen(int x, int y) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('tapScreen', <Object?>[x, y]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> swipeScreen(int startX, int startY, int endX, int endY, int durationMs) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('swipeScreen', <Object?>[startX, startY, endX, endY, durationMs]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> inputText(String text) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('inputText', <Object?>[text]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> pressKey(int keyCode) async {
    try {
      final result = await _ch.invokeMethod<List<dynamic>>('pressKey', <Object?>[keyCode]);
      return AdbCommandResult(
        success: result![0] as bool,
        output: result[1] as String,
        errorCode: result[2] as int?,
        errorMessage: result[3] as String?,
      );
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }
}
