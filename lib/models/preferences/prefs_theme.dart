import 'dart:ui';

class PrefsTheme {
  bool darkTheme;
  Color primaryColor;
  Color accentColor;
  Color noteColor;

  PrefsTheme({
    required this.darkTheme,
    required this.primaryColor,
    required this.accentColor,
    required this.noteColor,
  });

  Brightness get brightness => this.darkTheme ? Brightness.dark : Brightness.light;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrefsTheme &&
          runtimeType == other.runtimeType &&
          darkTheme == other.darkTheme &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          noteColor == other.noteColor;

  @override
  int get hashCode =>
      darkTheme.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      noteColor.hashCode;
}
