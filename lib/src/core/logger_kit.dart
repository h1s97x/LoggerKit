import '../models/log_level.dart';
import '../models/log_config.dart';
import 'logger.dart';

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

  /// Get the global [Logger] instance.
  ///
  /// If LoggerKit has not been initialized, it will be initialized with default
  /// configuration automatically.
  ///
  /// Returns the singleton [Logger] instance.
  static Logger get instance {
    if (_instance == null) {
      init(); // 使用默认配置初始化
    }
    return _instance!;
  }

  /// Log a debug message.
  ///
  /// Debug messages are typically used for detailed diagnostic information.
  ///
  /// Parameters:
  /// - [message]: The log message
  /// - [tag]: Optional tag to categorize the log
  /// - [data]: Optional additional data to include in the log
  ///
  /// Example:
  /// ```dart
  /// LoggerKit.d('Variable value: $value');
  /// LoggerKit.d('State changed', tag: 'STATE', data: {'old': 1, 'new': 2});
  /// ```
  static void d(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.d(message, tag: tag, data: data);
  }

  /// Log an info message.
  ///
  /// Info messages are used for general informational messages about application flow.
  ///
  /// Parameters:
  /// - [message]: The log message
  /// - [tag]: Optional tag to categorize the log
  /// - [data]: Optional additional data to include in the log
  ///
  /// Example:
  /// ```dart
  /// LoggerKit.i('Application started');
  /// LoggerKit.i('User action', tag: 'ANALYTICS', data: {'action': 'login'});
  /// ```
  static void i(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.i(message, tag: tag, data: data);
  }

  /// Log a warning message.
  ///
  /// Warning messages indicate potentially problematic situations that should be investigated.
  ///
  /// Parameters:
  /// - [message]: The log message
  /// - [tag]: Optional tag to categorize the log
  /// - [data]: Optional additional data to include in the log
  ///
  /// Example:
  /// ```dart
  /// LoggerKit.w('Deprecated API usage');
  /// LoggerKit.w('High memory usage', tag: 'PERFORMANCE', data: {'memory': '500MB'});
  /// ```
  static void w(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.w(message, tag: tag, data: data);
  }

  /// Log an error message.
  ///
  /// Error messages indicate error conditions that need attention.
  ///
  /// Parameters:
  /// - [message]: The log message
  /// - [tag]: Optional tag to categorize the log
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace
  /// - [data]: Optional additional data to include in the log
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   // code
  /// } catch (e, st) {
  ///   LoggerKit.e('Operation failed', error: e, stackTrace: st, tag: 'ERROR');
  /// }
  /// ```
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
  ///
  /// Fatal messages indicate severe errors that may cause application termination.
  ///
  /// Parameters:
  /// - [message]: The log message
  /// - [tag]: Optional tag to categorize the log
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace
  /// - [data]: Optional additional data to include in the log
  ///
  /// Example:
  /// ```dart
  /// LoggerKit.f('Critical system failure', error: e, stackTrace: st);
  /// ```
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

  /// Track an event.
  ///
  /// Events are logged as info-level messages with the 'EVENT' tag.
  ///
  /// Parameters:
  /// - [name]: The event name
  /// - [data]: Optional event data
  ///
  /// Example:
  /// ```dart
  /// LoggerKit.event('user_login', data: {'user_id': '123', 'timestamp': DateTime.now()});
  /// LoggerKit.event('app_started');
  /// ```
  static void event(String name, {Map<String, dynamic>? data}) {
    instance.i(
      'Event: $name',
      tag: 'EVENT',
      data: data,
    );
  }

  /// Close LoggerKit and release resources.
  ///
  /// This method should be called when the application is shutting down to ensure
  /// all log writers are properly closed and resources are released.
  ///
  /// Example:
  /// ```dart
  /// await LoggerKit.close();
  /// ```
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
    _config = null;
  }
}
