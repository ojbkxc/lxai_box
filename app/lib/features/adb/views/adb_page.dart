import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adb_providers.dart';
import '../native/adb_pigeon.dart';
import '../services/adb_service.dart';

/// ADB 工具页面
class AdbPage extends ConsumerStatefulWidget {
  const AdbPage({super.key});

  @override
  ConsumerState<AdbPage> createState() => _AdbPageState();
}

class _AdbPageState extends ConsumerState<AdbPage> {
  final _commandController = TextEditingController();
  final _logController = ScrollController();
  final List<String> _logs = [];

  @override
  void dispose() {
    _commandController.dispose();
    _logController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initStatus = ref.watch(adbInitializationProvider);
    final devicesStatus = ref.watch(connectedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADB 工具'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(connectedDevicesProvider);
              ref.invalidate(installedAppsProvider);
            },
            tooltip: '刷新',
          ),
        ],
      ),
      body: initStatus.when(
        data: (isInitialized) {
          if (!isInitialized) return _buildShizukuNotAvailable();
          return Column(children: [
            _buildDeviceInfoSection(devicesStatus),
            _buildCommandInput(),
            Expanded(child: _buildLogOutput()),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('初始化失败: $error')),
      ),
    );
  }

  Widget _buildShizukuNotAvailable() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        const Text('Shizuku 未安装或未授权', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('请安装 Shizuku 并授予权限'),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => ref.invalidate(adbInitializationProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('重试'),
        ),
      ]),
    );
  }

  Widget _buildDeviceInfoSection(AsyncValue<List<DeviceInfo>> devicesStatus) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: devicesStatus.when(
        data: (devices) {
          if (devices.isEmpty) {
            return const Row(children: [
              Icon(Icons.phone_android, size: 20),
              SizedBox(width: 8),
              Text('未检测到设备'),
            ]);
          }
          final device = devices.first;
          return Row(children: [
            Icon(Icons.phone_android, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(device.model, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Android ${device.androidVersion} · ${device.deviceId}',
                  style: Theme.of(context).textTheme.bodySmall),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: device.isConnected ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(device.isConnected ? '已连接' : '未连接',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]);
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('设备检测失败: $e'),
      ),
    );
  }

  Widget _buildCommandInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('命令执行', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(
            controller: _commandController,
            decoration: InputDecoration(
              hintText: '输入 ADB Shell 命令...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontFamily: 'monospace'),
          )),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _executeCommand,
            icon: const Icon(Icons.play_arrow),
            label: const Text('执行'),
          ),
        ]),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _buildQuickCommand('截图', 'screencap -p /sdcard/screenshot.png'),
            _buildQuickCommand('设备信息', 'getprop ro.product.model'),
            _buildQuickCommand('电池信息', 'dumpsys battery'),
            _buildQuickCommand('当前Activity', 'dumpsys window | grep mCurrentFocus'),
          ]),
        ),
      ]),
    );
  }

  Widget _buildQuickCommand(String label, String command) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () => _commandController.text = command,
      ),
    );
  }

  Widget _buildLogOutput() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            const Icon(Icons.terminal, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            const Text('输出日志', style: TextStyle(color: Colors.green, fontSize: 12)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
              onPressed: () => setState(() => _logs.clear()),
            ),
          ]),
        ),
        const Divider(color: Colors.white24, height: 1),
        Expanded(
          child: _logs.isEmpty
              ? const Center(child: Text('等待命令执行...', style: TextStyle(color: Colors.white38)))
              : ListView.builder(
                  controller: _logController,
                  padding: const EdgeInsets.all(8),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) => Text(_logs[index],
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12)),
                ),
        ),
      ]),
    );
  }

  void _executeCommand() {
    final command = _commandController.text.trim();
    if (command.isEmpty) return;

    setState(() => _logs.add('\$ $command'));

    if (_isHighRiskCommand(command)) {
      _showConfirmDialog(command);
      return;
    }
    _doExecute(command);
  }

  bool _isHighRiskCommand(String command) {
    return ['rm -rf', 'reboot', 'factory reset', 'wipe data']
        .any((p) => command.toLowerCase().contains(p));
  }

  void _showConfirmDialog(String command) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('危险命令确认'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('此命令可能对设备造成不可逆影响：'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(command, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () { Navigator.pop(context); _doExecute(command); },
            child: const Text('确认执行'),
          ),
        ],
      );
    });
  }

  void _doExecute(String command) {
    final service = ref.read(adbServiceProvider);
    service.executeShellCommand(command).then((result) {
      setState(() {
        if (result.success) {
          _logs.add(result.output);
        } else {
          _logs.add('ERROR: ${result.errorMessage ?? "Unknown error"}');
        }
        _logs.add('');
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_logController.hasClients) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _logController.animateTo(_logController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    }
  }
}
