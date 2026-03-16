/// A comprehensive logging toolkit for Flutter with console, file, and remote logging support.
///
/// LoggerKit provides a flexible and extensible logging system with the following features:
/// - Multi-level logging (Debug, Info, Warning, Error, Fatal)
/// - Console output with color support
/// - File logging with automatic rotation and cleanup
/// - Remote log upload with batch processing
/// - Customizable formatters, writers, and filters
/// - Event tracking functionality
/// - Asynchronous log writing
///
/// ## Quick Start
///
/// ```dart
/// import 'package:logger_kit/logger_kit.dart';
///
/// void main() {
///   // Initialize LoggerKit with default configuration
///   LoggerKit.init();
///
///   // Log messages at different levels
///   LoggerKit.d('Debug message');
///   LoggerKit.i('Info message');
///   LoggerKit.w('Warning message');
///   LoggerKit.e('Error message', error: Exception('test'));
///   LoggerKit.f('Fatal message');
///
///   // Log with tags
///   LoggerKit.i('User logged in', tag: 'AUTH');
///
///   // Log with additional data
///   LoggerKit.i('User action', tag: 'ANALYTICS', data: {
///     'action': 'button_click',
///     'timestamp': DateTime.now(),
///   });
///
///   // Track events
///   LoggerKit.event('app_started', data: {'version': '1.0.0'});
/// }
/// ```
///
/// ## Configuration
///
/// ```dart
/// LoggerKit.init(
///   minLevel: LogLevel.info,
///   enableConsole: true,
///   enableFile: true,
///   enableRemote: false,
///   filePath: './logs',
///   maxFileSize: 10 * 1024 * 1024, // 10MB
///   maxFileCount: 5,
///   includeTimestamp: true,
///   includeTag: true,
///   includeEmoji: true,
///   prettyPrint: true,
/// );
/// ```
///
/// See also:
/// - [LoggerKit] - Global logger manager
/// - [Logger] - Logger instance
/// - [LogLevel] - Log level enumeration
/// - [LogRecord] - Log record model
/// - [LogConfig] - Log configuration
/// - [LogFormatter] - Log formatter interface
/// - [LogWriter] - Log writer interface
/// - [LogFilter] - Log filter interface
// ignore: unnecessary_library_name
library logger_kit;

export 'src/core/logger_kit.dart';
export 'src/core/logger.dart';
export 'src/models/models.dart';
export 'src/formatters/log_formatter.dart';
export 'src/writers/log_writer.dart';
export 'src/filters/log_filter.dart';
