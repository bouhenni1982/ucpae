enum LuaCommandType { speak, none }

class LuaCommand {
  const LuaCommand({
    required this.type,
    required this.payload,
  });

  final LuaCommandType type;
  final String payload;
}
