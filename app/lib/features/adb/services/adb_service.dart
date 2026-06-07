import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../native/adb_pigeon.dart';
import '../native/adb_pigeon_api.dart';

/// ADB 服务封装类
class AdbService {
  AdbService({
    required this.adbApi,
    required this.appApi,
    required this.screenApi,
  });

  final AdbNativeApi adbApi;
  final AppManagerApi appApi;
  final ScreenApi screenApi;

  Future<bool> initialize() async {
    try {
      final available = await adbApi.isShizukuAvailable();
      if (!available) {
        return await adbApi.requestShizukuPermission();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<AdbCommandResult> executeCommand(String command) async {
    try {
      return await adbApi.executeCommand(command);
    } catch (e) {
      return AdbCommandResult(
        success: false,
        output: '',
        errorMessage: e.toString(),
      );
    }
  }

  Future<AdbCommandResult> executeShellCommand(String command) async {
    try {
      return await adbApi.executeShellCommand(command);
    } catch (e) {
      return AdbCommandResult(
        success: false,
        output: '',
        errorMessage: e.toString(),
      );
    }
  }

  Future<List<DeviceInfo>> getConnectedDevices() async {
    try {
      return await adbApi.getConnectedDevices();
    } catch (e) {
      return [];
    }
  }

  Future<DeviceInfo?> getCurrentDevice() async {
    try {
      return await adbApi.getCurrentDevice();
    } catch (e) {
      return null;
    }
  }

  Future<AdbCommandResult> connectDevice(String deviceId) async {
    try {
      return await adbApi.connectDevice(deviceId);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> disconnectDevice(String deviceId) async {
    try {
      return await adbApi.disconnectDevice(deviceId);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      return await appApi.getInstalledApps();
    } catch (e) {
      return [];
    }
  }

  Future<AdbCommandResult> installApp(String apkPath) async {
    try {
      return await appApi.installApp(apkPath);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> uninstallApp(String packageName) async {
    try {
      return await appApi.uninstallApp(packageName);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> launchApp(String packageName) async {
    try {
      return await appApi.launchApp(packageName);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> stopApp(String packageName) async {
    try {
      return await appApi.stopApp(packageName);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> clearAppData(String packageName) async {
    try {
      return await appApi.clearAppData(packageName);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<String?> takeScreenshot(String outputPath) async {
    try {
      return await screenApi.takeScreenshot(outputPath);
    } catch (e) {
      return null;
    }
  }

  Future<AdbCommandResult> startScreenRecording(String outputPath, int durationSeconds) async {
    try {
      return await screenApi.startScreenRecording(outputPath, durationSeconds);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> stopScreenRecording() async {
    try {
      return await screenApi.stopScreenRecording();
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> tapScreen(int x, int y) async {
    try {
      return await screenApi.tapScreen(x, y);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> swipeScreen({
    required int startX,
    required int startY,
    required int endX,
    required int endY,
    int durationMs = 300,
  }) async {
    try {
      return await screenApi.swipeScreen(startX, startY, endX, endY, durationMs);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> inputText(String text) async {
    try {
      return await screenApi.inputText(text);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }

  Future<AdbCommandResult> pressKey(int keyCode) async {
    try {
      return await screenApi.pressKey(keyCode);
    } catch (e) {
      return AdbCommandResult(success: false, output: '', errorMessage: e.toString());
    }
  }
}

/// ADB 服务 Provider
final adbServiceProvider = Provider<AdbService>((ref) {
  return AdbService(
    adbApi: AdbNativeApi(),
    appApi: AppManagerApi(),
    screenApi: ScreenApi(),
  );
});
