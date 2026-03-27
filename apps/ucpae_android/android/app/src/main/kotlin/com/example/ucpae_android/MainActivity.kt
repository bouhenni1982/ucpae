package com.example.ucpae_android

import com.example.ucpae_android.accessibility.UcpaeAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ucpae/accessibility/events"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                UcpaeAccessibilityService.sink = events
            }

            override fun onCancel(arguments: Any?) {
                UcpaeAccessibilityService.sink = null
            }
        })

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ucpae/accessibility/control"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMonitoring" -> result.success(null)
                else -> result.notImplemented()
            }
        }
    }
}
