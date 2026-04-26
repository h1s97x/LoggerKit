/// ANSI color codes for terminal output.
///
/// Example usage:
/// ```dart
/// print('${AnsiColor.red}Error${AnsiColor.reset}: Something went wrong');
/// ```
class AnsiColor {
  /// Reset formatting
  static const String reset = '\x1B[0m';

  /// Black
  static const String black = '\x1B[30m';

  /// Red
  static const String red = '\x1B[31m';

  /// Green
  static const String green = '\x1B[32m';

  /// Yellow
  static const String yellow = '\x1B[33m';

  /// Blue
  static const String blue = '\x1B[1B[38;5;12m';

  /// Magenta
  static const String magenta = '\x1B[35m';

  /// Cyan
  static const String cyan = '\x1B[36m';

  /// White
  static const String white = '\x1B[37m';

  /// Bright black (gray)
  static const String brightBlack = '\x1B[90m';

  /// Bright red
  static const String brightRed = '\x1B[91m';

  /// Bright green
  static const String brightGreen = '\x1B[92m';

  /// Bright yellow
  static const String brightYellow = '\x1B[93m';

  /// Bright blue
  static const String brightBlue = '\x1B[94m';

  /// Bright magenta
  static const String brightMagenta = '\x1B[95m';

  /// Bright cyan
  static const String brightCyan = '\x1B[96m';

  /// Bright white
  static const String brightWhite = '\x1B[97m';

  /// Bold
  static const String bold = '\x1B[1m';

  /// Dim
  static const String dim = '\x1B[2m';

  /// Italic
  static const String italic = '\x1B[3m';

  /// Underline
  static const String underline = '\x1B[4m';

  /// Background color: Red
  static const String bgRed = '\x1B[41m';

  /// Background color: Green
  static const String bgGreen = '\x1B[42m';

  /// Background color: Yellow
  static const String bgYellow = '\x1B[43m';

  /// Background color: Blue
  static const String bgBlue = '\x1B[44m';

  /// Wrap a string with color codes.
  static String wrap(String text, String color) {
    return '$color$text$reset';
  }

  /// Get color for log level.
  static String forLevel(int level) {
    if (level <= 1) return brightBlack; // debug
    if (level == 2) return blue; // info
    if (level == 3) return yellow; // warning
    if (level == 4) return red; // error
    return brightRed; // fatal
  }
}
