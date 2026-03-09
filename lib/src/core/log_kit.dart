import '../models/log_level.dart';
import '../models/log_config.dart';
import 'logger.dart';

/// LogKit - 全局日志管理器
class LogKit {
  static Logger? _instance;
  static LogConfig? _config;

  /// 初始化LogKit
  static void init({
    LogLevel minLevel = LogLevel.debug,
    bool enableConsole = true,
    bool enableFile = false,
    bool enableRemote = false,
    String? filePath,
    String? remoteUrl,
    int maxFileSize = 10 * 1024 * 1024,
    int maxFileCount = 5,
    bool includeTimestamp = true,
    bool includeTag = true,
    bool includeEmoji = true,
    bool prettyPrint = true,
  }) {
    _config = LogConfig(
      minLevel: minLevel,
      enableConsole: enableConsole,
      enableFile: enableFile,
      enableRemote: enableRemote,
      filePath: filePath,
      remoteUrl: remoteUrl,
      maxFileSize: maxFileSize,
      maxFileCount: maxFileCount,
      includeTimestamp: includeTimestamp,
      includeTag: includeTag,
      includeEmoji: includeEmoji,
      prettyPrint: prettyPrint,
    );

    _instance = Logger(config: _config!);
  }

  /// 获取Logger实例
  static Logger get instance {
    if (_instance == null) {
      init(); // 使用默认配置初始化
    }
    return _instance!;
  }

  /// Debug日志
  static void d(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.d(message, tag: tag, data: data);
  }

  /// Info日志
  static void i(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.i(message, tag: tag, data: data);
  }

  /// Warning日志
  static void w(String message, {String? tag, Map<String, dynamic>? data}) {
    instance.w(message, tag: tag, data: data);
  }

  /// Error日志
  static void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    instance.e(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Fatal日志
  static void f(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    instance.f(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// 记录事件
  static void event(String name, {Map<String, dynamic>? data}) {
    instance.i(
      'Event: $name',
      tag: 'EVENT',
      data: data,
    );
  }

  /// 关闭LogKit
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
    _config = null;
  }
}
