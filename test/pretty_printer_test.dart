import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/pretty.dart';

void main() {
  group('AnsiColor', () {
    test('should wrap text with color codes', () {
      final result = AnsiColor.red.wrap('error');
      expect(result, equals('\x1B[91merror\x1B[0m'));
    });

    test('should reset color correctly', () {
      final result = AnsiColor.reset.wrap('text');
      expect(result, equals('\x1B[0mtext\x1B[0m'));
    });

    test('should format bold text', () {
      final result = AnsiColor.bold.wrap('bold text');
      expect(result, contains('bold text'));
      expect(result, contains(AnsiColor.bold.code));
    });
  });

  group('PrettyPrinter', () {
    test('should be implemented by DefaultPrettyPrinter', () {
      final printer = DefaultPrettyPrinter();
      expect(printer, isA<PrettyPrinter>());
    });
  });

  group('DefaultPrettyPrinter', () {
    test('should format log record', () {
      final printer = DefaultPrettyPrinter();
      final record = SimpleLogRecord(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime(2024, 1, 15, 10, 30, 0),
        tag: 'TestTag',
      );

      final result = printer.format(record, 'Test message');

      // Should contain basic info
      expect(result, contains('Test message'));
      expect(result, contains('[INFO]'));
      expect(result, contains('TestTag'));
    });

    test('should handle null stackTrace', () {
      final printer = DefaultPrettyPrinter();
      final record = SimpleLogRecord(
        level: LogLevel.error,
        message: 'Error occurred',
        timestamp: DateTime.now(),
      );

      final result = printer.format(record, 'Error occurred');

      expect(result, contains('Error occurred'));
      // Should not throw
    });

    test('should wrap stack trace', () {
      final printer = DefaultPrettyPrinter(stackTraceWidth: 40);
      final stackTrace = StackTrace.fromString(
        '#0      main (file:///test.dart:10:5)\n'
        '#1      _runMain (file:///test.dart:20:10)',
      );
      final record = SimpleLogRecord(
        level: LogLevel.error,
        message: 'Error',
        timestamp: DateTime.now(),
        stackTrace: stackTrace,
      );

      final result = printer.format(record, 'Error');

      expect(result, contains('#0'));
      expect(result, contains('main'));
    });

    test('should respect custom options', () {
      final printer = DefaultPrettyPrinter(
        stackTraceLength: 2,
        errorMethodCount: 1,
        stackTraceWidth: 60,
      );

      expect(printer.stackTraceLength, equals(2));
      expect(printer.errorMethodCount, equals(1));
      expect(printer.stackTraceWidth, equals(60));
    });

    test('should handle object data', () {
      final printer = DefaultPrettyPrinter();
      final data = {'key': 'value', 'number': 42};
      final record = SimpleLogRecord(
        level: LogLevel.info,
        message: 'Data',
        timestamp: DateTime.now(),
        data: data,
      );

      final result = printer.format(record, 'Data');

      expect(result, contains('Data'));
    });
  });
}
