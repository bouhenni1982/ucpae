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
    final String workerPath = _resolveWorkerPath();
    _windowsWorker ??= await Process.start(
      workerPath,
      <String>[],
      workingDirectory: File(workerPath).parent.path,
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

  String _resolveWorkerPath() {
    final Directory exeDir = File(Platform.resolvedExecutable).parent;
    final List<String> candidates = <String>[
      'windows\\worker\\Ucpae.AccessibilityWorker\\bin\\Debug\\net8.0-windows\\Ucpae.AccessibilityWorker.exe',
      'windows\\worker\\Ucpae.AccessibilityWorker\\bin\\Release\\net8.0-windows\\Ucpae.AccessibilityWorker.exe',
      '${exeDir.path}\\worker\\Ucpae.AccessibilityWorker.exe',
      '${exeDir.path}\\data\\worker\\Ucpae.AccessibilityWorker.exe',
    ];

    for (final String candidate in candidates) {
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }

    throw StateError('Windows accessibility worker executable was not found.');
  }

  void dispose() {
    _windowsWorkerSubscription?.cancel();
    _windowsWorker?.kill();
    _eventsController.close();
  }
}
