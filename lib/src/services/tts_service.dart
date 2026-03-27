import 'package:flutter_tts/flutter_tts.dart';

class NativeTtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> initialize() async {
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  void dispose() {
    _tts.stop();
  }
}
