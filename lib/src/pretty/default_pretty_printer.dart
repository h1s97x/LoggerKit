import 'dart:convert';

import '../models/log_level.dart';
import '../models/log_record.dart';
import 'ansi_color.dart';
import 'pretty_printer.dart';

/// Default implementation of [PrettyPrinter] that provides:
/// - ANSI colored output
/// - Stack trace formatting
/// - Multi-line message collapsing
/// - Configurable formatting options
class DefaultPrettyPrinter implements PrettyPrinter {
  /// Create a new DefaultPrettyPrinter with optional configuration.
  DefaultPrettyPrinter([PrettyPrinterConfig? config])
      : _config = config ?? const PrettyPrinterConfig();

  PrettyPrinterConfig _config;

  @override
  PrettyPrinterConfig get config => _config;

  @override
  bool get useColors => _config.useColors;

  @override
  set useColors(bool value) {
    _config = _config.copyWith(useColors: value);
  }

  @override
  int get maxLineWidth => _config.maxLineWidth;

  @override
  set maxLineWidth(int value) {
    _config = _config.copyWith(maxLineWidth: value);
  }

  @override
  String format(LogRecord record) {
    return _formatInternal(record, useColors: false);
  }

  @override
  String formatColored(LogRecord record) {
    return _formatInternal(record, useColors: useColors);
  }

  String _formatInternal(LogRecord record, {required bool useColors}) {
    final buffer = StringBuffer();

    // Level indicator with color
    final levelStr = record.level.name.toUpperCase().padRight(5);
    if (useColors) {
      final levelColor = AnsiColor.forLevel(record.level.value);
      buffer.write(AnsiColor.wrap(levelStr, levelColor));
    } else {
      buffer.write(levelStr);
    }

    // Tag
    if (record.tag != null && record.tag!.isNotEmpty) {
      if (useColors) {
        buffer.write('[${AnsiColor.wrap(record.tag!, AnsiColor.cyan)}] ');
      } else {
        buffer.write('[${record.tag}] ');
      }
    }

    // Timestamp
    final timestamp = _formatTimestamp(record.timestamp);
    buffer.write('$timestamp ');

    // Message
    var message = record.message.toString();
    buffer.writeln(message);

    // Data (if present)
    if (record.data != null && record.data!.isNotEmpty) {
      final dataStr = _formatData(record.data!);
      for (final line in dataStr.split('\n')) {
        buffer.writeln(' ' * _config.messageIndent + line);
      }
    }

    // Error (if present)
    if (record.error != null) {
      final errorStr = record.error.toString();
      if (useColors) {
        buffer.writeln(AnsiColor.wrap(
          ' ' * _config.messageIndent + errorStr,
          AnsiColor.red,
        ));
      } else {
        buffer.writeln(' ' * _config.messageIndent + errorStr);
      }
    }

    // Stack trace (if present)
    if (record.stackTrace != null) {
      final stackStr = formatStackTrace(record.stackTrace!);
      buffer.write(stackStr);
    }

    return buffer.toString();
  }

  @override
  String formatStackTrace(StackTrace stackTrace) {
    final buffer = StringBuffer();
    final lines = stackTrace.toString().split('\n');

    final prefix = useColors
        ? AnsiColor.wrap(_config.stackTracePrefix, AnsiColor.red)
        : _config.stackTracePrefix;

    buffer.writeln(prefix);

    final indent = ' ' * _config.stackTraceIndent;
    final maxLines = lines.length > _config.maxStackTraceLines
        ? _config.maxStackTraceLines
        : lines.length;

    for (var i = 0; i < maxLines; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Format: #X <file>:<line> in <function>
      if (useColors) {
        buffer.writeln(
          AnsiColor.wrap('$indent$line', AnsiColor.dim),
        );
      } else {
        buffer.writeln('$indent$line');
      }
    }

    if (lines.length > _config.maxStackTraceLines) {
      final more = lines.length - _config.maxStackTraceLines;
      final moreStr = useColors
          ? AnsiColor.wrap(
              '$indent... and $more more lines',
              AnsiColor.dim,
            )
          : '$indent... and $more more lines';
      buffer.writeln(moreStr);
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    final pad = (int n) => n.toString().padLeft(2, '0');
    final year = timestamp.year;
    final month = pad(timestamp.month);
    final day = pad(timestamp.day);
    final hour = pad(timestamp.hour);
    final minute = pad(timestamp.minute);
    final second = pad(timestamp.second);
    final millis = timestamp.millisecond.toString().padLeft(3, '0');
    return '$year-$month-$day $hour:$minute:$second.$millis';
  }

  String _formatData(dynamic data) {
    if (data is Map) {
      return _formatMap(data);
    }
    return data.toString();
  }

  String _formatMap(Map map, [int depth = 0]) {
    if (map.isEmpty) return '{}';

    final buffer = StringBuffer();
    final indent = ' ' * (depth * 2 + _config.messageIndent);
    final innerIndent = ' ' * (depth * 2 + _config.messageIndent + 2);

    buffer.writeln('{');

    var first = true;
    for (final entry in map.entries) {
      if (!first) {
        buffer.writeln(',');
      }
      first = false;

      final key = entry.key;
      final value = entry.value;

      buffer.write('$innerIndent$key: ');

      if (value is Map) {
        buffer.write(_formatMap(value, depth + 1));
      } else if (value is List) {
        buffer.write(_formatList(value, depth + 1));
      } else if (value is String) {
        // Quote strings
        buffer.write('"${_escapeString(value)}"');
      } else if (value == null) {
        buffer.write('null');
      } else {
        buffer.write(value.toString());
      }
    }

    buffer.writeln();
    buffer.write('$indent}');

    return buffer.toString();
  }

  String _formatList(List list, [int depth = 0]) {
    if (list.isEmpty) return '[]';

    final buffer = StringBuffer();
    final indent = ' ' * (depth * 2 + _config.messageIndent);
    final innerIndent = ' ' * (depth * 2 + _config.messageIndent + 2);

    buffer.writeln('[');

    for (var i = 0; i < list.length; i++) {
      if (i > 0) {
        buffer.writeln(',');
      }

      final value = list[i];

      buffer.write(innerIndent);

      if (value is Map) {
        buffer.write(_formatMap(value, depth + 1));
      } else if (value is List) {
        buffer.write(_formatList(value, depth + 1));
      } else if (value is String) {
        buffer.write('"${_escapeString(value)}"');
      } else if (value == null) {
        buffer.write('null');
      } else {
        buffer.write(value.toString());
      }
    }

    buffer.writeln();
    buffer.write('$indent]');

    return buffer.toString();
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}

/// A simple pretty printer that outputs basic formatted logs without colors.
/// Use this for non-terminal output (e.g., files, network).
class SimplePrettyPrinter implements PrettyPrinter {
  const SimplePrettyPrinter();

  @override
  bool get useColors => false;

  @override
  set useColors(bool value) {
    // No-op for SimplePrettyPrinter
  }

  @override
  int get maxLineWidth => 80;

  @override
  set maxLineWidth(int value) {
    // No-op for SimplePrettyPrinter
  }

  @override
  String format(LogRecord record) {
    return formatColored(record);
  }

  @override
  String formatColored(LogRecord record) {
    final buffer = StringBuffer();

    // Level and timestamp
    final level = record.level.name.toUpperCase().padRight(5);
    final timestamp = _formatTimestamp(record.timestamp);
    buffer.write('[$level $timestamp] ');

    // Tag
    if (record.tag != null && record.tag!.isNotEmpty) {
      buffer.write('[${record.tag}] ');
    }

    // Message
    buffer.writeln(record.message);

    // Context
    if (record.context != null && record.context!.isNotEmpty) {
      buffer.writeln('  Context: ${record.context}');
    }

    // Data
    if (record.data != null && record.data!.isNotEmpty) {
      buffer.writeln('  Data: ${json.encode(record.data)}');
    }

    // Error
    if (record.error != null) {
      buffer.writeln('  Error: ${record.error}');
    }

    // Stack trace
    if (record.stackTrace != null) {
      buffer.writeln('  StackTrace: ${record.stackTrace}');
    }

    return buffer.toString();
  }

  @override
  String formatStackTrace(StackTrace stackTrace) {
    return '  StackTrace:\n${stackTrace.toString().split('\n').map((l) => '    $l').join('\n')}\n';
  }

  String _formatTimestamp(DateTime timestamp) {
    final pad = (int n) => n.toString().padLeft(2, '0');
    return '${timestamp.year}-${pad(timestamp.month)}-${pad(timestamp.day)} '
        '${pad(timestamp.hour)}:${pad(timestamp.minute)}:${pad(timestamp.second)}.${timestamp.millisecond}';
  }
}
