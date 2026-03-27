enum ScreenEventType { focus, click, scroll }

class ScreenEvent {
  const ScreenEvent({
    required this.type,
    required this.role,
    required this.name,
    required this.packageName,
    required this.sourcePlatform,
    this.hint,
    this.value,
  });

  final ScreenEventType type;
  final String role;
  final String name;
  final String packageName;
  final String sourcePlatform;
  final String? hint;
  final String? value;

  factory ScreenEvent.fromMap(Map<Object?, Object?> map) {
    return ScreenEvent(
      type: ScreenEventType.values.byName('${map['type'] ?? 'focus'}'),
      role: '${map['role'] ?? 'unknown'}',
      name: '${map['name'] ?? ''}',
      packageName: '${map['packageName'] ?? ''}',
      sourcePlatform: '${map['sourcePlatform'] ?? 'unknown'}',
      hint: map['hint'] as String?,
      value: map['value'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'type': type.name,
      'role': role,
      'name': name,
      'packageName': packageName,
      'sourcePlatform': sourcePlatform,
      'hint': hint,
      'value': value,
    };
  }
}
