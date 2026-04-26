import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('LogContext', () {
    late LogContext context;

    setUp(() {
      context = LogContext();
    });

    test('should create empty context', () {
      expect(context.isEmpty, isTrue);
      expect(context.isNotEmpty, isFalse);
      expect(context.userId, isNull);
      expect(context.sessionId, isNull);
      expect(context.traceId, isNull);
      expect(context.deviceId, isNull);
      expect(context.custom, isEmpty);
    });

    test('should create context with values', () {
      final ctx = LogContext(
        userId: 'user_123',
        sessionId: 'session_abc',
        traceId: 'trace_xyz',
        deviceId: 'device_001',
      );

      expect(ctx.userId, equals('user_123'));
      expect(ctx.sessionId, equals('session_abc'));
      expect(ctx.traceId, equals('trace_xyz'));
      expect(ctx.deviceId, equals('device_001'));
      expect(ctx.isEmpty, isFalse);
    });

    test('should set and get custom fields', () {
      context.set('key1', 'value1');
      context.set('key2', 123);
      context.set('key3', true);

      expect(context.get('key1'), equals('value1'));
      expect(context.get('key2'), equals(123));
      expect(context.get('key3'), equals(true));
      expect(context.containsKey('key1'), isTrue);
      expect(context.containsKey('nonexistent'), isFalse);
    });

    test('should remove custom field', () {
      context.set('key1', 'value1');
      expect(context.remove('key1'), equals('value1'));
      expect(context.containsKey('key1'), isFalse);
      expect(context.remove('nonexistent'), isNull);
    });

    test('should clear custom fields', () {
      context.set('key1', 'value1');
      context.set('key2', 'value2');
      expect(context.custom.length, equals(2));

      context.clear();
      expect(context.custom, isEmpty);
    });

    test('should clear all context', () {
      final ctx = LogContext(
        userId: 'user_123',
        sessionId: 'session_abc',
      );
      ctx.set('key1', 'value1');

      ctx.clearAll();

      expect(ctx.userId, isNull);
      expect(ctx.sessionId, isNull);
      expect(ctx.custom, isEmpty);
    });

    test('should convert to map', () {
      context.userId = 'user_123';
      context.sessionId = 'session_abc';
      context.set('custom1', 'value1');

      final map = context.toMap();

      expect(map['userId'], equals('user_123'));
      expect(map['sessionId'], equals('session_abc'));
      expect(map['custom']!['custom1'], equals('value1'));
      expect(map.containsKey('traceId'), isFalse);
    });

    test('should copy with overrides', () {
      final original = LogContext(
        userId: 'user_123',
        sessionId: 'session_abc',
      );
      original.set('key1', 'value1');

      final copy = original.copyWith(
        userId: 'new_user',
        clearSessionId: true,
      );

      expect(copy.userId, equals('new_user'));
      expect(copy.sessionId, isNull);
      expect(copy.get('key1'), equals('value1'));
    });

    test('should have correct toString', () {
      context.userId = 'user_123';
      final str = context.toString();

      expect(str, contains('LogContext'));
      expect(str, contains('user_123'));
    });
  });
}
