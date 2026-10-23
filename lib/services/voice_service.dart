import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:record/record.dart';

class VoiceService {
  final VoskFlutterPlugin _vosk = VoskFlutterPlugin.instance();
  Model? _model;
  Recognizer? _recognizer;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioStreamSub;
  Timer? _silenceTimer;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initModel(Function(String status) onStatusChanged) async {
    try {
      onStatusChanged('Загрузка языковой модели...');
      String modelPath = await ModelLoader().loadFromAssets('assets/models/vosk-model-small-ru-0.22.zip');
      _model = await _vosk.createModel(modelPath);
      _recognizer = await _vosk.createRecognizer(model: _model!, sampleRate: 16000);
      _isInitialized = true;
      onStatusChanged('Модель загружена. Готовы к работе!');
    } catch (e) {
      onStatusChanged('Ошибка инициализации: $e');
    }
  }

  Future<void> startListening({
    required Function(String text) onPartial,
    required VoidCallback onSilenceTimeout,
  }) async {
    if (!_isInitialized || _recognizer == null) return;
    if (!await _audioRecorder.hasPermission()) return;

    await _recognizer?.dispose();
    _recognizer = await _vosk.createRecognizer(model: _model!, sampleRate: 16000);

    const recordConfig = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );

    final stream = await _audioRecorder.startStream(recordConfig);
    _resetSilenceTimer(onSilenceTimeout);

    _audioStreamSub = stream.listen((data) async {
      if (_recognizer != null) {
        final isFinal = await _recognizer!.acceptWaveformBytes(data);
        if (isFinal) {
          final resJson = await _recognizer!.getResult();
          final decoded = jsonDecode(resJson);
          final text = decoded['text'] ?? '';
          if (text.isNotEmpty) {
            onPartial(text);
            _resetSilenceTimer(onSilenceTimeout);
          }
        } else {
          final partialJson = await _recognizer!.getPartialResult();
          final decoded = jsonDecode(partialJson);
          final partial = decoded['partial'] ?? '';
          if (partial.isNotEmpty) {
            onPartial(partial);
            _resetSilenceTimer(onSilenceTimeout);
          }
        }
      }
    });
  }

  void _resetSilenceTimer(VoidCallback onSilenceTimeout) {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(milliseconds: 1500), () {
      onSilenceTimeout();
    });
  }

  Future<String> stopListening() async {
    _silenceTimer?.cancel();
    await _audioStreamSub?.cancel();
    await _audioRecorder.stop();

    if (_recognizer != null) {
      final finalJson = await _recognizer!.getResult();
      final decoded = jsonDecode(finalJson);
      return decoded['text'] ?? '';
    }
    return '';
  }

  void dispose() {
    _silenceTimer?.cancel();
    _audioStreamSub?.cancel();
    _audioRecorder.dispose();
    _recognizer?.dispose();
    _model?.dispose();
  }
}