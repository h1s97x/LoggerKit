import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/strategy.dart';

void main() {
  group('ErrorStrategy', () {
    test('should have correct names', () {
      expect(ErrorStrategy.ignore.name, equals('ignore'));
      expect(ErrorStrategy.logToFallback.name, equals('logToFallback'));
      expect(ErrorStrategy.throwException.name, equals('throwException'));
    });

    test('should have correct descriptions', () {
      expect(ErrorStrategy.ignore.description, isNotEmpty);
      expect(ErrorStrategy.logToFallback.description, isNotEmpty);
      expect(ErrorStrategy.throwException.description, isNotEmpty);
    });
  });

  group('OverflowStrategy', () {
    test('should have correct names', () {
      expect(OverflowStrategy.dropOldest.name, equals('dropOldest'));
      expect(OverflowStrategy.dropNewest.name, equals('dropNewest'));
      expect(OverflowStrategy.block.name, equals('block'));
    });

    test('should have correct descriptions', () {
      expect(OverflowStrategy.dropOldest.description, isNotEmpty);
      expect(OverflowStrategy.dropNewest.description, isNotEmpty);
      expect(OverflowStrategy.block.description, isNotEmpty);
    });
  });
}
