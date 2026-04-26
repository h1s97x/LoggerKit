import '../strategy/error_strategy.dart';
import '../strategy/overflow_strategy.dart';
import 'log_level.dart';

/// Configuration for logging.
///
/// [LogConfig] contains all configuration options for the logging system including
/// which writers to enable, formatting options, and file rotation settings.
class LogConfig {
  /// Create a new [LogConfig].
  ///
  /// All parameters have sensible defaults and are optional.
  const LogConfig({
    this.minLevel = LogLevel.debug,
    this.enableConsole = true,
    this.enableFile = false,
    this.enableRemote = false,
    this.filePath,
    this.remoteUrl,
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFileCount = 5,
    this.includeTimestamp = true,
    this.includeTag = true,
    this.includeEmoji = true,
    this.prettyPrint = true,
    this.errorStrategy = ErrorStrategy.logToFallback,
    this.overflowStrategy = OverflowStrategy.dropOldest,
  });

  /// Minimum log level to record
  final LogLevel minLevel;

  /// Enable console output
  final bool enableConsole;

  /// Enable file logging
  final bool enableFile;

  /// Enable remote logging
  final bool enableRemote;

  /// Path for log files
  final String? filePath;

  /// URL for remote logging
  final String? remoteUrl;

  /// Maximum size of a log file in bytes
  final int maxFileSize;

  /// Maximum number of log files to keep
  final int maxFileCount;

  /// Include timestamp in logs
  final bool includeTimestamp;

  /// Include tag in logs
  final bool includeTag;

  /// Include emoji in logs
  final bool includeEmoji;

  /// Pretty print log output
  final bool prettyPrint;

  /// Error handling strategy
  final ErrorStrategy errorStrategy;

  /// Overflow handling strategy
  final OverflowStrategy overflowStrategy;

  /// Create a copy of this config with some fields replaced.
  ///
  /// Example:
  /// ```dart
  /// final newConfig = config.copyWith(minLevel: LogLevel.warning);
  /// ```
  LogConfig copyWith({
    LogLevel? minLevel,
    bool? enableConsole,
    bool? enableFile,
    bool? enableRemote,
    String? filePath,
    String? remoteUrl,
    int? maxFileSize,
    int? maxFileCount,
    bool? includeTimestamp,
    bool? includeTag,
    bool? includeEmoji,
    bool? prettyPrint,
    ErrorStrategy? errorStrategy,
    OverflowStrategy? overflowStrategy,
  }) {
    return LogConfig(
      minLevel: minLevel ?? this.minLevel,
      enableConsole: enableConsole ?? this.enableConsole,
      enableFile: enableFile ?? this.enableFile,
      enableRemote: enableRemote ?? this.enableRemote,
      filePath: filePath ?? this.filePath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      maxFileCount: maxFileCount ?? this.maxFileCount,
      includeTimestamp: includeTimestamp ?? this.includeTimestamp,
      includeTag: includeTag ?? this.includeTag,
      includeEmoji: includeEmoji ?? this.includeEmoji,
      prettyPrint: prettyPrint ?? this.prettyPrint,
      errorStrategy: errorStrategy ?? this.errorStrategy,
      overflowStrategy: overflowStrategy ?? this.overflowStrategy,
    );
  }
}
