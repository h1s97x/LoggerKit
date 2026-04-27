import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/pretty.dart';
import 'package:logger_kit/models/models.dart';

void main() {
  group('AnsiColor', () {
    test('should have color codes', () {
      expect(AnsiColor.red, isNotEmpty);
      expect(AnsiColor.reset, isNotEmpty);
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

      final result = printer.format(record);

      // Should contain basic info
      expect(result, contains('Test message'));
      expect(result, contains('[INFO]'));
      expect(result, contains('TestTag'));
    });

    test('should handle error with stackTrace', () {
      final printer = DefaultPrettyPrinter();
      final record = LogRecord(
        level: LogLevel.error,
        message: 'Error occurred',
        timestamp: DateTime.now(),
        error: Exception('test error'),
        stackTrace: StackTrace.current,
      );

      final result = printer.format(record);

      expect(result, contains('Error occurred'));
    });
  });
}
