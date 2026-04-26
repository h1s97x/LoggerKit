import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('LogInterceptor', () {
    test('PassThroughInterceptor should pass records unchanged', () {
      final interceptor = PassThroughInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {'key': 'value'},
      );

      final result = interceptor.intercept(record);

      expect(result, equals(record));
    });

    test('Custom interceptor should be able to modify records', () {
      final interceptor = _AddDataInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
      );

      final result = interceptor.intercept(record);

      expect(result!.data, isNotNull);
      expect(result.data!['injected'], equals('value'));
    });

    test('Custom interceptor can discard records', () {
      final interceptor = _DiscardingInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
      );

      final result = interceptor.intercept(record);

      expect(result, isNull);
    });

    test('interceptor order should determine execution sequence', () {
      final results = <int>[];

      final first = _RecordingInterceptor(1, results);
      final second = _RecordingInterceptor(2, results);
      final third = _RecordingInterceptor(3, results);

      final composite = CompositeInterceptor([third, first, second]);
      final record = LogRecord(level: LogLevel.info, message: 'test');

      composite.intercept(record);

      expect(results, equals([1, 2, 3]));
    });

    test('CompositeInterceptor should stop on null when configured', () {
      final composite = CompositeInterceptor([
        PassThroughInterceptor(),
        _DiscardingInterceptor(),
        PassThroughInterceptor(),
      ], stopOnNull: true);

      final record = LogRecord(level: LogLevel.info, message: 'test');
      final result = composite.intercept(record);

      expect(result, isNull);
    });

    test('CompositeInterceptor can add and remove interceptors', () {
      final composite = CompositeInterceptor([]);
      expect(composite.isEmpty, isTrue);

      final interceptor = PassThroughInterceptor();
      composite.add(interceptor);
      expect(composite.isNotEmpty, isTrue);
      expect(composite.length, equals(1));

      composite.remove(interceptor);
      expect(composite.isEmpty, isTrue);
    });
  });

  group('PrivacyInterceptor', () {
    test('should filter default sensitive fields', () {
      final interceptor = PrivacyInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {
          'username': 'john',
          'password': 'secret123',
          'token': 'token123',
        },
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['username'], equals('john'));
      expect(result.data!['password'], equals('***'));
      expect(result.data!['token'], equals('***'));
    });

    test('should filter custom sensitive fields', () {
      final interceptor = PrivacyInterceptor(
        extraSensitiveFields: ['customSecret'],
      );
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {
          'customSecret': 'hidden',
          'normal': 'visible',
        },
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['customSecret'], equals('***'));
      expect(result.data!['normal'], equals('visible'));
    });

    test('should recursively filter nested objects', () {
      final interceptor = PrivacyInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {
          'user': {
            'name': 'john',
            'password': 'secret',
          },
        },
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['user']['name'], equals('john'));
      expect(result.data!['user']['password'], equals('***'));
    });

    test('should filter arrays', () {
      final interceptor = PrivacyInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {
          'users': [
            {'name': 'john', 'token': 'abc'},
            {'name': 'jane', 'token': 'xyz'},
          ],
        },
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['users'][0]['name'], equals('john'));
      expect(result.data!['users'][0]['token'], equals('***'));
    });

    test('should handle null data', () {
      final interceptor = PrivacyInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: null,
      );

      final result = interceptor.intercept(record);

      expect(result, isNotNull);
      expect(result!.data, isNull);
    });

    test('should use custom mask value', () {
      final interceptor = PrivacyInterceptor(maskValue: '[REDACTED]');
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {'password': 'secret'},
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['password'], equals('[REDACTED]'));
    });

    test('should be case insensitive', () {
      final interceptor = PrivacyInterceptor();
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {
          'PASSWORD': 'secret',
          'Password': 'secret2',
          'password': 'secret3',
        },
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['PASSWORD'], equals('***'));
      expect(result.data!['Password'], equals('***'));
      expect(result.data!['password'], equals('***'));
    });
  });

  group('ContextInterceptor', () {
    test('should inject context into record', () {
      final testContext = LogContext(
        userId: 'user_123',
        sessionId: 'session_abc',
      );

      final interceptor = ContextInterceptor(getContext: () => testContext);
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
      );

      final result = interceptor.intercept(record);

      expect(result!.data, isNotNull);
      expect(result.data!['userId'], equals('user_123'));
      expect(result.data!['sessionId'], equals('session_abc'));
    });

    test('should merge context with existing data', () {
      final testContext = LogContext(userId: 'user_123');

      final interceptor = ContextInterceptor(getContext: () => testContext);
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: {'action': 'click'},
      );

      final result = interceptor.intercept(record);

      expect(result!.data!['userId'], equals('user_123'));
      expect(result.data!['action'], equals('click'));
    });

    test('should not modify record when context is empty', () {
      final interceptor = ContextInterceptor(getContext: () => LogContext());
      final originalData = {'key': 'value'};
      final record = LogRecord(
        level: LogLevel.info,
        message: 'test',
        data: originalData,
      );

      final result = interceptor.intercept(record);

      expect(result, equals(record));
    });
  });
}

// Test helper interceptors

class _AddDataInterceptor implements LogInterceptor {
  @override
  int get order => 0;

  @override
  LogRecord? intercept(LogRecord record) {
    return record.copyWith(
      data: {
        ...?record.data,
        'injected': 'value',
      },
    );
  }
}

class _DiscardingInterceptor implements LogInterceptor {
  @override
  int get order => 0;

  @override
  LogRecord? intercept(LogRecord record) => null;
}

class _RecordingInterceptor implements LogInterceptor {
  _RecordingInterceptor(this._order, this.results);

  final int _order;
  final List<int> results;

  @override
  int get order => _order;

  @override
  LogRecord? intercept(LogRecord record) {
    results.add(order);
    return record;
  }
}
