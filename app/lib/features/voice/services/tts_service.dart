import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 语音合成服务状态
enum TtsState { playing, stopped, paused, continued }

/// 语音合成服务
class TtsService {
  final FlutterTts _tts = FlutterTts();
  TtsState _state = TtsState.stopped;
  final _stateController = StreamController<TtsState>.broadcast();
  final List<String> _queue = [];
  bool _isProcessing = false;

  Stream<TtsState> get stateStream => _stateController.stream;
  TtsState get state => _state;

  TtsService() {
    _init();
  }

  Future<void> _init() async {
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _state = TtsState.playing;
      _stateController.add(_state);
    });
    _tts.setCompletionHandler(() {
      _state = TtsState.stopped;
      _stateController.add(_state);
      _processNext();
    });
    _tts.setErrorHandler((msg) {
      _state = TtsState.stopped;
      _stateController.add(_state);
      _processNext();
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _queue.add(text);
    if (!_isProcessing) await _processNext();
  }

  Future<void> _processNext() async {
    if (_queue.isEmpty) {
      _isProcessing = false;
      return;
    }
    _isProcessing = true;
    final text = _queue.removeAt(0);
    try {
      await _tts.speak(text);
    } catch (e) {
      _processNext();
    }
  }

  Future<void> stop() async {
    _queue.clear();
    _isProcessing = false;
    await _tts.stop();
    _state = TtsState.stopped;
    _stateController.add(_state);
  }

  Future<void> pause() async {
    await _tts.pause();
    _state = TtsState.paused;
    _stateController.add(_state);
  }

  Future<void> setLanguage(String lang) => _tts.setLanguage(lang);
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);
  Future<void> setVolume(double vol) => _tts.setVolume(vol);
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  void dispose() {
    _stateController.close();
  }
}

/// TtsService Provider
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);
  return service;
});
