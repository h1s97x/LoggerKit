import '../models/log_record.dart';
import '../models/log_config.dart';
import '../models/log_level.dart';

/// 日志格式化器接口
abstract class LogFormatter {
  String format(LogRecord record, LogConfig config);
}

/// 简单格式化器
class SimpleFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    final buffer = StringBuffer();

    // 时间戳
    if (config.includeTimestamp) {
      buffer.write('[${_formatTimestamp(record.timestamp)}] ');
    }

    // Emoji
    if (config.includeEmoji) {
      buffer.write('${record.level.emoji} ');
    }

    // 级别
    buffer.write('[${record.level.name}] ');

    // 标签
    if (config.includeTag && record.tag != null) {
      buffer.write('[${record.tag}] ');
    }

    // 消息
    buffer.write(record.message);

    // 错误
    if (record.error != null) {
      buffer.write('\n  Error: ${record.error}');
    }

    // 堆栈跟踪
    if (record.stackTrace != null) {
      buffer.write('\n  StackTrace:\n${_formatStackTrace(record.stackTrace!)}');
    }

    // 额外数据
    if (record.data != null && record.data!.isNotEmpty) {
      buffer.write('\n  Data: ${record.data}');
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.year}-${_pad(timestamp.month)}-${_pad(timestamp.day)} '
        '${_pad(timestamp.hour)}:${_pad(timestamp.minute)}:${_pad(timestamp.second)}';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  String _formatStackTrace(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');
    return lines.take(5).map((line) => '    $line').join('\n');
  }
}

/// JSON格式化器
class JsonFormatter implements LogFormatter {
  @override
  String format(LogRecord record, LogConfig config) {
    return record.toJson().toString();
  }
}

/// 彩色格式化器（用于控制台）
class ColoredFormatter implements LogFormatter {
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _gray = '\x1B[90m';

  @override
  String format(LogRecord record, LogConfig config) {
    final color = _getColor(record.level);
    final formatted = SimpleFormatter().format(record, config);
    return '$color$formatted$_reset';
  }

  String _getColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return _gray;
      case LogLevel.info:
        return _blue;
      case LogLevel.warning:
        return _yellow;
      case LogLevel.error:
      case LogLevel.fatal:
        return _red;
    }
  }
}
