import 'package:flutter/material.dart';
import 'package:ucpae_core/ucpae_core.dart';

import 'android_accessibility_bridge.dart';
import 'android_tts_service.dart';

class UcpaeAndroidApp extends StatefulWidget {
  const UcpaeAndroidApp({super.key});

  @override
  State<UcpaeAndroidApp> createState() => _UcpaeAndroidAppState();
}

class _UcpaeAndroidAppState extends State<UcpaeAndroidApp> {
  final AndroidAccessibilityBridge _bridge = AndroidAccessibilityBridge();
  final LuaRuntimeEngine _luaEngine = LuaRuntimeEngine();
  final AndroidTtsService _ttsService = AndroidTtsService();
  final List<String> _log = <String>[];

  bool _isRunning = false;
  String? _error;
  LuaCommand? _lastCommand;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _luaEngine.initialize();
      await _ttsService.initialize();
      _bridge.events.listen((ScreenEvent event) async {
        final LuaCommand command = await _luaEngine.handle(event);
        setState(() {
          _lastCommand = command;
          _log.insert(0, '${event.type.name} -> ${command.payload}');
        });
        if (command.type == LuaCommandType.speak) {
          await _ttsService.speak(command.payload);
        }
      });
      await _bridge.start();
      setState(() {
        _isRunning = true;
      });
    } catch (error) {
      setState(() {
        _error = '$error';
      });
    }
  }

  Future<void> _sendDemoEvent() async {
    await _bridge.injectDemoEvent(
      const ScreenEvent(
        type: ScreenEventType.click,
        role: 'button',
        name: 'Play',
        packageName: 'demo.app',
        sourcePlatform: 'android-demo',
      ),
    );
  }

  @override
  void dispose() {
    _bridge.dispose();
    _luaEngine.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UCPAE Android',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6E4F)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('UCPAE Android')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_error ?? (_isRunning ? 'Android bridge is running.' : 'Starting Android bridge...')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _error == null ? _sendDemoEvent : null,
                child: const Text('Trigger Android Demo Event'),
              ),
              const SizedBox(height: 16),
              Text('Last command: ${_lastCommand?.payload ?? 'None'}'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _log.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text(_log[index]));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
