import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ucpae_core/ucpae_core.dart';

class WindowsAccessibilityBridge {
  final StreamController<ScreenEvent> _eventsController =
      StreamController<ScreenEvent>.broadcast();
  Process? _windowsWorker;
  StreamSubscription<String>? _windowsWorkerSubscription;

  Stream<ScreenEvent> get events => _eventsController.stream;

  Future<void> start() async {
    _windowsWorker ??= await Process.start(
      'windows\\worker\\Ucpae.AccessibilityWorker\\bin\\Debug\\net8.0-windows\\Ucpae.AccessibilityWorker.exe',
      <String>[],
      workingDirectory: Directory.current.path,
    );

    _windowsWorkerSubscription ??= _windowsWorker!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((String line) {
      final dynamic payload = jsonDecode(line);
      if (payload is Map<String, dynamic>) {
        _eventsController.add(
          ScreenEvent.fromMap(
            payload.map(
              (String key, dynamic value) => MapEntry<Object?, Object?>(key, value),
            ),
          ),
        );
      }
    });
  }

  Future<void> injectDemoEvent(ScreenEvent event) async {
    _eventsController.add(event);
  }

  void dispose() {
    _windowsWorkerSubscription?.cancel();
    _windowsWorker?.kill();
    _eventsController.close();
  }
}
