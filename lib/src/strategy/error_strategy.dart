/// Error handling strategies for LoggerKit.
///
/// This module provides strategies for handling errors during log writing,
/// helping to prevent cascading failures and ensure logging reliability.
///
/// ## Strategies
///
/// - [ErrorStrategy.ignore] - Silently ignore errors (default)
/// - [ErrorStrategy.logToFallback] - Log errors to fallback writer
/// - [ErrorStrategy.throwException] - Throw exceptions to caller
///
/// ## Usage
///
/// ```dart
/// LoggerKit.builder()
///   ..errorStrategy(ErrorStrategy.logToFallback)
///   ..build();
/// ```
///
/// ## Best Practices
///
/// - Use `ignore` in production for reliability
/// - Use `throwException` during development for debugging
/// - Use `logToFallback` when you have multiple writers configured
enum ErrorStrategy {
  /// Ignore errors silently.
  ///
  /// This is the default strategy for maximum logging reliability.
  /// Errors are logged to console but do not interrupt the application.
  ///
  /// **Use case**: Production environments where logging should never
  /// interrupt the main application flow.
  ignore,

  /// Log errors to a fallback writer.
  ///
  /// When the primary writer fails, errors are logged to the fallback
  /// writer (usually console). This ensures error visibility while
  /// maintaining graceful degradation.
  ///
  /// **Use case**: When you have multiple writers and want to ensure
  /// error visibility without failing the primary operation.
  logToFallback,

  /// Throw exceptions to the caller.
  ///
  /// Errors propagate up the call stack. This should be used when
  /// logging failures should be treated as critical issues.
  ///
  /// **Use case**: Development/debugging, or when logging is part of
  /// a critical business operation that must succeed.
  throwException;

  /// Returns the name of the strategy for display purposes.
  String get displayName {
    switch (this) {
      case ErrorStrategy.ignore:
        return 'Ignore';
      case ErrorStrategy.logToFallback:
        return 'Log to Fallback';
      case ErrorStrategy.throwException:
        return 'Throw Exception';
    }
  }

  /// Returns a description of the strategy.
  String get description {
    switch (this) {
      case ErrorStrategy.ignore:
        return 'Silently ignore errors and continue';
      case ErrorStrategy.logToFallback:
        return 'Log errors to fallback writer';
      case ErrorStrategy.throwException:
        return 'Throw exceptions to caller';
    }
  }
}
