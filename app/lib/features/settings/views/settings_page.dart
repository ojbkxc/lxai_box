import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';

/// 当前数据源类型
enum DataSourceType {
  quantDinger('QuantDinger 自建后端'),
  futu('富途 Futu'),
  longBridge('长桥 LongBridge');

  final String label;
  const DataSourceType(this.label);
}

/// 设置数据模型
class SettingsModel {
  final DataSourceType dataSource;
  final String aiBaseUrl;
  final String aiApiKey;
  final String aiModel;
  final String quantServerUrl;
  final ThemeMode themeMode;

  const SettingsModel({
    this.dataSource = DataSourceType.quantDinger,
    this.aiBaseUrl = ApiConstants.defaultAiBaseUrl,
    this.aiApiKey = '',
    this.aiModel = ApiConstants.defaultAiModel,
    this.quantServerUrl = ApiConstants.defaultQuantHttpUrl,
    this.themeMode = ThemeMode.system,
  });

  SettingsModel copyWith({
    DataSourceType? dataSource,
    String? aiBaseUrl,
    String? aiApiKey,
    String? aiModel,
    String? quantServerUrl,
    ThemeMode? themeMode,
  }) {
    return SettingsModel(
      dataSource: dataSource ?? this.dataSource,
      aiBaseUrl: aiBaseUrl ?? this.aiBaseUrl,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiModel: aiModel ?? this.aiModel,
      quantServerUrl: quantServerUrl ?? this.quantServerUrl,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// 设置状态管理
class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(const SettingsModel());

  void setDataSource(DataSourceType type) => state = state.copyWith(dataSource: type);
  void setAiBaseUrl(String url) => state = state.copyWith(aiBaseUrl: url);
  void setAiApiKey(String key) => state = state.copyWith(aiApiKey: key);
  void setAiModel(String model) => state = state.copyWith(aiModel: model);
  void setQuantServerUrl(String url) => state = state.copyWith(quantServerUrl: url);
  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
}

final settingsStateProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);

/// 设置页面
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSectionHeader(context, '数据源'),
          _buildDataSourceTile(context, ref, settings),
          const Divider(),
          _buildSectionHeader(context, 'AI 大模型配置'),
          _buildSettingTile(context, icon: Icons.link, title: 'API 地址',
            subtitle: settings.aiBaseUrl,
            onTap: () => _editSetting(context, ref, title: 'API 地址',
              initialValue: settings.aiBaseUrl,
              onSave: (v) => ref.read(settingsStateProvider.notifier).setAiBaseUrl(v)),
          ),
          _buildSettingTile(context, icon: Icons.key, title: 'API Key',
            subtitle: settings.aiApiKey.isEmpty ? '未设置' : '***${settings.aiApiKey.substring(settings.aiApiKey.length - 4)}',
            onTap: () => _editSetting(context, ref, title: 'API Key',
              initialValue: settings.aiApiKey,
              onSave: (v) => ref.read(settingsStateProvider.notifier).setAiApiKey(v)),
          ),
          _buildSettingTile(context, icon: Icons.smart_toy, title: '模型',
            subtitle: settings.aiModel,
            onTap: () => _editSetting(context, ref, title: '模型名称',
              initialValue: settings.aiModel,
              onSave: (v) => ref.read(settingsStateProvider.notifier).setAiModel(v)),
          ),
          const Divider(),
          _buildSectionHeader(context, '量化服务器'),
          _buildSettingTile(context, icon: Icons.dns, title: '服务器地址',
            subtitle: settings.quantServerUrl,
            onTap: () => _editSetting(context, ref, title: '服务器地址',
              initialValue: settings.quantServerUrl,
              onSave: (v) => ref.read(settingsStateProvider.notifier).setQuantServerUrl(v)),
          ),
          const Divider(),
          _buildSectionHeader(context, '外观'),
          _buildThemeTile(context, ref, settings),
          const Divider(),
          _buildSectionHeader(context, '关于'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('蓝星AI机器人'),
            subtitle: Text('版本 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
      )),
    );
  }

  Widget _buildDataSourceTile(BuildContext context, WidgetRef ref, SettingsModel settings) {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('当前数据源'),
      subtitle: Text(settings.dataSource.label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: const Text('选择数据源'),
          children: DataSourceType.values.map((type) => RadioListTile<DataSourceType>(
            title: Text(type.label),
            value: type,
            groupValue: settings.dataSource,
            onChanged: (value) {
              if (value != null) ref.read(settingsStateProvider.notifier).setDataSource(value);
              Navigator.pop(context);
            },
          )).toList(),
        );
      }),
    );
  }

  Widget _buildSettingTile(BuildContext context, {
    required IconData icon, required String title,
    required String subtitle, required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeTile(BuildContext context, WidgetRef ref, SettingsModel settings) {
    String name;
    switch (settings.themeMode) {
      case ThemeMode.system: name = '跟随系统'; break;
      case ThemeMode.light: name = '浅色模式'; break;
      case ThemeMode.dark: name = '深色模式'; break;
    }
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('主题模式'),
      subtitle: Text(name),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showDialog(context: context, builder: (context) {
        return SimpleDialog(
          title: const Text('选择主题'),
          children: [
            RadioListTile<ThemeMode>(title: const Text('跟随系统'), value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (v) { if (v != null) ref.read(settingsStateProvider.notifier).setThemeMode(v); Navigator.pop(context); }),
            RadioListTile<ThemeMode>(title: const Text('浅色模式'), value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (v) { if (v != null) ref.read(settingsStateProvider.notifier).setThemeMode(v); Navigator.pop(context); }),
            RadioListTile<ThemeMode>(title: const Text('深色模式'), value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (v) { if (v != null) ref.read(settingsStateProvider.notifier).setThemeMode(v); Navigator.pop(context); }),
          ],
        );
      }),
    );
  }

  void _editSetting(BuildContext context, WidgetRef ref, {
    required String title, required String initialValue, required ValueChanged<String> onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text('设置$title'),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: title, border: const OutlineInputBorder()), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(onPressed: () { onSave(controller.text.trim()); Navigator.pop(context); }, child: const Text('保存')),
        ],
      );
    });
  }
}
