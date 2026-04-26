/// Overflow handling strategies for LoggerKit's async queue.
///
/// This module provides strategies for handling queue overflow when
/// the async write queue exceeds its capacity, helping to prevent
/// memory issues and maintain logging performance.
///
/// ## Strategies
///
/// - [OverflowStrategy.dropOldest] - Drop the oldest log entry
/// - [OverflowStrategy.dropNewest] - Drop the newest log entry
/// - [OverflowStrategy.block] - Block until space is available
///
/// ## Background
///
/// LoggerKit uses an async queue for non-blocking log writes. When
/// the queue is full (e.g., during high-throughput logging), the
/// overflow strategy determines what happens.
///
/// ## Usage
///
/// ```dart
/// LoggerKit.builder()
///   ..overflowStrategy(OverflowStrategy.dropOldest)
///   ..build();
/// ```
///
/// ## Performance Considerations
///
/// | Strategy | Latency | Memory | Reliability |
/// |----------|---------|--------|-------------|
/// | dropOldest | Low | Bounded | May lose logs |
/// | dropNewest | Low | Bounded | Keeps recent logs |
/// | block | High | Unbounded | No log loss |
///
/// ## Best Practices
///
/// - Use `dropOldest` for high-throughput scenarios
/// - Use `dropNewest` when recent logs are more important
/// - Use `block` only when log completeness is critical
enum OverflowStrategy {
  /// Drop the oldest log entry to make room for new ones.
  ///
  /// This strategy ensures the queue size never exceeds the limit,
  /// providing predictable memory usage. Older logs may be lost,
  /// but the queue always accepts new logs.
  ///
  /// **Use case**: High-throughput scenarios where memory is constrained
  /// and occasional log loss is acceptable.
  ///
  /// **Pros**:
  /// - Predictable memory usage
  /// - Never blocks the main thread
  /// - Handles burst traffic gracefully
  ///
  /// **Cons**:
  /// - May lose important older logs during peak load
  dropOldest,

  /// Drop the newest log entry when queue is full.
  ///
  /// This strategy keeps older logs and drops newer ones. This is
  /// useful when historical logs are more important than the most
  /// recent ones.
  ///
  /// **Use case**: When historical data completeness matters more
  /// than capturing the latest events.
  ///
  /// **Pros**:
  /// - Keeps historical data intact
  /// - Never blocks the main thread
  ///
  /// **Cons**:
  /// - May miss important recent events during peak load
  dropNewest,

  /// Block the caller until space is available.
  ///
  /// This strategy ensures no logs are lost but may introduce
  /// latency. The caller blocks until the queue has space.
  ///
  /// **Use case**: When log completeness is critical and some
  /// latency is acceptable.
  ///
  /// **Pros**:
  /// - No log loss
  /// - Simple to reason about
  ///
  /// **Cons**:
  /// - May block the main thread during peak load
  /// - May cause latency spikes
  block;

  /// Returns the name of the strategy for display purposes.
  String get displayName {
    switch (this) {
      case OverflowStrategy.dropOldest:
        return 'Drop Oldest';
      case OverflowStrategy.dropNewest:
        return 'Drop Newest';
      case OverflowStrategy.block:
        return 'Block';
    }
  }

  /// Returns a description of the strategy.
  String get description {
    switch (this) {
      case OverflowStrategy.dropOldest:
        return 'Drop oldest log to make room for new ones';
      case OverflowStrategy.dropNewest:
        return 'Drop newest log to keep historical data';
      case OverflowStrategy.block:
        return 'Block until space is available';
    }
  }
}
