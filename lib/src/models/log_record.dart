import 'log_level.dart';

/// A single log record.
///
/// [LogRecord] contains all information about a single log entry including
/// the message, level, timestamp, and optional error/stack trace information.
class LogRecord {
  /// Create a new [LogRecord].
  ///
  /// Parameters:
  /// - [level]: The [LogLevel] of this record
  /// - [message]: The log message
  /// - [timestamp]: The timestamp (defaults to current time)
  /// - [tag]: Optional tag to categorize the log
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace
  /// - [data]: Optional additional data
  LogRecord({
    required this.level,
    required this.message,
    DateTime? timestamp,
    this.tag,
    this.error,
    this.stackTrace,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a [LogRecord] from JSON.
  ///
  /// Useful for deserializing log records from remote sources or storage.
  factory LogRecord.fromJson(Map<String, dynamic> json) {
    return LogRecord(
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      tag: json['tag'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// The log level
  final LogLevel level;

  /// The log message
  final String message;

  /// The timestamp when this record was created
  final DateTime timestamp;

  /// Optional tag to categorize the log
  final String? tag;

  /// Optional error object
  final Object? error;

  /// Optional stack trace
  final StackTrace? stackTrace;

  /// Optional additional data
  final Map<String, dynamic>? data;

  /// Convert this [LogRecord] to JSON.
  ///
  /// Useful for serializing log records for remote storage or transmission.
  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      if (tag != null) 'tag': tag,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (data != null) 'data': data,
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${level.name}]');
    if (tag != null) buffer.write(' [$tag]');
    buffer.write(' $message');
    if (error != null) buffer.write('\nError: $error');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    return buffer.toString();
  }
}
