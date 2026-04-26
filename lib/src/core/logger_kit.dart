import '../models/log_level.dart';
import '../models/log_config.dart';
import '../models/log_context.dart';
import 'logger.dart';
import 'logger_builder.dart';
import 'logger_manager.dart';

/// Global logger manager for LoggerKit.
///
/// [LoggerKit] provides static methods for logging at different levels and managing
/// the global logger instance. It follows the singleton pattern and can be initialized
/// with custom configuration.
///
/// ## Initialization
///
/// Initialize LoggerKit before using it:
///
/// ```dart
/// LoggerKit.init(
///   minLevel: LogLevel.debug,
///   enableConsole: true,
///   enableFile: true,
///   filePath: './logs',
/// );
/// ```
///
/// ## Builder Pattern (Recommended)
///
/// ```dart
/// LoggerKit.builder()
///   ..minLevel(LogLevel.info)
///   ..console()
///   ..file(path: './logs')
///   ..build();
/// ```
///
/// ## Logging Methods
///
/// ```dart
/// LoggerKit.d('Debug message');           // Debug level
/// LoggerKit.i('Info message');            // Info level
/// LoggerKit.w('Warning message');         // Warning level
/// LoggerKit.e('Error message');           // Error level
/// LoggerKit.f('Fatal message');           // Fatal level
/// ```
///
/// ## Advanced Usage
///
/// ```dart
/// // Log with tags
/// LoggerKit.i('User action', tag: 'AUTH');
///
/// // Log with additional data
/// LoggerKit.i('Event', tag: 'ANALYTICS', data: {'key': 'value'});
///
/// // Log errors with stack traces
/// try {
///   // code
/// } catch (e, st) {
///   LoggerKit.e('Error occurred', error: e, stackTrace: st);
/// }
///
/// // Track events
/// LoggerKit.event('user_login', data: {'user_id': '123'});
///
/// // Namespace logging
/// LoggerKit.namespace('network').i('API request sent');
/// LoggerKit.network.i('Cache hit');
/// ```
///
/// ## Cleanup
///
/// Close LoggerKit when done:
///
/// ```dart
/// await LoggerKit.close();
/// ```
class LoggerKit {
  static Logger? _instance;
  static LogConfig? _config;

  // Global context
  static LogContext _globalContext = LogContext();

  /// Initialize LoggerKit with custom configuration.
  ///
  /// This method must be called before using LoggerKit. If not called explicitly,
  /// it will be called automatically with default configuration on first use.
  ///
  /// Parameters:
  /// - [minLevel]: Minimum log level to record (default: [LogLevel.debug])
  /// - [enableConsole]: Enable console output (default: true)
  /// - [enableFile]: Enable file logging (default: false)
  /// - [enableRemote]: Enable remote logging (default: false)
  /// - [filePath]: Path for log files (required if [enableFile] is true)
  /// - [remoteUrl]: URL for remote logging (required if [enableRemote] is true)
  /// - [maxFileSize]: Maximum size of a log file in bytes (default: 10MB)
  /// - [maxFileCount]: Maximum number of log files to keep (default: 5)
  /// - [includeTimestamp]: Include timestamp in logs (default: true)
  /// - [includeTag]: Include tag in logs (default: true)
  /// - [includeEmoji]: Include emoji in logs (default: true)
  /// - [prettyPrint]: Pretty print log output (default: true)
  ///
  /// Example:
  /// ```dart
  /// LoggerKit.init(
  ///   minLevel: LogLevel.info,
  ///   enableConsole: true,
  ///   enableFile: true,
  ///   filePath: './logs',
  ///   maxFileSize: 5 * 1024 * 1024,
  ///   maxFileCount: 10,
  /// );
  /// ```
  static void init({
    LogLevel minLevel = LogLevel.debug,
    bool enableConsole = true,
    bool enableFile = false,
    bool enableRemote = false,
    String? filePath,
    String? remoteUrl,
    int maxFileSize = 10 * 1024 * 1024,
    int maxFileCount = 5,
    bool includeTimestamp = true,
    bool includeTag = true,
    bool includeEmoji = true,
    bool prettyPrint = true,
  }) {
    builder()
      ..minLevel(minLevel)
      ..console(prettyPrint: prettyPrint)
      ..timestamp(includeTimestamp)
      ..tag(includeTag)
      ..emoji(includeEmoji)
      ..noFile()
      ..noRemote()
      ..build();

    // Handle file and remote if enabled
    if (enableFile && filePath != null) {
      builder()
        ..minLevel(minLevel)
        ..console(prettyPrint: prettyPrint)
        ..file(path: filePath, maxSize: maxFileSize, maxCount: maxFileCount)
        ..build();
    }

    if (enableRemote && remoteUrl != null) {
      builder()
        ..minLevel(minLevel)
        ..console(prettyPrint: prettyPrint)
        ..remote(url: remoteUrl)
        ..build();
    }

    // Simple approach: just create with basic settings
    _config = LogConfig(
      minLevel: minLevel,
      enableConsole: enableConsole,
      enableFile: enableFile,
      enableRemote: enableRemote,
      filePath: filePath,
      remoteUrl: remoteUrl,
      maxFileSize: maxFileSize,
      maxFileCount: maxFileCount,
      includeTimestamp: includeTimestamp,
      includeTag: includeTag,
      includeEmoji: includeEmoji,
      prettyPrint: prettyPrint,
    );

    _instance = Logger(config: _config!);
  }

  /// Create a new [LoggerBuilder] for fluent configuration.
  ///
  /// ```dart
  /// LoggerKit.builder()
  ///   ..minLevel(LogLevel.info)
  ///   ..console()
  ///   ..file(path: './logs')
  ///   ..build();
  /// ```
  static LoggerBuilder builder() {
    return LoggerBuilder();
  }

  /// Get the global [Logger] instance.
  ///
  /// If LoggerKit has not been initialized, it will be initialized with default
  /// configuration automatically.
  ///
  /// Returns the singleton [Logger] instance.
  static Logger get instance {
    if (_instance == null) {
      init();
    }
    return _instance!;
  }

  /// Get or create a namespace-scoped logger.
  ///
  /// Namespaces allow you to separate logs from different parts of your application.
  ///
  /// ```dart
  /// final networkLogger = LoggerKit.namespace('network');
  /// networkLogger.i('API request sent');
  /// ```
  static Logger namespace(String name, {LogConfig? config}) {
    return LoggerManager.instance.namespace(name, config: config);
  }

  /// Register a preset namespace configuration.
  ///
  /// ```dart
  /// LoggerKit.registerNamespace('network', config: LogConfig(
  ///   minLevel: LogLevel.warning,
  /// ));
  /// ```
  static void registerNamespace(String name, {LogConfig? config}) {
    LoggerManager.instance.registerNamespace(name, config: config);
  }

  /// Get the current global context.
  ///
  /// ```dart
  /// LoggerKit.context.userId = 'user_123';
  /// ```
  static LogContext get context => _globalContext;

  /// Set the global context.
  ///
  /// ```dart
  /// LoggerKit.setContext(LogContext(
  ///   userId: 'user_123',
  ///   sessionId: 'session_abc',
  /// ));
  /// ```
  static void setContext(LogContext newContext) {
    _globalContext = newContext;
  }

  /// Clear the global context.
  static void clearContext() {
    _globalContext = LogContext();
  }

  // Preset namespace accessors
  static Logger get network => LoggerManager.instance.network;
  static Logger get database => LoggerManager.instance.database;
  static Logger get ui => LoggerManager.instance.ui;
  static Logger get storage => LoggerManager.instance.storage;
  static Logger get auth => LoggerManager.instance.auth;
  static Logger get analytics => LoggerManager.instance.analytics;

  /// Log a debug message.
  static void d(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.d(message, tag: tag, data: data);
  }

  /// Log an info message.
  static void i(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.i(message, tag: tag, data: data);
  }

  /// Log a warning message.
  static void w(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.w(message, tag: tag, data: data);
  }

  /// Log an error message.
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    instance.e(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log a fatal message.
  static void f(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    instance.f(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Log a verbose message (alias for debug).
  static void v(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.v(message, tag: tag, data: data);
  }

  /// Track an event.
  static void event(String name, {Map<String, dynamic>? data}) {
    instance.i(
      'Event: $name',
      tag: 'EVENT',
      data: data,
    );
  }

  /// Close LoggerKit and release resources.
  static Future<void> close() async {
    await _instance?.close();
    await LoggerManager.instance.dispose();
    _instance = null;
    _config = null;
    _globalContext = LogContext();
  }

  // Internal: for LoggerBuilder to set the global instance
  static void setInstance(Logger logger) {
    _instance = logger;
  }
}
