/// ADB 预置命令库
/// 定义常用 ADB 命令的结构化列表

/// 命令危险等级
enum DangerLevel {
  low,
  medium,
  high,
  dangerous,
}

/// ADB 命令条目
class AdbCommandEntry {
  final String name;
  final String description;
  final String command;
  final String category;
  final bool requireConfirm;
  final DangerLevel dangerLevel;
  final String icon;

  const AdbCommandEntry({
    required this.name,
    required this.description,
    required this.command,
    required this.category,
    this.requireConfirm = true,
    this.dangerLevel = DangerLevel.medium,
    this.icon = '📱',
  });
}

/// 命令分类
class CommandCategory {
  final String name;
  final String icon;
  final List<AdbCommandEntry> commands;

  const CommandCategory({
    required this.name,
    required this.icon,
    required this.commands,
  });
}

/// 预置命令库
class CommandLibrary {
  static List<CommandCategory> getAllCategories() {
    return [
      systemInfoCategory,
      appManagementCategory,
      screenOperationCategory,
      inputOperationCategory,
      fileOperationCategory,
      networkCategory,
    ];
  }

  static const systemInfoCategory = CommandCategory(
    name: '系统信息',
    icon: '📱',
    commands: [
      AdbCommandEntry(name: '获取设备型号', description: '获取设备型号名称', command: 'getprop ro.product.model', category: '系统信息', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: 'Android 版本', description: '获取 Android 版本号', command: 'getprop ro.build.version.release', category: '系统信息', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: 'SDK 版本', description: '获取 SDK 版本号', command: 'getprop ro.build.version.sdk', category: '系统信息', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '电池信息', description: '查看电池状态和电量', command: 'dumpsys battery', category: '系统信息', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '当前 Activity', description: '获取当前前台 Activity', command: 'dumpsys window | grep mCurrentFocus', category: '系统信息', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '内存信息', description: '查看内存使用情况', command: 'cat /proc/meminfo', category: '系统信息', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '存储空间', description: '查看存储空间使用情况', command: 'df -h', category: '系统信息', dangerLevel: DangerLevel.low),
    ],
  );

  static const appManagementCategory = CommandCategory(
    name: '应用管理',
    icon: '📦',
    commands: [
      AdbCommandEntry(name: '启动应用', description: '启动指定包名的应用', command: 'am start -n {package}/.MainActivity', category: '应用管理', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '强制停止', description: '强制停止指定应用', command: 'am force-stop {package}', category: '应用管理', dangerLevel: DangerLevel.medium),
      AdbCommandEntry(name: '清除数据', description: '清除应用所有数据', command: 'pm clear {package}', category: '应用管理', requireConfirm: true, dangerLevel: DangerLevel.high),
      AdbCommandEntry(name: '卸载应用', description: '卸载指定应用', command: 'pm uninstall {package}', category: '应用管理', requireConfirm: true, dangerLevel: DangerLevel.high),
      AdbCommandEntry(name: '获取包名', description: '获取当前前台应用包名', command: 'dumpsys window | grep -E "mCurrentFocus|mFocusedApp"', category: '应用管理', dangerLevel: DangerLevel.low),
    ],
  );

  static const screenOperationCategory = CommandCategory(
    name: '屏幕操作',
    icon: '🖥️',
    commands: [
      AdbCommandEntry(name: '截图', description: '截取当前屏幕', command: 'screencap -p /sdcard/screenshot.png', category: '屏幕操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '开始录屏', description: '开始屏幕录制', command: 'screenrecord /sdcard/video.mp4', category: '屏幕操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '停止录屏', description: '停止屏幕录制', command: 'pkill -l INT screenrecord', category: '屏幕操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '获取分辨率', description: '获取屏幕分辨率', command: 'wm size', category: '屏幕操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '获取屏幕密度', description: '获取屏幕密度', command: 'wm density', category: '屏幕操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '调节亮度', description: '设置屏幕亮度 (0-255)', command: 'settings put system screen_brightness {value}', category: '屏幕操作', dangerLevel: DangerLevel.low),
    ],
  );

  static const inputOperationCategory = CommandCategory(
    name: '输入操作',
    icon: '👆',
    commands: [
      AdbCommandEntry(name: '模拟点击', description: '模拟点击屏幕坐标', command: 'input tap {x} {y}', category: '输入操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '模拟滑动', description: '模拟屏幕滑动', command: 'input swipe {x1} {y1} {x2} {y2} {duration}', category: '输入操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '输入文本', description: '输入文本（需先聚焦输入框）', command: 'input text "{text}"', category: '输入操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '返回键', description: '按下返回键', command: 'input keyevent 4', category: '输入操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: 'Home键', description: '按下 Home 键', command: 'input keyevent 3', category: '输入操作', dangerLevel: DangerLevel.low),
    ],
  );

  static const fileOperationCategory = CommandCategory(
    name: '文件操作',
    icon: '📁',
    commands: [
      AdbCommandEntry(name: '列出文件', description: '列出目录下的文件', command: 'ls -la {path}', category: '文件操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '创建目录', description: '创建目录', command: 'mkdir -p {path}', category: '文件操作', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '删除文件', description: '删除指定文件', command: 'rm {path}', category: '文件操作', requireConfirm: true, dangerLevel: DangerLevel.high),
      AdbCommandEntry(name: '删除目录', description: '递归删除目录', command: 'rm -rf {path}', category: '文件操作', requireConfirm: true, dangerLevel: DangerLevel.dangerous),
    ],
  );

  static const networkCategory = CommandCategory(
    name: '网络',
    icon: '🌐',
    commands: [
      AdbCommandEntry(name: 'WiFi 信息', description: '获取 WiFi 连接信息', command: 'dumpsys wifi | grep "Wi-Fi"', category: '网络', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: 'IP 地址', description: '获取设备 IP 地址', command: 'ip addr show wlan0', category: '网络', dangerLevel: DangerLevel.low),
      AdbCommandEntry(name: '网络连接测试', description: '测试网络连接', command: 'ping -c 3 8.8.8.8', category: '网络', dangerLevel: DangerLevel.low),
    ],
  );

  static List<AdbCommandEntry> getAllCommands() {
    return getAllCategories().expand((c) => c.commands).toList();
  }

  static AdbCommandEntry? findCommand(String name) {
    try {
      return getAllCommands().firstWhere((c) => c.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<AdbCommandEntry> getCommandsByCategory(String category) {
    return getAllCommands().where((c) => c.category == category).toList();
  }
}
