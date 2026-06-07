import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/adb_providers.dart';
import '../native/adb_pigeon.dart';
import '../native/adb_pigeon_api.dart';
import '../services/adb_service.dart';

/// ADB 管理主屏幕
class AdbScreen extends ConsumerWidget {
  const AdbScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initStatus = ref.watch(adbInitializationProvider);
    final devicesStatus = ref.watch(connectedDevicesProvider);
    final appsStatus = ref.watch(installedAppsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADB 设备管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(connectedDevicesProvider);
              ref.invalidate(installedAppsProvider);
            },
          ),
        ],
      ),
      body: initStatus.when(
        data: (isInitialized) {
          if (!isInitialized) {
            return _buildShizukuNotAvailable(context, ref);
          }
          return Column(children: [
            _buildDeviceSection(context, ref, devicesStatus),
            const Divider(height: 1),
            Expanded(child: _buildAppSection(context, ref, appsStatus)),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('初始化失败: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCommandDialog(context, ref),
        icon: const Icon(Icons.terminal),
        label: const Text('执行命令'),
      ),
    );
  }

  Widget _buildShizukuNotAvailable(BuildContext context, WidgetRef ref) {
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

  Widget _buildDeviceSection(BuildContext context, WidgetRef ref, AsyncValue<List<DeviceInfo>> devicesStatus) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('已连接设备', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showConnectDeviceDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('连接设备'),
          ),
        ]),
        const SizedBox(height: 8),
        devicesStatus.when(
          data: (devices) {
            if (devices.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('暂无已连接设备')));
            }
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: devices.length,
                itemBuilder: (context, index) => _buildDeviceCard(context, ref, devices[index]),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('加载失败: $error')),
        ),
      ]),
    );
  }

  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, DeviceInfo device) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.phone_android, color: device.isConnected ? Theme.of(context).colorScheme.primary : Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text(device.model, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Text('ID: ${device.deviceId}', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
          Text('Android ${device.androidVersion}', style: const TextStyle(fontSize: 12)),
          Text('SDK ${device.sdkVersion}', style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
              icon: const Icon(Icons.link_off, size: 20),
              onPressed: () async {
                final service = ref.read(adbServiceProvider);
                await service.disconnectDevice(device.deviceId);
                ref.invalidate(connectedDevicesProvider);
              },
              tooltip: '断开连接',
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildAppSection(BuildContext context, WidgetRef ref, AsyncValue<List<AppInfo>> appsStatus) {
    return appsStatus.when(
      data: (apps) {
        if (apps.isEmpty) {
          return const Center(child: Text('暂无已安装应用'));
        }
        return ListView.builder(
          itemCount: apps.length,
          itemBuilder: (context, index) => _buildAppTile(context, ref, apps[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
    );
  }

  Widget _buildAppTile(BuildContext context, WidgetRef ref, AppInfo app) {
    return ListTile(
      leading: Icon(app.isSystemApp ? Icons.system_security_update : Icons.android),
      title: Text(app.appName),
      subtitle: Text(app.packageName),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAppAction(context, ref, app, value),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'launch', child: Text('启动')),
          const PopupMenuItem(value: 'stop', child: Text('停止')),
          const PopupMenuItem(value: 'clear', child: Text('清除数据')),
          const PopupMenuItem(value: 'uninstall', child: Text('卸载')),
        ],
      ),
    );
  }

  void _handleAppAction(BuildContext context, WidgetRef ref, AppInfo app, String action) async {
    final service = ref.read(adbServiceProvider);
    switch (action) {
      case 'launch':
        await service.launchApp(app.packageName);
        break;
      case 'stop':
        await service.stopApp(app.packageName);
        break;
      case 'clear':
        await service.clearAppData(app.packageName);
        break;
      case 'uninstall':
        await service.uninstallApp(app.packageName);
        ref.invalidate(installedAppsProvider);
        break;
    }
  }

  void _showConnectDeviceDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('连接设备'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '设备 ID', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () async {
            final deviceId = controller.text.trim();
            if (deviceId.isNotEmpty) {
              final service = ref.read(adbServiceProvider);
              await service.connectDevice(deviceId);
              ref.invalidate(connectedDevicesProvider);
            }
            Navigator.pop(context);
          }, child: const Text('连接')),
        ],
      );
    });
  }

  void _showCommandDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('执行命令'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'ADB 命令', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () async {
            final command = controller.text.trim();
            if (command.isNotEmpty) {
              final service = ref.read(adbServiceProvider);
              final result = await service.executeShellCommand(command);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result.success ? '执行成功: ${result.output}' : '执行失败: ${result.errorMessage}'),
                ));
              }
            }
            Navigator.pop(context);
          }, child: const Text('执行')),
        ],
      );
    });
  }
}
