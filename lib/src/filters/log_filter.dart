import '../models/log_record.dart';
import '../models/log_level.dart';

/// Interface for log filters.
///
/// Implementations of [LogFilter] determine whether a log record should be
/// recorded or filtered out.
abstract class LogFilter {
  /// Determine if a log record should be logged.
  ///
  /// Returns true if the record should be logged, false otherwise.
  bool shouldLog(LogRecord record);
}

/// Log level filter.
///
/// Filters logs based on their level. Only logs at or above the minimum level
/// are allowed through.
class LevelFilter implements LogFilter {
  /// Create a new [LevelFilter].
  ///
  /// Parameters:
  /// - [minLevel]: The minimum [LogLevel] to allow
  LevelFilter(this.minLevel);

  /// The minimum log level to allow
  final LogLevel minLevel;

  @override
  bool shouldLog(LogRecord record) {
    return record.level.shouldLog(minLevel);
  }
}

/// Tag-based log filter.
///
/// Filters logs based on their tag. Only logs with tags in the allowed list
/// are allowed through.
class TagFilter implements LogFilter {
  /// Create a new [TagFilter].
  ///
  /// Parameters:
  /// - [allowedTags]: List of tags to allow
  TagFilter(this.allowedTags);

  /// List of allowed tags
  final List<String> allowedTags;

  @override
  bool shouldLog(LogRecord record) {
    if (record.tag == null) return false;
    return allowedTags.contains(record.tag);
  }
}

/// Composite log filter.
///
/// Combines multiple filters using AND or OR logic.
class CompositeFilter implements LogFilter {
  /// Create a new [CompositeFilter].
  ///
  /// Parameters:
  /// - [filters]: List of filters to combine
  /// - [requireAll]: If true, all filters must pass (AND logic). If false, any filter can pass (OR logic).
  CompositeFilter(this.filters, {this.requireAll = true});

  /// List of filters to combine
  final List<LogFilter> filters;

  /// If true, all filters must pass (AND logic). If false, any filter can pass (OR logic).
  final bool requireAll;

  @override
  bool shouldLog(LogRecord record) {
    if (requireAll) {
      return filters.every((filter) => filter.shouldLog(record));
    } else {
      return filters.any((filter) => filter.shouldLog(record));
    }
  }
}
