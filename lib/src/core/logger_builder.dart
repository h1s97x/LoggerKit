import '../models/log_level.dart';
import '../models/log_config.dart';
import '../models/log_context.dart';
import '../interceptors/log_interceptor.dart';
import 'logger.dart';
import 'logger_kit.dart';

/// Builder for configuring and creating [Logger] instances.
///
/// The builder provides a fluent API for configuring logging options
/// before creating a logger instance.
///
/// ## Usage
///
/// ```dart
/// // Basic usage
/// final logger = LoggerKit.builder()
///   ..minLevel(LogLevel.info)
///   ..console()
///   ..build();
///
/// // Advanced usage
/// final logger = LoggerKit.builder()
///   ..minLevel(LogLevel.debug)
///   ..console(prettyPrint: true)
///   ..file(path: './logs', maxSize: 10 * 1024 * 1024)
///   ..remote(url: 'https://api.example.com/logs')
///   ..context(LogContext(userId: 'user_123'))
///   ..privacyFields(['password', 'token'])
///   ..addInterceptor(MyCustomInterceptor())
///   ..build();
/// ```
class LoggerBuilder {
  /// Create a new [LoggerBuilder].
  LoggerBuilder();

  // Configuration state
  LogLevel _minLevel = LogLevel.debug;
  bool _enableConsole = true;
  bool _enableFile = false;
  String? _filePath;
  int _maxFileSize = 10 * 1024 * 1024; // 10MB
  int _maxFileCount = 5;
  bool _enableRemote = false;
  String? _remoteUrl;
  bool _includeTimestamp = true;
  bool _includeTag = true;
  bool _includeEmoji = true;
  bool _prettyPrint = true;
  LogContext? _context;
  final List<LogInterceptor> _interceptors = [];

  // Reserved for future use (Remote logging configuration)
  // ignore: unused_field
  int? _remoteBatchSize;
  // ignore: unused_field
  int? _remoteFlushInterval;
  // ignore: unused_field
  List<String>? _privacyFields;

  /// Set the minimum log level.
  ///
  /// Only logs at or above this level will be recorded.
  /// Default is [LogLevel.debug].
  ///
  /// ```dart
  /// ..minLevel(LogLevel.info)  // Ignore debug logs
  /// ```
  LoggerBuilder minLevel(LogLevel level) {
    _minLevel = level;
    return this;
  }

  /// Enable console output.
  ///
  /// ```dart
  /// ..console()  // Enable with defaults
  /// ..console(prettyPrint: true)  // With options
  /// ```
  LoggerBuilder console({bool? prettyPrint}) {
    _enableConsole = true;
    if (prettyPrint != null) {
      _prettyPrint = prettyPrint;
    }
    return this;
  }

  /// Disable console output.
  LoggerBuilder noConsole() {
    _enableConsole = false;
    return this;
  }

  /// Enable file logging.
  ///
  /// ```dart
  /// ..file(path: './logs')
  /// ..file(path: './logs', maxSize: 5 * 1024 * 1024, maxCount: 10)
  /// ```
  LoggerBuilder file({
    String? path,
    int? maxSize,
    int? maxCount,
  }) {
    _enableFile = true;
    if (path != null) _filePath = path;
    if (maxSize != null) _maxFileSize = maxSize;
    if (maxCount != null) _maxFileCount = maxCount;
    return this;
  }

  /// Disable file logging.
  LoggerBuilder noFile() {
    _enableFile = false;
    return this;
  }

  /// Enable remote logging.
  ///
  /// ```dart
  /// ..remote(url: 'https://api.example.com/logs')
  /// ..remote(url: 'https://api.example.com/logs', batchSize: 20)
  /// ```
  LoggerBuilder remote({
    String? url,
    int? batchSize,
    int? flushInterval,
  }) {
    _enableRemote = true;
    if (url != null) _remoteUrl = url;
    if (batchSize != null) _remoteBatchSize = batchSize;
    if (flushInterval != null) _remoteFlushInterval = flushInterval;
    return this;
  }

  /// Disable remote logging.
  LoggerBuilder noRemote() {
    _enableRemote = false;
    return this;
  }

  /// Configure timestamp display.
  LoggerBuilder timestamp(bool include) {
    _includeTimestamp = include;
    return this;
  }

  /// Configure tag display.
  LoggerBuilder tag(bool include) {
    _includeTag = include;
    return this;
  }

  /// Configure emoji display.
  LoggerBuilder emoji(bool include) {
    _includeEmoji = include;
    return this;
  }

  /// Configure pretty print for console output.
  LoggerBuilder prettyPrint(bool enable) {
    _prettyPrint = enable;
    return this;
  }

  /// Set privacy fields that should be filtered.
  ///
  /// These field names will be automatically masked in logs.
  ///
  /// ```dart
  /// ..privacyFields(['password', 'token', 'creditCard'])
  /// ```
  LoggerBuilder privacyFields(List<String> fields) {
    _privacyFields = List.from(fields);
    return this;
  }

  /// Set initial context.
  ///
  /// ```dart
  /// ..context(LogContext(userId: 'user_123'))
  /// ```
  LoggerBuilder context(LogContext context) {
    _context = context;
    return this;
  }

  /// Add a log interceptor.
  ///
  /// Interceptors are executed in order of their `order` property.
  ///
  /// ```dart
  /// ..addInterceptor(MyInterceptor())
  /// ```
  LoggerBuilder addInterceptor(LogInterceptor interceptor) {
    _interceptors.add(interceptor);
    return this;
  }

  /// Add multiple interceptors.
  LoggerBuilder addInterceptors(List<LogInterceptor> interceptors) {
    _interceptors.addAll(interceptors);
    return this;
  }

  /// Build the logger instance with current configuration.
  ///
  /// This creates and returns a [Logger] instance configured according
  /// to all previously set options.
  ///
  /// ```dart
  /// final logger = LoggerKit.builder()
  ///   ..minLevel(LogLevel.info)
  ///   ..console()
  ///   ..build();
  /// ```
  Logger build() {
    // Create config from builder state
    final config = LogConfig(
      minLevel: _minLevel,
      enableConsole: _enableConsole,
      enableFile: _enableFile,
      enableRemote: _enableRemote,
      filePath: _filePath,
      remoteUrl: _remoteUrl,
      maxFileSize: _maxFileSize,
      maxFileCount: _maxFileCount,
      includeTimestamp: _includeTimestamp,
      includeTag: _includeTag,
      includeEmoji: _includeEmoji,
      prettyPrint: _prettyPrint,
    );

    // Create logger
    final logger = Logger(config: config);

    // Add interceptors
    if (_interceptors.isNotEmpty) {
      for (final interceptor in _interceptors) {
        logger.addInterceptor(interceptor);
      }
    }

    // Set global context if provided
    if (_context != null) {
      LogContext.current = _context!;
    }

    return logger;
  }

  /// Build and set as the global logger.
  ///
  /// This is equivalent to:
  /// ```dart
  /// LoggerKit.builder()..build();
  /// LoggerKit.instance;  // Returns the built logger
  /// ```
  Logger buildAndSetGlobal() {
    final logger = build();
    LoggerKit.setInstance(logger);
    return logger;
  }
}
