import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('ColoredFormatter', () {
    test('should format log record', () {
      final formatter = ColoredFormatter();
      const config = LogConfig(
        includeTimestamp: true,
        includeTag: true,
        includeEmoji: true,
      );
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
      );

      final formatted = formatter.format(record, config);

      expect(formatted, contains('INFO'));
      expect(formatted, contains('Test message'));
      expect(formatted, contains('TEST'));
      expect(formatted, contains('ℹ️'));
    });

    test('should respect config options', () {
      final formatter = ColoredFormatter();
      const configNoEmoji = LogConfig(
        includeTimestamp: true,
        includeTag: true,
        includeEmoji: false,
      );
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
      );

      final formatted = formatter.format(record, configNoEmoji);

      expect(formatted, isNot(contains('ℹ️')));
    });
  });

  group('SimpleFormatter', () {
    test('should format log record simply', () {
      final formatter = SimpleFormatter();
      const config = LogConfig();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
      );

      final formatted = formatter.format(record, config);

      expect(formatted, contains('INFO'));
      expect(formatted, contains('Test message'));
    });
  });

  group('JsonFormatter', () {
    test('should format log record as JSON', () {
      final formatter = JsonFormatter();
      const config = LogConfig();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
      );

      final formatted = formatter.format(record, config);

      expect(formatted, contains('level'));
      expect(formatted, contains('message'));
      expect(formatted, contains('timestamp'));
      expect(formatted, contains('INFO'));
      expect(formatted, contains('Test message'));
    });
  });
}
