/// Exception thrown when all log writers fail.
///
/// This exception is thrown when using [ErrorStrategy.throwException]
/// or when all writers fail with a non-throwing strategy.
class LoggerException implements Exception {
  /// The error message.
  final String message;

  /// List of errors from failed writers.
  final List<Object> errors;

  /// Creates a new [LoggerException].
  const LoggerException(this.message, {this.errors = const []});

  @override
  String toString() {
    if (errors.isEmpty) {
      return 'LoggerException: $message';
    }
    return 'LoggerException: $message\nErrors: ${errors.join('\n')}';
  }
}
