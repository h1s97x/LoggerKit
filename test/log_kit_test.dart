import 'package:flutter_test/flutter_test.dart';
import 'package:log_kit/log_kit.dart';

void main() {
  group('LogKit', () {
    setUp(() {
      // 每个测试前初始化
      LogKit.init(
        enableConsole: false,
        enableFile: false,
        enableRemote: false,
      );
    });

    tearDown(() async {
      // 每个测试后清理
      await LogKit.close();
    });

    test('should initialize with default config', () {
      LogKit.init();
      expect(LogKit.instance, isNotNull);
    });

    test('should initialize with custom config', () {
      LogKit.init(
        minLevel: LogLevel.warning,
        enableConsole: true,
      );
      expect(LogKit.instance, isNotNull);
    });

    test('should record debug log', () {
      expect(() => LogKit.d('Debug message'), returnsNormally);
    });

    test('should record info log', () {
      expect(() => LogKit.i('Info message'), returnsNormally);
    });

    test('should record warning log', () {
      expect(() => LogKit.w('Warning message'), returnsNormally);
    });

    test('should record error log', () {
      expect(() => LogKit.e('Error message'), returnsNormally);
    });

    test('should record fatal log', () {
      expect(() => LogKit.f('Fatal message'), returnsNormally);
    });

    test('should record log with tag', () {
      expect(
        () => LogKit.i('Message', tag: 'TEST'),
        returnsNormally,
      );
    });

    test('should record log with data', () {
      expect(
        () => LogKit.i('Message', data: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('should record event', () {
      expect(
        () => LogKit.event('test_event', data: {'key': 'value'}),
        returnsNormally,
      );
    });

    test('should close successfully', () async {
      await expectLater(LogKit.close(), completes);
    });
  });
}
