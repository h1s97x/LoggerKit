import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/pretty.dart';
import 'package:logger_kit/models/models.dart';

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
      final record = LogRecord(
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
      final record = LogRecord(
        level: LogLevel.error,
        message: 'Error occurred',
        timestamp: DateTime.now(),
      );

      final result = printer.format(record, 'Error occurred');

      expect(result, contains('Error occurred'));
      // Should not throw
    });

    test('should respect custom options', () {
      final printer = DefaultPrettyPrinter(
        stackTraceDepth: 2,
        errorMethodCount: 1,
        lineLength: 60,
      );

      expect(printer.stackTraceDepth, equals(2));
      expect(printer.errorMethodCount, equals(1));
      expect(printer.lineLength, equals(60));
    });
  });
}
