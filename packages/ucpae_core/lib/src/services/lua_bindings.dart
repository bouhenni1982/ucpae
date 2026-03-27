import 'dart:ffi';

import 'package:ffi/ffi.dart';

typedef _LuaLNewStateNative = Pointer<Void> Function();
typedef _LuaLNewStateDart = Pointer<Void> Function();

typedef _LuaCloseNative = Void Function(Pointer<Void>);
typedef _LuaCloseDart = void Function(Pointer<Void>);

typedef _LuaLOpenLibsNative = Void Function(Pointer<Void>);
typedef _LuaLOpenLibsDart = void Function(Pointer<Void>);

typedef _LuaLLoadStringNative = Int32 Function(Pointer<Void>, Pointer<Utf8>);
typedef _LuaLLoadStringDart = int Function(Pointer<Void>, Pointer<Utf8>);

typedef _LuaPCallKNative =
    Int32 Function(Pointer<Void>, Int32, Int32, Int32, Int64, Pointer<Void>);
typedef _LuaPCallKDart =
    int Function(Pointer<Void>, int, int, int, int, Pointer<Void>);

typedef _LuaGetGlobalNative = Int32 Function(Pointer<Void>, Pointer<Utf8>);
typedef _LuaGetGlobalDart = int Function(Pointer<Void>, Pointer<Utf8>);

typedef _LuaGetFieldNative =
    Int32 Function(Pointer<Void>, Int32, Pointer<Utf8>);
typedef _LuaGetFieldDart = int Function(Pointer<Void>, int, Pointer<Utf8>);

typedef _LuaSetTopNative = Void Function(Pointer<Void>, Int32);
typedef _LuaSetTopDart = void Function(Pointer<Void>, int);

typedef _LuaCreateTableNative = Void Function(Pointer<Void>, Int32, Int32);
typedef _LuaCreateTableDart = void Function(Pointer<Void>, int, int);

typedef _LuaSetFieldNative = Void Function(Pointer<Void>, Int32, Pointer<Utf8>);
typedef _LuaSetFieldDart = void Function(Pointer<Void>, int, Pointer<Utf8>);

typedef _LuaPushStringNative =
    Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>);
typedef _LuaPushStringDart =
    Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>);

typedef _LuaPushNilNative = Void Function(Pointer<Void>);
typedef _LuaPushNilDart = void Function(Pointer<Void>);

typedef _LuaToLStringNative =
    Pointer<Utf8> Function(Pointer<Void>, Int32, Pointer<Size>);
typedef _LuaToLStringDart =
    Pointer<Utf8> Function(Pointer<Void>, int, Pointer<Size>);

typedef _LuaTypeNative = Int32 Function(Pointer<Void>, Int32);
typedef _LuaTypeDart = int Function(Pointer<Void>, int);

class LuaBindings {
  LuaBindings(this.library)
    : luaLNewState = library
          .lookupFunction<_LuaLNewStateNative, _LuaLNewStateDart>(
            'luaL_newstate',
          ),
      luaClose = library.lookupFunction<_LuaCloseNative, _LuaCloseDart>(
        'lua_close',
      ),
      luaLOpenLibs = library
          .lookupFunction<_LuaLOpenLibsNative, _LuaLOpenLibsDart>(
            'luaL_openlibs',
          ),
      luaLLoadString = library
          .lookupFunction<_LuaLLoadStringNative, _LuaLLoadStringDart>(
            'luaL_loadstring',
          ),
      luaPCallK = library.lookupFunction<_LuaPCallKNative, _LuaPCallKDart>(
        'lua_pcallk',
      ),
      luaGetGlobal = library
          .lookupFunction<_LuaGetGlobalNative, _LuaGetGlobalDart>(
            'lua_getglobal',
          ),
      luaGetField = library
          .lookupFunction<_LuaGetFieldNative, _LuaGetFieldDart>('lua_getfield'),
      luaSetTop = library.lookupFunction<_LuaSetTopNative, _LuaSetTopDart>(
        'lua_settop',
      ),
      luaCreateTable = library
          .lookupFunction<_LuaCreateTableNative, _LuaCreateTableDart>(
            'lua_createtable',
          ),
      luaSetField = library
          .lookupFunction<_LuaSetFieldNative, _LuaSetFieldDart>('lua_setfield'),
      luaPushString = library
          .lookupFunction<_LuaPushStringNative, _LuaPushStringDart>(
            'lua_pushstring',
          ),
      luaPushNil = library.lookupFunction<_LuaPushNilNative, _LuaPushNilDart>(
        'lua_pushnil',
      ),
      luaToLString = library
          .lookupFunction<_LuaToLStringNative, _LuaToLStringDart>(
            'lua_tolstring',
          ),
      luaType = library.lookupFunction<_LuaTypeNative, _LuaTypeDart>(
        'lua_type',
      );

  final DynamicLibrary library;
  final _LuaLNewStateDart luaLNewState;
  final _LuaCloseDart luaClose;
  final _LuaLOpenLibsDart luaLOpenLibs;
  final _LuaLLoadStringDart luaLLoadString;
  final _LuaPCallKDart luaPCallK;
  final _LuaGetGlobalDart luaGetGlobal;
  final _LuaGetFieldDart luaGetField;
  final _LuaSetTopDart luaSetTop;
  final _LuaCreateTableDart luaCreateTable;
  final _LuaSetFieldDart luaSetField;
  final _LuaPushStringDart luaPushString;
  final _LuaPushNilDart luaPushNil;
  final _LuaToLStringDart luaToLString;
  final _LuaTypeDart luaType;
}
