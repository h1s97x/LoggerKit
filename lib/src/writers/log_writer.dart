import 'dart:async';
import '../models/log_record.dart';

/// Interface for log writers.
///
/// Implementations of [LogWriter] are responsible for writing formatted log
/// records to their destination (console, file, remote server, etc.).
abstract class LogWriter {
  /// Write a formatted log record.
  ///
  /// Parameters:
  /// - [record]: The [LogRecord] being written
  /// - [formatted]: The formatted log string
  Future<void> write(LogRecord record, String formatted);

  /// Close this writer and release resources.
  Future<void> close();

  /// Flush buffered writes.
  ///
  /// Override this if the writer has internal buffering.
  Future<void> flush() async {
    // Default implementation does nothing.
    // Writers with buffering should override this.
  }
}

/// Console log writer.
///
/// Writes log records to standard output using print().
class ConsoleWriter implements LogWriter {
  @override
  Future<void> write(LogRecord record, String formatted) async {
    // ignore: avoid_print
    print(formatted);
  }

  @override
  Future<void> close() async {
    // 控制台不需要关闭
  }

  @override
  Future<void> flush() async {
    // 控制台不需要刷新
  }
}
