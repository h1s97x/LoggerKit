import '../models/log_record.dart';

/// Interface for log interceptors.
///
/// Interceptors allow you to intercept, modify, or enrich log records
/// before they are written. This is useful for:
///
/// - Adding contextual information automatically
/// - Filtering sensitive data
/// - Performance monitoring
/// - Custom routing logic
///
/// ## Usage
///
/// ```dart
/// // Create a custom interceptor
/// class UserContextInterceptor implements LogInterceptor {
///   @override
///   LogRecord intercept(LogRecord record) {
///     record.data ??= {};
///     record.data!['userId'] = getCurrentUserId();
///     return record;
///   }
///
///   @override
///   int get order => 10;
/// }
/// ```
///
/// ## Interceptor Chain
///
/// Interceptors are executed in order of their `order` property.
/// Lower values execute first. Use `order` to control execution sequence.
abstract class LogInterceptor {
  /// Intercept and optionally modify a log record.
  ///
  /// This method is called for each log record before it is written.
  /// You can:
  ///
  /// - Return the record unchanged
  /// - Modify the record and return it
  /// - Return a completely different record
  /// - Return null to discard the record
  ///
  /// Parameters:
  /// - [record]: The log record to intercept
  ///
  /// Returns:
  /// - The (possibly modified) log record
  /// - null to discard the record
  LogRecord? intercept(LogRecord record);

  /// Execution order of this interceptor.
  ///
  /// Interceptors with lower order values execute first.
  /// Default is 0. Use this to control the sequence of interceptors.
  ///
  /// ```dart
  /// // This executes before UserContextInterceptor
  /// class DeviceInterceptor implements LogInterceptor {
  ///   @override
  ///   int get order => 10;  // Lower = earlier
  /// }
  ///
  /// class UserContextInterceptor implements LogInterceptor {
  ///   @override
  ///   int get order => 20;  // Higher = later
  /// }
  /// ```
  int get order => 0;
}

/// A simple interceptor that passes through records unchanged.
///
/// This can be used as a base class for simple interceptors
/// that only need to inspect or log about records.
class PassThroughInterceptor implements LogInterceptor {
  @override
  LogRecord? intercept(LogRecord record) => record;

  @override
  int get order => 0;
}

/// Composite interceptor that chains multiple interceptors.
///
/// This allows you to combine multiple interceptors into one,
/// executing them in sequence.
class CompositeInterceptor implements LogInterceptor {
  /// Create a new [CompositeInterceptor].
  ///
  /// Parameters:
  /// - [interceptors]: List of interceptors to chain
  /// - [stopOnNull]: If true, stops execution when an interceptor returns null
  CompositeInterceptor(
    List<LogInterceptor> interceptors, {
    this.stopOnNull = true,
  }) : _interceptors = List.from(interceptors) {
    // Sort by order
    _interceptors.sort((a, b) => a.order.compareTo(b.order));
  }

  final List<LogInterceptor> _interceptors;

  /// Whether to stop execution when an interceptor returns null.
  final bool stopOnNull;

  @override
  int get order => 0;

  @override
  LogRecord? intercept(LogRecord record) {
    LogRecord? current = record;

    for (final interceptor in _interceptors) {
      if (current == null) break;
      current = interceptor.intercept(current);
    }

    return current;
  }

  /// Add an interceptor to the chain.
  void add(LogInterceptor interceptor) {
    _interceptors.add(interceptor);
    _interceptors.sort((a, b) => a.order.compareTo(b.order));
  }

  /// Remove an interceptor from the chain.
  void remove(LogInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Get the number of interceptors in the chain.
  int get length => _interceptors.length;

  /// Check if the chain is empty.
  bool get isEmpty => _interceptors.isEmpty;

  /// Check if the chain is not empty.
  bool get isNotEmpty => _interceptors.isNotEmpty;
}
