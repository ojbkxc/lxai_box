import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 语音交互模式
enum VoiceMode {
  disabled,
  inputOnly,
  outputOnly,
  full,
}

/// 语音设置状态
class VoiceSettingsState {
  final VoiceMode mode;
  final String language;
  final double speechRate;
  final bool autoSpeak;

  const VoiceSettingsState({
    this.mode = VoiceMode.disabled,
    this.language = 'zh-CN',
    this.speechRate = 0.5,
    this.autoSpeak = false,
  });

  VoiceSettingsState copyWith({
    VoiceMode? mode,
    String? language,
    double? speechRate,
    bool? autoSpeak,
  }) {
    return VoiceSettingsState(
      mode: mode ?? this.mode,
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      autoSpeak: autoSpeak ?? this.autoSpeak,
    );
  }
}

/// 语音设置 Provider
class VoiceSettingsNotifier extends StateNotifier<VoiceSettingsState> {
  VoiceSettingsNotifier() : super(const VoiceSettingsState());

  void setMode(VoiceMode mode) => state = state.copyWith(mode: mode);
  void setLanguage(String language) => state = state.copyWith(language: language);
  void setSpeechRate(double rate) => state = state.copyWith(speechRate: rate);
  void setAutoSpeak(bool autoSpeak) => state = state.copyWith(autoSpeak: autoSpeak);
}

final voiceSettingsProvider =
    StateNotifierProvider<VoiceSettingsNotifier, VoiceSettingsState>(
  (ref) => VoiceSettingsNotifier(),
);
