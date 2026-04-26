import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/strategy.dart';

void main() {
  group('ErrorStrategy', () {
    test('ignore should not throw', () {
      expect(ErrorStrategy.ignore, isNotNull);
    });

    test('logToFallback should not throw', () {
      expect(ErrorStrategy.logToFallback, isNotNull);
    });

    test('throwException should not throw', () {
      expect(ErrorStrategy.throwException, isNotNull);
    });

    test('should have correct names', () {
      expect(ErrorStrategy.ignore.name, equals('ignore'));
      expect(ErrorStrategy.logToFallback.name, equals('logToFallback'));
      expect(ErrorStrategy.throwException.name, equals('throwException'));
    });
  });

  group('OverflowStrategy', () {
    test('dropOldest should not be null', () {
      expect(OverflowStrategy.dropOldest, isNotNull);
    });

    test('dropNewest should not be null', () {
      expect(OverflowStrategy.dropNewest, isNotNull);
    });

    test('block should not be null', () {
      expect(OverflowStrategy.block, isNotNull);
    });

    test('should have correct names', () {
      expect(OverflowStrategy.dropOldest.name, equals('dropOldest'));
      expect(OverflowStrategy.dropNewest.name, equals('dropNewest'));
      expect(OverflowStrategy.block.name, equals('block'));
    });
  });
}
