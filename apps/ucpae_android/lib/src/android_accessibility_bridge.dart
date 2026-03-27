import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ucpae_core/ucpae_core.dart';

class AndroidAccessibilityBridge {
  static const MethodChannel _controlChannel =
      MethodChannel('ucpae/accessibility/control');
  static const EventChannel _eventChannel =
      EventChannel('ucpae/accessibility/events');

  final StreamController<ScreenEvent> _eventsController =
      StreamController<ScreenEvent>.broadcast();
  StreamSubscription<dynamic>? _nativeSubscription;

  Stream<ScreenEvent> get events => _eventsController.stream;

  Future<void> start() async {
    _nativeSubscription ??=
        _eventChannel.receiveBroadcastStream().listen((dynamic payload) {
      if (payload is Map<Object?, Object?>) {
        _eventsController.add(ScreenEvent.fromMap(payload));
      }
    });

    await _controlChannel.invokeMethod<void>('startMonitoring');
  }

  Future<void> injectDemoEvent(ScreenEvent event) async {
    _eventsController.add(event);
  }

  void dispose() {
    _nativeSubscription?.cancel();
    _eventsController.close();
  }
}
