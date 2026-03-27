import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/screen_event.dart';

class AccessibilityBridge {
  AccessibilityBridge();

  static const MethodChannel _controlChannel =
      MethodChannel('ucpae/accessibility/control');
  static const EventChannel _eventChannel =
      EventChannel('ucpae/accessibility/events');

  final StreamController<ScreenEvent> _eventsController =
      StreamController<ScreenEvent>.broadcast();
  StreamSubscription<dynamic>? _nativeSubscription;
  Process? _windowsWorker;
  StreamSubscription<String>? _windowsWorkerSubscription;

  Stream<ScreenEvent> get events => _eventsController.stream;

  Future<void> start() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      await _startWindowsWorker();
      return;
    }

    _nativeSubscription ??=
        _eventChannel.receiveBroadcastStream().listen((dynamic payload) {
      if (payload is Map<Object?, Object?>) {
        _eventsController.add(ScreenEvent.fromMap(payload));
      }
    });

    try {
      await _controlChannel.invokeMethod<void>('startMonitoring');
    } on MissingPluginException {
      // Desktop and tests can still use injectDemoEvent without native hooks.
    }
  }

  Future<void> injectDemoEvent(ScreenEvent event) async {
    _eventsController.add(event);
  }

  Future<void> _startWindowsWorker() async {
    try {
      _windowsWorker ??= await Process.start(
        'windows\\worker\\Ucpae.AccessibilityWorker\\bin\\Debug\\net8.0-windows\\Ucpae.AccessibilityWorker.exe',
        <String>[],
      );

      _windowsWorkerSubscription ??= _windowsWorker!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((String line) {
        final dynamic payload = jsonDecode(line);
        if (payload is Map<String, dynamic>) {
          _eventsController.add(
            ScreenEvent.fromMap(payload.map(
              (String key, dynamic value) =>
                  MapEntry<Object?, Object?>(key, value),
            )),
          );
        }
      });
    } on ProcessException {
      // The demo app still works through injectDemoEvent if the worker is absent.
    }
  }

  void dispose() {
    _nativeSubscription?.cancel();
    _windowsWorkerSubscription?.cancel();
    _windowsWorker?.kill();
    _eventsController.close();
  }
}
