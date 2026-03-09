import 'dart:async';
import '../models/log_record.dart';
import '../models/log_level.dart';
import '../models/log_config.dart';
import '../formatters/log_formatter.dart';
import '../writers/log_writer.dart';
import '../writers/file_writer.dart';
import '../writers/remote_writer.dart';
import '../filters/log_filter.dart';

/// 日志记录器
class Logger {
  Logger({
    required this.config,
    LogFormatter? formatter,
  }) : _formatter = formatter ?? ColoredFormatter() {
    _initWriters();
    _initFilters();
  }

  final LogConfig config;
  final List<LogWriter> _writers = [];
  final List<LogFilter> _filters = [];
  final LogFormatter _formatter;

  void _initWriters() {
    if (config.enableConsole) {
      _writers.add(ConsoleWriter());
    }

    if (config.enableFile && config.filePath != null) {
      _writers.add(FileWriter(config));
    }

    if (config.enableRemote && config.remoteUrl != null) {
      _writers.add(RemoteWriter(config));
    }
  }

  void _initFilters() {
    _filters.add(LevelFilter(config.minLevel));
  }

  /// 记录日志
  Future<void> log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    // 应用过滤器
    if (!_shouldLog(record)) return;

    // 格式化
    final formatted = _formatter.format(record, config);

    // 写入
    await Future.wait(
      _writers.map((writer) => writer.write(record, formatted)),
    );
  }

  bool _shouldLog(LogRecord record) {
    return _filters.every((filter) => filter.shouldLog(record));
  }

  /// Debug日志
  void d(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.debug, message, tag: tag, data: data);
  }

  /// Info日志
  void i(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.info, message, tag: tag, data: data);
  }

  /// Warning日志
  void w(String message, {String? tag, Map<String, dynamic>? data}) {
    log(LogLevel.warning, message, tag: tag, data: data);
  }

  /// Error日志
  void e(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Fatal日志
  void f(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// 添加过滤器
  void addFilter(LogFilter filter) {
    _filters.add(filter);
  }

  /// 移除过滤器
  void removeFilter(LogFilter filter) {
    _filters.remove(filter);
  }

  /// 关闭日志记录器
  Future<void> close() async {
    await Future.wait(_writers.map((writer) => writer.close()));
    _writers.clear();
  }
}
