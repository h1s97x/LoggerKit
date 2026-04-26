import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('ConsoleWriter', () {
    test('should create with default settings', () {
      final writer = ConsoleWriter();
      expect(writer, isNotNull);
      expect(writer.useColor, isFalse);
      expect(writer.prettyPrint, isFalse);
    });

    test('should create with prettyPrint enabled', () {
      final writer = ConsoleWriter(prettyPrint: true);
      expect(writer.prettyPrint, isTrue);
    });

    test('should create with color enabled', () {
      final writer = ConsoleWriter(useColor: true);
      expect(writer.useColor, isTrue);
    });

    test('should write without error', () async {
      final writer = ConsoleWriter();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime.now(),
      );

      // Should not throw
      await writer.write(record, 'Test message');
    });

    test('should write with pretty print', () async {
      final writer = ConsoleWriter(prettyPrint: true);
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        timestamp: DateTime.now(),
      );

      // Should not throw
      await writer.write(record, 'Test message');
    });

    test('should flush without error', () async {
      final writer = ConsoleWriter();
      await writer.flush();
    });
  });

  group('LoggerBuilder with PrettyPrint', () {
    test('should configure prettyPrint', () {
      final builder = LoggerBuilder()
        ..console(prettyPrint: true);

      expect(builder._consolePrettyPrint, isTrue);
    });

    test('should build with prettyPrint', () {
      final logger = LoggerBuilder()
        ..console(prettyPrint: true)
        ..build();

      expect(logger, isNotNull);
      LoggerKit.close();
    });

    test('should configure errorStrategy', () {
      final builder = LoggerBuilder()
        ..errorStrategy(ErrorStrategy.throwException);

      expect(builder._errorStrategy, equals(ErrorStrategy.throwException));
    });

    test('should configure overflowStrategy', () {
      final builder = LoggerBuilder()
        ..overflowStrategy(OverflowStrategy.dropOldest);

      expect(builder._overflowStrategy, equals(OverflowStrategy.dropOldest));
    });
  });
}
