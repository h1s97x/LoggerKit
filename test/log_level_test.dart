import 'package:flutter_test/flutter_test.dart';
import 'package:log_kit/log_kit.dart';

void main() {
  group('LogLevel', () {
    test('should have correct values', () {
      expect(LogLevel.debug.value, equals(0));
      expect(LogLevel.info.value, equals(1));
      expect(LogLevel.warning.value, equals(2));
      expect(LogLevel.error.value, equals(3));
      expect(LogLevel.fatal.value, equals(4));
    });

    test('should have correct names', () {
      expect(LogLevel.debug.name, equals('DEBUG'));
      expect(LogLevel.info.name, equals('INFO'));
      expect(LogLevel.warning.name, equals('WARNING'));
      expect(LogLevel.error.name, equals('ERROR'));
      expect(LogLevel.fatal.name, equals('FATAL'));
    });

    test('should have correct emojis', () {
      expect(LogLevel.debug.emoji, equals('🔍'));
      expect(LogLevel.info.emoji, equals('ℹ️'));
      expect(LogLevel.warning.emoji, equals('⚠️'));
      expect(LogLevel.error.emoji, equals('❌'));
      expect(LogLevel.fatal.emoji, equals('💀'));
    });

    test('shouldLog should work correctly', () {
      expect(LogLevel.debug.shouldLog(LogLevel.debug), isTrue);
      expect(LogLevel.debug.shouldLog(LogLevel.info), isFalse);
      expect(LogLevel.info.shouldLog(LogLevel.debug), isTrue);
      expect(LogLevel.warning.shouldLog(LogLevel.info), isTrue);
      expect(LogLevel.error.shouldLog(LogLevel.warning), isTrue);
      expect(LogLevel.fatal.shouldLog(LogLevel.error), isTrue);
    });

    test('toString should return name', () {
      expect(LogLevel.debug.toString(), equals('DEBUG'));
      expect(LogLevel.info.toString(), equals('INFO'));
    });
  });
}
