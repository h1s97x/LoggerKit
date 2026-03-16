import 'dart:async';
import '../models/log_record.dart';
import '../models/log_level.dart';
import '../models/log_config.dart';
import '../formatters/log_formatter.dart';
import '../writers/log_writer.dart';
import '../writers/file_writer.dart';
import '../writers/remote_writer.dart';
import '../filters/log_filter.dart';

/// Logger instance for recording logs.
///
/// [Logger] is responsible for formatting and writing log records to configured
/// destinations (console, file, remote). It applies filters to determine which
/// logs should be recorded.
///
/// Typically, you should use [LoggerKit] static methods instead of creating
/// [Logger] instances directly.
///
/// ## Usage
///
/// ```dart
/// final logger = Logger(config: LogConfig());
/// logger.d('Debug message');
/// logger.i('Info message');
/// logger.e('Error message', error: exception);
/// ```
class Logger {
  /// Create a new [Logger] instance.
  ///
  /// Parameters:
  /// - [config]: The [LogConfig] for this logger
  /// - [formatter]: Optional custom [LogFormatter] (defaults to [ColoredFormatter])
  Logger({
    required this.config,
    LogFormatter? formatter,
  }) : _formatter = formatter ?? ColoredFormatter() {
    _initWriters();
    _initFilters();
  }

  /// The logger configuration
  final LogConfig config;
  final List<LogWriter> _writers = [];
  final List<LogFilter> _filters = [];
  final LogFormatter _formatter;

  void _initWriters() {
    if (config.enableConsole) {
      _writers.add(ConsoleWriter());
    }

    if (config.enableFile && config.filePath != null) {
      _writers.add(FileWriter(config));
    }

    if (config.enableRemote && config.remoteUrl != null) {
      _writers.add(RemoteWriter(config));
    }
  }

  void _initFilters() {
    _filters.add(LevelFilter(config.minLevel));
  }

  /// Record a log message.
  ///
  /// This method applies filters and formatters to the log record, then writes it
  /// to all configured writers.
  ///
  /// Parameters:
  /// - [level]: The [LogLevel] of this log
  /// - [message]: The log message
  /// - [tag]: Optional tag to categorize the log
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace
  /// - [data]: Optional additional data
  Future<void> log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    // 应用过滤器
    if (!_shouldLog(record)) return;

    // 格式化
    final formatted = _formatter.format(record, config);

    // 写入
    await Future.wait(
      _writers.map((writer) => writer.write(record, formatted)),
    );
  }

  bool _shouldLog(LogRecord record) {
    return _filters.every((filter) => filter.shouldLog(record));
  }

  /// Log a debug message.
  void d(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Log an info message.
  void i(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Log a warning message.
  void w(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Log an error message.
  void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log a fatal message.
  void f(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Add a filter to this logger.
  ///
  /// Filters are applied in order to determine if a log record should be recorded.
  void addFilter(LogFilter filter) {
    _filters.add(filter);
  }

  /// Remove a filter from this logger.
  void removeFilter(LogFilter filter) {
    _filters.remove(filter);
  }

  /// Close this logger and release resources.
  ///
  /// This closes all writers and clears the writer list.
  Future<void> close() async {
    await Future.wait(_writers.map((writer) => writer.close()));
    _writers.clear();
  }
}
