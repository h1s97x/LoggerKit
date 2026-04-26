import '../models/log_config.dart';
import '../models/log_level.dart';
import 'logger.dart';

/// Manager for namespace-scoped loggers.
///
/// [LoggerManager] provides a way to create and manage multiple logger
/// instances with different configurations for different parts of an application.
///
/// ## Usage
///
/// ```dart
/// // Create namespace loggers
/// final networkLogger = LoggerKit.namespace('network');
/// final dbLogger = LoggerKit.namespace('database');
/// final uiLogger = LoggerKit.namespace('ui');
///
/// // Use them independently
/// networkLogger.i('API request sent');
/// dbLogger.d('Query executed');
/// uiLogger.d('Screen rendered');
/// ```
///
/// ## Preset Namespaces
///
/// You can register preset namespaces for quick access:
///
/// ```dart
/// // Register preset namespace
/// LoggerKit.registerNamespace('network', config: LogConfig(
///   minLevel: LogLevel.warning,  // Only warnings and above
/// ));
///
/// // Access via shortcut
/// LoggerKit.network.i('API request sent');
/// ```
class LoggerManager {
  /// Internal constructor for singleton.
  LoggerManager._();

  /// The singleton instance.
  static final LoggerManager instance = LoggerManager._();

  /// Registered namespaces.
  final Map<String, Logger> _namespaces = {};

  /// Preset namespace configurations.
  final Map<String, LogConfig> _presetConfigs = {};

  /// Get a logger for a namespace.
  ///
  /// If the namespace doesn't exist, it will be created with
  /// the default configuration (or a preset configuration if registered).
  ///
  /// ```dart
  /// final logger = LoggerKit.namespace('network');
  /// logger.i('Network activity');
  /// ```
  Logger namespace(String name, {LogConfig? config}) {
    // Return existing namespace
    if (_namespaces.containsKey(name)) {
      return _namespaces[name]!;
    }

    // Use preset config or create default
    final namespaceConfig = _presetConfigs[name] ?? config ?? LogConfig();

    // Create and store new logger
    final logger = Logger(config: namespaceConfig, namespace: name);
    _namespaces[name] = logger;

    return logger;
  }

  /// Register a preset namespace configuration.
  ///
  /// Preset namespaces are created lazily when first accessed.
  ///
  /// ```dart
  /// LoggerKit.registerNamespace('network', config: LogConfig(
  ///   minLevel: LogLevel.info,
  ///   enableConsole: true,
  /// ));
  /// ```
  void registerNamespace(String name, {LogConfig? config}) {
    _presetConfigs[name] = config ?? LogConfig();
    
    // If namespace already exists, update its config
    if (_namespaces.containsKey(name)) {
      _namespaces[name]!.updateConfig(_presetConfigs[name]!);
    }
  }

  /// Check if a namespace exists.
  bool hasNamespace(String name) {
    return _namespaces.containsKey(name);
  }

  /// Get all registered namespace names.
  List<String> get namespaceNames => _namespaces.keys.toList();

  /// Remove a namespace.
  ///
  /// This closes the logger and removes it from the manager.
  Future<void> removeNamespace(String name) async {
    final logger = _namespaces.remove(name);
    if (logger != null) {
      await logger.close();
    }
  }

  /// Clear all namespaces.
  ///
  /// This closes all loggers and clears the namespace registry.
  Future<void> clearAll() async {
    final closeFutures = _namespaces.values.map((logger) => logger.close());
    await Future.wait(closeFutures);
    _namespaces.clear();
  }

  /// Create a logger with custom configuration that is not namespace-scoped.
  ///
  /// Unlike [namespace], this creates a logger without registering it
  /// in the namespace registry.
  Logger createLogger({LogConfig? config, String? namespace}) {
    return Logger(config: config ?? LogConfig(), namespace: namespace);
  }

  /// Get the global logger instance.
  ///
  /// If no global logger exists, creates one with default configuration.
  Logger get global => LoggerKit.instance;

  /// Dispose of all resources.
  ///
  /// Call this when shutting down the application.
  Future<void> dispose() async {
    await clearAll();
  }
}

/// Extension for accessing preset namespaces via LoggerKit.
///
/// This provides convenient shortcuts for common namespaces.
extension LoggerNamespaceExtension on LoggerManager {
  /// Network namespace for HTTP/API logging.
  Logger get network => namespace('network');

  /// Database namespace for DB query logging.
  Logger get database => namespace('database');

  /// UI namespace for UI/component logging.
  Logger get ui => namespace('ui');

  /// Storage namespace for file/cache operations.
  Logger get storage => namespace('storage');

  /// Auth namespace for authentication logging.
  Logger get auth => namespace('auth');

  /// Analytics namespace for event tracking.
  Logger get analytics => namespace('analytics');
}
