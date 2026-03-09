import 'package:flutter_test/flutter_test.dart';
import 'package:log_kit/log_kit.dart';

void main() {
  group('LevelFilter', () {
    test('should filter by level', () {
      final filter = LevelFilter(LogLevel.warning);

      final debugRecord = LogRecord(
        level: LogLevel.debug,
        message: 'Debug',
      );
      final infoRecord = LogRecord(
        level: LogLevel.info,
        message: 'Info',
      );
      final warningRecord = LogRecord(
        level: LogLevel.warning,
        message: 'Warning',
      );
      final errorRecord = LogRecord(
        level: LogLevel.error,
        message: 'Error',
      );

      expect(filter.shouldLog(debugRecord), isFalse);
      expect(filter.shouldLog(infoRecord), isFalse);
      expect(filter.shouldLog(warningRecord), isTrue);
      expect(filter.shouldLog(errorRecord), isTrue);
    });
  });

  group('TagFilter', () {
    test('should filter by tag', () {
      final filter = TagFilter(['IMPORTANT', 'CRITICAL']);

      final noTagRecord = LogRecord(
        level: LogLevel.info,
        message: 'No tag',
      );
      final allowedTagRecord = LogRecord(
        level: LogLevel.info,
        message: 'Allowed',
        tag: 'IMPORTANT',
      );
      final disallowedTagRecord = LogRecord(
        level: LogLevel.info,
        message: 'Disallowed',
        tag: 'OTHER',
      );

      expect(filter.shouldLog(noTagRecord), isFalse);
      expect(filter.shouldLog(allowedTagRecord), isTrue);
      expect(filter.shouldLog(disallowedTagRecord), isFalse);
    });
  });

  group('CompositeFilter', () {
    test('should require all filters by default', () {
      final levelFilter = LevelFilter(LogLevel.warning);
      final tagFilter = TagFilter(['IMPORTANT']);
      final compositeFilter = CompositeFilter([levelFilter, tagFilter]);

      final validRecord = LogRecord(
        level: LogLevel.error,
        message: 'Valid',
        tag: 'IMPORTANT',
      );
      final invalidLevelRecord = LogRecord(
        level: LogLevel.info,
        message: 'Invalid level',
        tag: 'IMPORTANT',
      );
      final invalidTagRecord = LogRecord(
        level: LogLevel.error,
        message: 'Invalid tag',
        tag: 'OTHER',
      );

      expect(compositeFilter.shouldLog(validRecord), isTrue);
      expect(compositeFilter.shouldLog(invalidLevelRecord), isFalse);
      expect(compositeFilter.shouldLog(invalidTagRecord), isFalse);
    });

    test('should allow any filter when requireAll is false', () {
      final levelFilter = LevelFilter(LogLevel.warning);
      final tagFilter = TagFilter(['IMPORTANT']);
      final compositeFilter = CompositeFilter(
        [levelFilter, tagFilter],
        requireAll: false,
      );

      final validLevelRecord = LogRecord(
        level: LogLevel.error,
        message: 'Valid level',
        tag: 'OTHER',
      );
      final validTagRecord = LogRecord(
        level: LogLevel.info,
        message: 'Valid tag',
        tag: 'IMPORTANT',
      );
      final invalidRecord = LogRecord(
        level: LogLevel.info,
        message: 'Invalid',
        tag: 'OTHER',
      );

      expect(compositeFilter.shouldLog(validLevelRecord), isTrue);
      expect(compositeFilter.shouldLog(validTagRecord), isTrue);
      expect(compositeFilter.shouldLog(invalidRecord), isFalse);
    });
  });
}
