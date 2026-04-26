/// Log level enumeration.
///
/// Defines the severity levels for log messages. Each level has a numeric value
/// for comparison, a name, and an emoji for visual representation.
///
/// The levels in order of severity are:
/// - [debug] - Detailed diagnostic information
/// - [info] - General informational messages
/// - [warning] - Warning messages for potentially problematic situations
/// - [error] - Error messages for error conditions
/// - [fatal] - Fatal messages for severe errors
enum LogLevel {
  /// Detailed diagnostic information
  debug(0, 'DEBUG', '🔍'),

  /// General informational messages
  info(1, 'INFO', 'ℹ️'),

  /// Warning messages for potentially problematic situations
  warning(2, 'WARNING', '⚠️'),

  /// Error messages for error conditions
  error(3, 'ERROR', '❌'),

  /// Fatal messages for severe errors
  fatal(4, 'FATAL', '💀');

  const LogLevel(this.value, this.name, this.emoji);

  /// The numeric value of this level (used for comparison)
  final int value;

  /// The name of this level
  final String name;

  /// The emoji representation of this level
  final String emoji;

  /// Check if this level should be logged given a minimum level.
  ///
  /// Returns true if this level's value is greater than or equal to [minLevel]'s value.
  bool shouldLog(LogLevel minLevel) {
    return value >= minLevel.value;
  }

  @override
  String toString() => name;
}
