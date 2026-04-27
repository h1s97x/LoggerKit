import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/pretty.dart';
import 'package:logger_kit/logger_kit.dart' show ConsoleWriter;
import 'package:logger_kit/models/models.dart';

final _testRecord = LogRecord(
  level: LogLevel.info,
  message: 'Test',
  timestamp: DateTime.now(),
);

void main() {
  group('ConsoleWriter', () {
    test('should create with default values', () {
      final writer = ConsoleWriter();
      expect(writer, isNotNull);
    });

    test('should create with prettyPrinter', () {
      final printer = DefaultPrettyPrinter();
      final writer = ConsoleWriter(prettyPrinter: printer);
      expect(writer, isNotNull);
    });

    test('should create with useColor', () {
      final writer = ConsoleWriter(useColor: false);
      expect(writer, isNotNull);
    });

    test('should handle multiple writers configuration', () async {
      final writer = ConsoleWriter(
        prettyPrinter: DefaultPrettyPrinter(),
        useColor: false,
      );

      // Should not throw
      await writer.write(_testRecord, 'Test message');
    });

    test('should write with pretty print', () async {
      final writer = ConsoleWriter(prettyPrinter: DefaultPrettyPrinter());
      final logRecord = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime.now(),
      );

      // Should not throw
      await writer.write(logRecord, 'Test message');
    });

    test('should flush without error', () async {
      final writer = ConsoleWriter();
      await writer.flush();
    });
  });
}
