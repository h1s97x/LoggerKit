import 'dart:io';

import '../models/log_record.dart';
import '../pretty/pretty_printer.dart';
import '../pretty/default_pretty_printer.dart';
import '../pretty/simple_pretty_printer.dart';
import '../strategy/error_strategy.dart';
import 'log_writer.dart';

/// A log writer that outputs logs to the console
///
/// Supports optional pretty printing with ANSI colors and stack trace formatting
class ConsoleWriter implements LogWriter {
  final PrettyPrinter? prettyPrinter;
  final ErrorStrategy errorStrategy;
  final String _output;
  final bool _useColor;

  /// Create a new ConsoleWriter
  ///
  /// [prettyPrinter] - Optional pretty printer for formatted output.
  ///                   If not provided, uses [DefaultPrettyPrinter] with default settings.
  ///                   Pass [SimplePrettyPrinter] for plain output.
  /// [errorStrategy] - Strategy for handling write errors. Defaults to [ErrorStrategy.ignore].
  /// [output] - Output stream: 'stdout' (default) or 'stderr'.
  /// [useColor] - Whether to use ANSI colors. Auto-detected if not provided.
  ConsoleWriter({
    PrettyPrinter? prettyPrinter,
    this.errorStrategy = ErrorStrategy.ignore,
    String output = 'stdout',
    bool? useColor,
  })  : prettyPrinter = prettyPrinter ?? DefaultPrettyPrinter(),
        _output = output,
        _useColor = useColor ?? _detectColorSupport();

  static bool _detectColorSupport() {
    // Check if terminal supports colors
    final envVars = Platform.environment;
    if (envVars['TERM'] == 'dumb') return false;
    if (envVars.containsKey('NO_COLOR')) return false;
    if (Platform.isWindows) {
      // Windows Console API detection
      return Platform.environment['WT_SESSION'] != null ||
          Platform.environment['TERMINAL_SERIES'] != null;
    }
    return stdout.hasTerminal;
  }

  @override
  Future<void> write(LogRecord record, String formatted) async {
    try {
      final output =
          prettyPrinter != null ? prettyPrinter!.format(record) : formatted;

      if (_output == 'stderr' || record.level.value >= 3) {
        stderr.writeln(output);
      } else {
        stdout.writeln(output);
      }
    } catch (e) {
      _handleError(e, record);
    }
  }

  @override
  Future<void> flush() async {
    // Console output is synchronous, no flush needed
  }

  void _handleError(dynamic error, LogRecord record) {
    switch (errorStrategy) {
      case ErrorStrategy.ignore:
        // Do nothing
        break;
      case ErrorStrategy.logToFallback:
        // Fallback to simple print without colors
        stderr.writeln('[${record.level.name}] ${record.message}');
        break;
      case ErrorStrategy.throwException:
        throw Exception('Failed to write log: $error');
    }
  }

  @override
  Future<void> close() async {
    // Console writer doesn't need cleanup
  }
}
