import 'package:flutter/material.dart';

import 'models/lua_command.dart';
import 'models/screen_event.dart';
import 'services/accessibility_bridge.dart';
import 'services/lua_runtime_engine.dart';
import 'services/tts_service.dart';

class UcpaeApp extends StatefulWidget {
  const UcpaeApp({super.key});

  @override
  State<UcpaeApp> createState() => _UcpaeAppState();
}

class _UcpaeAppState extends State<UcpaeApp> {
  final AccessibilityBridge _bridge = AccessibilityBridge();
  final LuaRuntimeEngine _luaEngine = LuaRuntimeEngine();
  final NativeTtsService _ttsService = NativeTtsService();
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
        sourcePlatform: 'flutter-demo',
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
      title: 'UCPAE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('UCPAE Hello World'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _error != null
                    ? 'Lua runtime failed to start.'
                    : _isRunning
                        ? 'Bridge is listening for accessibility events.'
                        : 'Starting background bridge...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Place lua54.dll beside the Windows executable or liblua.so in the Android native libraries.',
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Last Lua command'),
                      const SizedBox(height: 8),
                      Text(_lastCommand?.payload ?? 'No commands yet'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _error == null ? _sendDemoEvent : null,
                child: const Text('Trigger Demo Tap Event'),
              ),
              const SizedBox(height: 24),
              const Text('Event Log'),
              const SizedBox(height: 8),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: _log.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        title: Text(_log[index]),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
