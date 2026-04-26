import '../models/log_record.dart';

/// Abstract interface for log pretty printing.
///
/// [PrettyPrinter] is responsible for formatting [LogRecord] objects
/// into human-readable strings with optional ANSI colors, stack trace
/// formatting, and multi-line collapsing.
abstract class PrettyPrinter {
  /// Format a log record into a pretty string.
  String format(LogRecord record);

  /// Format a log record with ANSI colors for terminal output.
  String formatColored(LogRecord record);

  /// Format a stack trace for better readability.
  String formatStackTrace(StackTrace stackTrace);

  /// Check if output should use colors (can be disabled).
  bool get useColors;

  /// Set whether to use colors.
  set useColors(bool value);

  /// Get the maximum line width for wrapping.
  int get maxLineWidth;

  /// Set the maximum line width.
  set maxLineWidth(int value);
}

/// Configuration options for [PrettyPrinter].
class PrettyPrinterConfig {
  /// Create a new configuration.
  const PrettyPrinterConfig({
    this.useColors = true,
    this.maxLineWidth = 80,
    this.maxStackTraceLines = 10,
    this.stackTraceIndent = 2,
    this.messageIndent = 2,
    this.collapseMultiLine = true,
    this.collapseThreshold = 3,
    this.errorPrefix = 'ERROR',
    this.stackTracePrefix = 'STACK TRACE',
    this.timestampFormat = 'yyyy-MM-dd HH:mm:ss.SSS',
  });

  /// Whether to use ANSI colors.
  final bool useColors;

  /// Maximum line width for wrapping.
  final int maxLineWidth;

  /// Maximum number of stack trace lines to show.
  final int maxStackTraceLines;

  /// Indentation for stack trace lines.
  final int stackTraceIndent;

  /// Indentation for message lines.
  final int messageIndent;

  /// Whether to collapse multi-line messages.
  final bool collapseMultiLine;

  /// Number of lines threshold for collapsing.
  final int collapseThreshold;

  /// Prefix for error messages.
  final String errorPrefix;

  /// Prefix for stack trace.
  final String stackTracePrefix;

  /// Format string for timestamp.
  final String timestampFormat;

  /// Create a copy with optional overrides.
  PrettyPrinterConfig copyWith({
    bool? useColors,
    int? maxLineWidth,
    int? maxStackTraceLines,
    int? stackTraceIndent,
    int? messageIndent,
    bool? collapseMultiLine,
    int? collapseThreshold,
    String? errorPrefix,
    String? stackTracePrefix,
    String? timestampFormat,
  }) {
    return PrettyPrinterConfig(
      useColors: useColors ?? this.useColors,
      maxLineWidth: maxLineWidth ?? this.maxLineWidth,
      maxStackTraceLines: maxStackTraceLines ?? this.maxStackTraceLines,
      stackTraceIndent: stackTraceIndent ?? this.stackTraceIndent,
      messageIndent: messageIndent ?? this.messageIndent,
      collapseMultiLine: collapseMultiLine ?? this.collapseMultiLine,
      collapseThreshold: collapseThreshold ?? this.collapseThreshold,
      errorPrefix: errorPrefix ?? this.errorPrefix,
      stackTracePrefix: stackTracePrefix ?? this.stackTracePrefix,
      timestampFormat: timestampFormat ?? this.timestampFormat,
    );
  }
}
