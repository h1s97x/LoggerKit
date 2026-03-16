import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('LoggerKit', () {
    setUp(() {
      // 每个测试前初始化
      LoggerKit.init(
        enableConsole: false,
        enableFile: false,
        enableRemote: false,
      );
    });

    tearDown(() async {
      // 每个测试后清理
      await LoggerKit.close();
    });

    test('should initialize with default config', () {
      LoggerKit.init();
      expect(LoggerKit.instance, isNotNull);
    });

    test('should initialize with custom config', () {
      LoggerKit.init(
        minLevel: LogLevel.warning,
        enableConsole: true,
      );
      expect(LoggerKit.instance, isNotNull);
    });

    test('should record debug log', () {
      expect(() => LoggerKit.d('Debug message'), returnsNormally);
    });

    test('should record info log', () {
      expect(() => LoggerKit.i('Info message'), returnsNormally);
    });

    test('should record warning log', () {
      expect(() => LoggerKit.w('Warning message'), returnsNormally);
    });

    test('should record error log', () {
      expect(() => LoggerKit.e('Error message'), returnsNormally);
    });

    test('should record fatal log', () {
      expect(() => LoggerKit.f('Fatal message'), returnsNormally);
    });

    test('should record log with tag', () {
      expect(
        () => LoggerKit.i('Message', tag: 'TEST'),
        returnsNormally,
      );
    });

    test('should record log with data', () {
      expect(
        () => LoggerKit.i('Message', data: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('should record event', () {
      expect(
        () => LoggerKit.event('test_event', data: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('should close successfully', () async {
      await expectLater(LoggerKit.close(), completes);
    });
  });
}
