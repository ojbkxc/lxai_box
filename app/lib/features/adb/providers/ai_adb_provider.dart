import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/constants.dart';
import '../../../core/network/dio_client.dart';

/// AI 转 ADB 命令结果
class AiAdbResult {
  final String command;
  final String userQuery;
  final bool requireConfirm;
  final String? dangerWarning;

  const AiAdbResult({
    required this.command,
    required this.userQuery,
    this.requireConfirm = true,
    this.dangerWarning,
  });

  bool get isValid => command.isNotEmpty && command != 'UNKNOWN';
}

/// AI 转 ADB 命令服务
class AiAdbService {
  final Dio _dio;

  AiAdbService(this._dio);

  Future<AiAdbResult?> translateToCommand(String userQuery) async {
    if (userQuery.trim().isEmpty) return null;

    try {
      final response = await _dio.post(
        '${ApiConstants.defaultAiBaseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.defaultAiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': ApiConstants.defaultAiModel,
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userQuery},
          ],
          'stream': false,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'] as String;
        final command = content.trim();
        return AiAdbResult(
          command: command,
          userQuery: userQuery,
          requireConfirm: _isHighRiskCommand(command),
          dangerWarning: _getDangerWarning(command),
        );
      }
    } catch (e) {
      print('AI 转换命令失败: $e');
    }
    return null;
  }

  bool _isHighRiskCommand(String command) {
    final patterns = ['rm -rf', 'rm -r', 'reboot', 'factory reset', 'wipe data', 'format', 'dd if='];
    final lower = command.toLowerCase();
    return patterns.any((p) => lower.contains(p));
  }

  String? _getDangerWarning(String command) {
    if (_isHighRiskCommand(command)) {
      return '⚠️ 此命令为高危操作，可能导致数据丢失或设备损坏，请谨慎执行！';
    }
    return null;
  }

  static const _systemPrompt = '''你是一个 ADB 命令生成器。根据用户的描述，只返回对应的 ADB Shell 命令，不要任何解释。
如果无法生成，返回 "UNKNOWN"。
常见命令参考：
- 截图: screencap -p /sdcard/screenshot.png
- 模拟点击: input tap x y
- 清除缓存: pm clear 包名
- 卸载应用: pm uninstall 包名
- 启动应用: am start -n 包名/.MainActivity
- 停止应用: am force-stop 包名
- 获取设备信息: getprop ro.product.model
- 查看电池: dumpsys battery
- 调节亮度: settings put system screen_brightness 值(0-255)''';
}

/// AiAdbService Provider
final aiAdbServiceProvider = Provider<AiAdbService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AiAdbService(dio);
});

/// 当前 AI ADB 结果
final aiAdbResultProvider = StateProvider<AiAdbResult?>((ref) => null);
