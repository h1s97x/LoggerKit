// ignore_for_file: unnecessary_library_name, dangling_library_doc_comments
library logger_kit;

/// A comprehensive logging toolkit
///
/// LoggerKit provides a flexible and extensible logging system with the following features:
/// - Multi-level logging (Debug, Info, Warning, Error, Fatal)
/// - Console output with color support
/// - File logging with automatic rotation and cleanup
/// - Remote log upload with batch processing
/// - Customizable formatters, writers, and filters
/// - Log interceptors for modification and enrichment
/// - Namespace-scoped logging
/// - Structured logging with context
/// - Privacy filtering
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
/// ## Builder Pattern (Recommended)
///
/// ```dart
/// LoggerKit.builder()
///   ..minLevel(LogLevel.info)
///   ..console()
///   ..file(path: './logs')
///   ..addInterceptor(PrivacyInterceptor())
///   ..build();
/// ```
///
/// ## Namespace Logging
///
/// ```dart
/// // Create namespace loggers
/// LoggerKit.namespace('network').i('API request sent');
/// LoggerKit.namespace('database').d('Query executed');
///
/// // Or use preset shortcuts
/// LoggerKit.network.i('Network activity');
/// LoggerKit.database.d('Database query');
/// ```
// Core exports
export 'src/core/logger_kit.dart';
export 'src/core/logger.dart';
export 'src/core/logger_builder.dart';
export 'src/core/logger_manager.dart';

// Model exports
export 'src/models/models.dart';

// Interceptor exports
export 'src/interceptors/interceptors.dart';

// Formatter, Writer, Filter exports
export 'src/formatters/log_formatter.dart';
export 'src/writers/writers.dart';
export 'src/filters/log_filter.dart';

// Pretty print exports
export 'src/pretty/pretty.dart';

// Strategy exports
export 'src/strategy/strategy.dart';
