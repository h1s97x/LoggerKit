import 'package:flutter_test/flutter_test.dart';
import 'package:log_kit/log_kit.dart';

void main() {
  group('LogRecord', () {
    test('should create with required fields', () {
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
      );

      expect(record.level, equals(LogLevel.info));
      expect(record.message, equals('Test message'));
      expect(record.timestamp, isNotNull);
      expect(record.tag, isNull);
      expect(record.error, isNull);
      expect(record.stackTrace, isNull);
      expect(record.data, isNull);
    });

    test('should create with all fields', () {
      final timestamp = DateTime.now();
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final data = {'key': 'value'};

      final record = LogRecord(
        level: LogLevel.error,
        message: 'Error message',
        timestamp: timestamp,
        tag: 'TEST',
        error: error,
        stackTrace: stackTrace,
        data: data,
      );

      expect(record.level, equals(LogLevel.error));
      expect(record.message, equals('Error message'));
      expect(record.timestamp, equals(timestamp));
      expect(record.tag, equals('TEST'));
      expect(record.error, equals(error));
      expect(record.stackTrace, equals(stackTrace));
      expect(record.data, equals(data));
    });

    test('should convert to JSON', () {
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
        data: {'key': 'value'},
      );

      final json = record.toJson();

      expect(json['level'], equals('INFO'));
      expect(json['message'], equals('Test message'));
      expect(json['timestamp'], isNotNull);
      expect(json['tag'], equals('TEST'));
      expect(json['data'], equals({'key': 'value'}));
    });

    test('should create from JSON', () {
      final json = {
        'level': 'INFO',
        'message': 'Test message',
        'timestamp': DateTime.now().toIso8601String(),
        'tag': 'TEST',
        'data': {'key': 'value'},
      };

      final record = LogRecord.fromJson(json);

      expect(record.level, equals(LogLevel.info));
      expect(record.message, equals('Test message'));
      expect(record.tag, equals('TEST'));
      expect(record.data, equals({'key': 'value'}));
    });

    test('toString should format correctly', () {
      final record = LogRecord(
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TEST',
      );

      final str = record.toString();

      expect(str, contains('[INFO]'));
      expect(str, contains('[TEST]'));
      expect(str, contains('Test message'));
    });
  });
}
