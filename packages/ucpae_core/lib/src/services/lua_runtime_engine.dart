import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/lua_command.dart';
import '../models/screen_event.dart';
import 'lua_bindings.dart';

class LuaRuntimeEngine {
  static const int _luaOk = 0;
  static const int _luaTypeTable = 5;
  static const String _assetPrefix = 'packages/ucpae_core/assets/lua';

  ffi.Pointer<ffi.Void>? _state;
  LuaBindings? _bindings;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    final ffi.DynamicLibrary library = _openLuaLibrary();
    final LuaBindings bindings = LuaBindings(library);
    final ffi.Pointer<ffi.Void> state = bindings.luaLNewState();

    if (state == ffi.nullptr) {
      throw StateError('Failed to create Lua state.');
    }

    bindings.luaLOpenLibs(state);

    final String coreScript = await rootBundle.loadString(
      '$_assetPrefix/core.lua',
    );
    final String rulesScript = await rootBundle.loadString(
      '$_assetPrefix/default_rules.lua',
    );
    final String extensionScript = await rootBundle.loadString(
      '$_assetPrefix/extensions/sample_extension.lua',
    );

    final String bootstrap =
        '''
ucpae_core = (function()
$coreScript
end)()

ucpae_rules = (function()
$rulesScript
end)()

ucpae_extension_1 = (function()
$extensionScript
end)()

function ucpae_handle(event)
  return ucpae_core.process_event(event, { ucpae_extension_1 })
end
''';

    _executeChunk(bindings, state, bootstrap);

    _bindings = bindings;
    _state = state;
    _initialized = true;
  }

  Future<LuaCommand> handle(ScreenEvent event) async {
    final LuaBindings bindings = _bindings!;
    final ffi.Pointer<ffi.Void> state = _state!;

    bindings.luaSetTop(state, 0);
    _pushGlobalFunction(bindings, state, 'ucpae_handle');
    _pushEventTable(bindings, state, event);

    final int callResult = bindings.luaPCallK(state, 1, 1, 0, 0, ffi.nullptr);
    if (callResult != _luaOk) {
      final String message =
          _readString(bindings, state, -1) ?? 'Unknown Lua error';
      bindings.luaSetTop(state, 0);
      throw StateError('Lua runtime failed while handling event: $message');
    }

    if (bindings.luaType(state, -1) != _luaTypeTable) {
      bindings.luaSetTop(state, 0);
      return const LuaCommand(type: LuaCommandType.none, payload: '');
    }

    final String action =
        _readTableStringField(bindings, state, -1, 'action') ?? 'none';
    final String text =
        _readTableStringField(bindings, state, -1, 'text') ?? '';
    bindings.luaSetTop(state, 0);

    return LuaCommand(
      type: action == 'speak' ? LuaCommandType.speak : LuaCommandType.none,
      payload: text,
    );
  }

  void dispose() {
    final ffi.Pointer<ffi.Void>? state = _state;
    final LuaBindings? bindings = _bindings;
    if (state != null && bindings != null) {
      bindings.luaClose(state);
    }
    _state = null;
    _bindings = null;
    _initialized = false;
  }

  ffi.DynamicLibrary _openLuaLibrary() {
    if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('lua54.dll');
    }
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('liblua.so');
    }
    throw UnsupportedError(
      'Lua runtime is currently configured for Windows and Android only.',
    );
  }

  void _executeChunk(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    String script,
  ) {
    final ffi.Pointer<Utf8> source = script.toNativeUtf8();
    try {
      final int loadResult = bindings.luaLLoadString(state, source);
      if (loadResult != _luaOk) {
        final String message =
            _readString(bindings, state, -1) ?? 'Unknown load error';
        bindings.luaSetTop(state, 0);
        throw StateError('Unable to load Lua bootstrap: $message');
      }

      final int callResult = bindings.luaPCallK(state, 0, 0, 0, 0, ffi.nullptr);
      if (callResult != _luaOk) {
        final String message =
            _readString(bindings, state, -1) ?? 'Unknown call error';
        bindings.luaSetTop(state, 0);
        throw StateError('Unable to execute Lua bootstrap: $message');
      }
    } finally {
      malloc.free(source);
    }
  }

  void _pushGlobalFunction(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    String name,
  ) {
    final ffi.Pointer<Utf8> global = name.toNativeUtf8();
    try {
      bindings.luaGetGlobal(state, global);
    } finally {
      malloc.free(global);
    }
  }

  void _pushEventTable(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    ScreenEvent event,
  ) {
    bindings.luaCreateTable(state, 0, 7);
    _setStringField(bindings, state, 'type', event.type.name);
    _setStringField(bindings, state, 'role', event.role);
    _setStringField(bindings, state, 'name', event.name);
    _setStringField(bindings, state, 'packageName', event.packageName);
    _setStringField(bindings, state, 'sourcePlatform', event.sourcePlatform);
    _setNullableStringField(bindings, state, 'hint', event.hint);
    _setNullableStringField(bindings, state, 'value', event.value);
  }

  void _setStringField(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    String key,
    String value,
  ) {
    final ffi.Pointer<Utf8> luaValue = value.toNativeUtf8();
    final ffi.Pointer<Utf8> luaKey = key.toNativeUtf8();
    try {
      bindings.luaPushString(state, luaValue);
      bindings.luaSetField(state, -2, luaKey);
    } finally {
      malloc.free(luaValue);
      malloc.free(luaKey);
    }
  }

  void _setNullableStringField(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    String key,
    String? value,
  ) {
    final ffi.Pointer<Utf8> luaKey = key.toNativeUtf8();
    try {
      if (value == null) {
        bindings.luaPushNil(state);
      } else {
        final ffi.Pointer<Utf8> luaValue = value.toNativeUtf8();
        try {
          bindings.luaPushString(state, luaValue);
        } finally {
          malloc.free(luaValue);
        }
      }
      bindings.luaSetField(state, -2, luaKey);
    } finally {
      malloc.free(luaKey);
    }
  }

  String? _readTableStringField(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    int index,
    String field,
  ) {
    final ffi.Pointer<Utf8> luaField = field.toNativeUtf8();
    try {
      bindings.luaGetField(state, index, luaField);
      final String? value = _readString(bindings, state, -1);
      bindings.luaSetTop(state, -2);
      return value;
    } finally {
      malloc.free(luaField);
    }
  }

  String? _readString(
    LuaBindings bindings,
    ffi.Pointer<ffi.Void> state,
    int index,
  ) {
    final ffi.Pointer<ffi.Size> length = malloc<ffi.Size>();
    try {
      final ffi.Pointer<Utf8> value = bindings.luaToLString(
        state,
        index,
        length,
      );
      if (value == ffi.nullptr) {
        return null;
      }
      return value.toDartString(length: length.value);
    } finally {
      malloc.free(length);
    }
  }
}
