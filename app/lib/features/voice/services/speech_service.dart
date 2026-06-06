import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 语音识别状态
enum SpeechStatus { uninitialized, ready, listening, done, error }

/// 语音识别结果
class SpeechResult {
  final String text;
  final bool isFinal;
  final double confidence;

  const SpeechResult({
    required this.text,
    this.isFinal = false,
    this.confidence = 0.0,
  });
}

/// 语音识别服务
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  SpeechStatus _status = SpeechStatus.uninitialized;
  final _resultController = StreamController<SpeechResult>.broadcast();

  SpeechStatus get status => _status;
  Stream<SpeechResult> get resultStream => _resultController.stream;
  bool get isListening => _speech.isListening;

  Future<void> init() async {
    try {
      final available = await _speech.initialize(
        onError: (error) {
          _status = SpeechStatus.error;
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _status = SpeechStatus.done;
          }
        },
      );
      _status = available ? SpeechStatus.ready : SpeechStatus.error;
    } catch (e) {
      _status = SpeechStatus.error;
    }
  }

  Future<void> startListening({String localeId = 'zh_CN', Duration? listenFor}) async {
    if (_status != SpeechStatus.ready && _status != SpeechStatus.done) {
      await init();
    }
    if (_speech.isAvailable) {
      _status = SpeechStatus.listening;
      await _speech.listen(
        onResult: (result) {
          _resultController.add(SpeechResult(
            text: result.recognizedWords,
            isFinal: result.finalResult,
            confidence: result.confidence,
          ));
        },
        localeId: localeId,
        listenFor: listenFor ?? const Duration(seconds: 30),
        cancelOnError: true,
        partialResults: true,
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _status = SpeechStatus.done;
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    _status = SpeechStatus.ready;
  }

  Future<List<LocaleName>> getAvailableLanguages() async {
    return await _speech.locales();
  }

  void dispose() {
    _resultController.close();
  }
}

/// SpeechService Provider
final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(service.dispose);
  return service;
});
