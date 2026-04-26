/// Log context for structured logging.
///
/// [LogContext] provides a standardized way to attach contextual information
/// to log records. This includes user information, session tracking, device
/// identification, and custom fields.
///
/// ## Usage
///
/// ```dart
/// // Set global context
/// LogContext.current = LogContext(
///   userId: 'user_123',
///   sessionId: 'session_abc',
///   traceId: 'trace_xyz',
/// );
///
/// // Add custom fields
/// LogContext.current.set('requestId', 'req_456');
///
/// // Context is automatically included in all logs
/// LoggerKit.i('User action');  // Includes context in log record
/// ```
class LogContext {
  /// Create a new [LogContext].
  LogContext({
    this.userId,
    this.sessionId,
    this.traceId,
    this.deviceId,
    Map<String, dynamic>? custom,
  }) : custom = custom ?? {};

  /// The current global log context.
  ///
  /// Set this to attach context to all subsequent log records.
  static LogContext? current;

  /// User identifier.
  ///
  /// Typically the authenticated user's ID or anonymous identifier.
  String? userId;

  /// Session identifier.
  ///
  /// Used to group logs from the same user session.
  String? sessionId;

  /// Trace identifier.
  ///
  /// Used for distributed tracing across services.
  String? traceId;

  /// Device identifier.
  ///
  /// Unique device or installation identifier.
  String? deviceId;

  /// Custom contextual fields.
  ///
  /// A map of key-value pairs for additional context.
  /// Values should be primitive types (String, num, bool, etc.)
  /// or collections of primitives.
  final Map<String, dynamic> custom;

  /// Set a custom field.
  ///
  /// ```dart
  /// LoggerKit.context.set('requestId', 'req_123');
  /// LoggerKit.context.set('feature', 'dark_mode');
  /// ```
  void set(String key, dynamic value) {
    custom[key] = value;
  }

  /// Get a custom field.
  ///
  /// Returns null if the field doesn't exist.
  dynamic get(String key) {
    return custom[key];
  }

  /// Remove a custom field.
  ///
  /// Returns the removed value, or null if not found.
  dynamic remove(String key) {
    return custom.remove(key);
  }

  /// Check if a custom field exists.
  bool containsKey(String key) {
    return custom.containsKey(key);
  }

  /// Clear all custom fields.
  void clear() {
    custom.clear();
  }

  /// Clear all context including built-in fields.
  void clearAll() {
    userId = null;
    sessionId = null;
    traceId = null;
    deviceId = null;
    custom.clear();
  }

  /// Check if context is empty.
  bool get isEmpty =>
      userId == null &&
      sessionId == null &&
      traceId == null &&
      deviceId == null &&
      custom.isEmpty;

  /// Check if context has any data.
  bool get isNotEmpty => !isEmpty;

  /// Convert context to a Map.
  ///
  /// Useful for serialization and structured logging.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (userId != null) map['userId'] = userId;
    if (sessionId != null) map['sessionId'] = sessionId;
    if (traceId != null) map['traceId'] = traceId;
    if (deviceId != null) map['deviceId'] = deviceId;

    if (custom.isNotEmpty) {
      map['custom'] = Map<String, dynamic>.from(custom);
    }

    return map;
  }

  /// Create a copy of this context with optional overrides.
  LogContext copyWith({
    String? userId,
    String? sessionId,
    String? traceId,
    String? deviceId,
    Map<String, dynamic>? custom,
    bool clearUserId = false,
    bool clearSessionId = false,
    bool clearTraceId = false,
    bool clearDeviceId = false,
  }) {
    return LogContext(
      userId: clearUserId ? null : (userId ?? this.userId),
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
      traceId: clearTraceId ? null : (traceId ?? this.traceId),
      deviceId: clearDeviceId ? null : (deviceId ?? this.deviceId),
      custom: custom ?? Map<String, dynamic>.from(this.custom),
    );
  }

  @override
  String toString() {
    return 'LogContext(${toMap()})';
  }
}
