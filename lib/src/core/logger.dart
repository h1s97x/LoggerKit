import 'dart:async';
import '../models/log_record.dart';
import '../models/log_level.dart';
import '../models/log_config.dart';
import '../formatters/log_formatter.dart';
import '../writers/log_writer.dart';
import '../writers/file_writer.dart';
import '../writers/remote_writer.dart';
import '../filters/log_filter.dart';
import '../interceptors/log_interceptor.dart';
import '../pretty/pretty_printer.dart';
import '../strategy/error_strategy.dart';
import '../strategy/overflow_strategy.dart';

/// Logger instance for recording logs.
///
/// [Logger] is responsible for formatting and writing log records to configured
/// destinations (console, file, remote). It applies filters to determine which
/// logs should be recorded, and interceptors to modify records before writing.
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
///
/// ## Namespace Usage
///
/// Loggers can be created with a namespace for modular logging:
///
/// ```dart
/// final networkLogger = Logger(config: LogConfig(), namespace: 'network');
/// networkLogger.i('API request sent');
/// ```
class Logger {
  /// Create a new [Logger] instance.
  ///
  /// Parameters:
  /// - [config]: The [LogConfig] for this logger
  /// - [formatter]: Optional custom [LogFormatter] (defaults to [ColoredFormatter])
  /// - [namespace]: Optional namespace for this logger
  /// - [errorStrategy]: Strategy for handling writer errors (defaults to [ErrorStrategy.ignore])
  /// - [overflowStrategy]: Strategy for handling queue overflow (defaults to [OverflowStrategy.dropOldest])
  /// - [prettyPrinter]: Pretty printer for console output (defaults to null, disabled)
  Logger({
    required this.config,
    LogFormatter? formatter,
    String? namespace,
    this.errorStrategy = ErrorStrategy.ignore,
    this.overflowStrategy = OverflowStrategy.dropOldest,
    PrettyPrinter? prettyPrinter,
  })  : _formatter = formatter ?? ColoredFormatter(),
        _namespace = namespace,
        _prettyPrinter = prettyPrinter {
    _initWriters();
    _initFilters();
  }

  /// The logger configuration
  final LogConfig config;

  /// The namespace for this logger
  final String? _namespace;

  /// The error strategy
  final ErrorStrategy errorStrategy;

  /// The overflow strategy
  final OverflowStrategy overflowStrategy;

  /// The pretty printer (may be null)
  final PrettyPrinter? _prettyPrinter;

  final List<LogWriter> _writers = [];
  final List<LogFilter> _filters = [];
  final List<LogInterceptor> _interceptors = [];
  final LogFormatter _formatter;

  void _initWriters() {
    if (config.enableConsole) {
      _writers.add(ConsoleWriter(prettyPrinter: _prettyPrinter));
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

  /// The namespace of this logger.
  ///
  /// Returns the namespace string if set, null otherwise.
  String? get namespace => _namespace;

  /// Record a log message.
  ///
  /// This method applies interceptors, filters, and formatters to the log record,
  /// then writes it to all configured writers.
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
    // Create the record
    LogRecord record = LogRecord(
      level: level,
      message: message,
      tag: tag ?? _namespace, // Use namespace as default tag
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    // Apply interceptors (in order)
    for (final interceptor in _interceptors) {
      record = interceptor.intercept(record) ?? record;
    }

    // Apply filters
    if (!_shouldLog(record)) return;

    // Format
    final formatted = _formatter.format(record, config);

    // Write to all destinations with error handling
    await _writeWithErrorHandling(record, formatted);
  }

  /// Writes to all writers with error handling based on [ErrorStrategy].
  Future<void> _writeWithErrorHandling(
    LogRecord record,
    String formatted,
  ) async {
    final errors = <Object>[];

    for (final writer in _writers) {
      try {
        await writer.write(record, formatted);
      } catch (e, st) {
        errors.add(e);

        switch (config.errorStrategy) {
          case ErrorStrategy.ignore:
            // Silently ignore errors
            break;
          case ErrorStrategy.logToFallback:
            // Log to console as fallback
            _logFallbackError(record, e, st);
            break;
          case ErrorStrategy.throwException:
            // Rethrow if any writer fails
            rethrow;
        }
      }
    }

    // If all writers failed and strategy is not throwException, throw aggregated error
    if (errors.isNotEmpty &&
        errors.length == _writers.length &&
        config.errorStrategy != ErrorStrategy.throwException) {
      throw LoggerException(
        'All ${_writers.length} writers failed',
        errors: errors,
      );
    }
  }

  /// Logs error to console as fallback when writer fails.
  void _logFallbackError(
    LogRecord record,
    Object error,
    StackTrace stackTrace,
  ) {
    try {
      // Use stderr for fallback errors
      // ignore: avoid_print
      print(
        '\x1B[31m[FALLBACK ERROR]\x1B[0m Failed to write log: $error',
      );
    } catch (_) {
      // Last resort: ignore
    }
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

  /// Log a verbose message.
  ///
  /// Verbose logs are below debug level and may be filtered out in production.
  void v(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.debug, message, tag: tag, data: data);
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

  /// Add an interceptor to this logger.
  ///
  /// Interceptors are executed in order before the log is written.
  /// Lower order values execute first.
  ///
  /// ```dart
  /// logger.addInterceptor(MyInterceptor());
  /// ```
  void addInterceptor(LogInterceptor interceptor) {
    _interceptors.add(interceptor);
    _interceptors.sort((a, b) => a.order.compareTo(b.order));
  }

  /// Remove an interceptor from this logger.
  void removeInterceptor(LogInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Get all interceptors.
  List<LogInterceptor> get interceptors => List.unmodifiable(_interceptors);

  /// Get all filters.
  List<LogFilter> get filters => List.unmodifiable(_filters);

  /// Get all writers.
  List<LogWriter> get writers => List.unmodifiable(_writers);

  /// Update the configuration.
  ///
  /// This recreates writers based on the new config.
  void updateConfig(LogConfig newConfig) {
    // Close existing writers
    Future.wait(_writers.map((w) => w.close())).then((_) {
      // Recreate writers with new config
      _writers.clear();

      if (newConfig.enableConsole) {
        _writers.add(ConsoleWriter());
      }
      if (newConfig.enableFile && newConfig.filePath != null) {
        _writers.add(FileWriter(newConfig));
      }
      if (newConfig.enableRemote && newConfig.remoteUrl != null) {
        _writers.add(RemoteWriter(newConfig));
      }
    });
  }

  /// Close this logger and release resources.
  ///
  /// This closes all writers and clears the writer list.
  Future<void> close() async {
    await Future.wait(_writers.map((writer) => writer.close()));
    _writers.clear();
  }

  /// Flush buffered writes.
  ///
  /// This waits for all pending writes to complete.
  Future<void> flush() async {
    await Future.wait(_writers.map((writer) => writer.flush()));
  }
}
