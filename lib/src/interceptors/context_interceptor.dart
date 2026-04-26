import '../models/log_record.dart';
import '../models/log_context.dart';
import 'log_interceptor.dart';

/// Interceptor that injects [LogContext] into log records.
///
/// This interceptor automatically adds context information
/// (userId, sessionId, traceId, deviceId, custom fields)
/// to each log record.
///
/// ## Usage
///
/// ```dart
/// // Set global context first
/// LoggerKit.setContext(LogContext(
///   userId: 'user_123',
///   sessionId: 'session_abc',
/// ));
///
/// // Add context interceptor
/// LoggerKit.builder()
///   ..addInterceptor(ContextInterceptor())
///   ..build();
/// ```
///
/// ## Execution Order
///
/// This interceptor should run early in the chain to ensure
/// context is available for subsequent interceptors.
/// Default order is 0 (first).
class ContextInterceptor implements LogInterceptor {
  /// Create a new [ContextInterceptor].
  ///
  /// Parameters:
  /// - [getContext]: Function to retrieve the current context.
  ///   Defaults to using the global [LogContext.current].
  ContextInterceptor({
    LogContext Function()? getContext,
  }) : _getContext = getContext ?? (() => LogContext.current ?? LogContext());

  final LogContext Function() _getContext;

  @override
  int get order => 0; // Run first

  @override
  LogRecord? intercept(LogRecord record) {
    final context = _getContext();

    if (!context.isNotEmpty) {
      return record; // No context to inject
    }

    // Merge context into record data
    final mergedData = <String, dynamic>{};

    // Add context fields first
    mergedData.addAll(context.toMap());

    // Then add record data (record data takes precedence)
    if (record.data != null) {
      mergedData.addAll(record.data!);
    }

    // Return new record with merged context
    return LogRecord(
      level: record.level,
      message: record.message,
      timestamp: record.timestamp,
      tag: record.tag,
      error: record.error,
      stackTrace: record.stackTrace,
      data: mergedData.isEmpty ? null : mergedData,
    );
  }
}

/// A scoped context interceptor that creates temporary context for a block.
///
/// This is useful for adding context to a specific section of code,
/// such as an HTTP request handler.
///
/// ## Usage
///
/// ```dart
/// final scopedInterceptor = ScopedContextInterceptor();
///
/// // Within a request handler:
/// scopedInterceptor.runWithContext(LogContext(
///   requestId: request.headers['x-request-id'],
/// ), () {
///   LoggerKit.i('Processing request');
///   // All logs within this block will include the requestId
/// });
/// ```
class ScopedContextInterceptor implements LogInterceptor {
  @override
  int get order => 0;

  LogContext? _scopedContext;

  @override
  LogRecord? intercept(LogRecord record) {
    final context = _scopedContext;
    if (context == null || !context.isNotEmpty) {
      return record;
    }

    // Merge scoped context into record
    final mergedData = <String, dynamic>{};
    mergedData.addAll(context.toMap());

    if (record.data != null) {
      mergedData.addAll(record.data!);
    }

    return LogRecord(
      level: record.level,
      message: record.message,
      timestamp: record.timestamp,
      tag: record.tag,
      error: record.error,
      stackTrace: record.stackTrace,
      data: mergedData.isEmpty ? null : mergedData,
    );
  }

  /// Run a callback with scoped context.
  ///
  /// All logs within the callback will include the scoped context.
  T runWithContext<T>(LogContext context, T Function() callback) {
    final previousContext = _scopedContext;
    _scopedContext = context;

    try {
      return callback();
    } finally {
      _scopedContext = previousContext;
    }
  }
}
