import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('LoggerBuilder', () {
    tearDown(() async {
      await LoggerKit.close();
    });

    test('should create builder with default values', () {
      final builder = LoggerKit.builder();
      expect(builder, isNotNull);
    });

    test('should set minLevel', () {
      final builder = LoggerKit.builder();
      final result = builder.minLevel(LogLevel.info);
      
      expect(result, equals(builder));
    });

    test('should configure console output', () {
      final builder = LoggerKit.builder();
      final result = builder.console();
      
      expect(result, equals(builder));
    });

    test('should configure file output', () {
      final builder = LoggerKit.builder();
      final result = builder.file(
        path: './logs',
        maxSize: 5 * 1024 * 1024,
        maxCount: 10,
      );
      
      expect(result, equals(builder));
    });

    test('should configure remote output', () {
      final builder = LoggerKit.builder();
      final result = builder.remote(
        url: 'https://api.example.com/logs',
        batchSize: 20,
        flushInterval: 60,
      );
      
      expect(result, equals(builder));
    });

    test('should set privacy fields', () {
      final builder = LoggerKit.builder();
      final result = builder.privacyFields(['password', 'token']);
      
      expect(result, equals(builder));
    });

    test('should set context', () {
      final builder = LoggerKit.builder();
      final ctx = LogContext(userId: 'user_123');
      final result = builder.context(ctx);
      
      expect(result, equals(builder));
    });

    test('should add interceptors', () {
      final builder = LoggerKit.builder();
      final result = builder.addInterceptor(PassThroughInterceptor());
      
      expect(result, equals(builder));
    });

    test('should build logger with config', () {
      final logger = LoggerKit.builder()
        ..minLevel(LogLevel.info)
        ..noFile()
        ..noRemote()
        ..build();

      expect(logger, isNotNull);
      expect(logger.config.minLevel, equals(LogLevel.info));
    });

    test('should build and set global logger', () {
      final logger = LoggerKit.builder()
        ..minLevel(LogLevel.debug)
        ..noFile()
        ..noRemote()
        ..buildAndSetGlobal();

      expect(logger, equals(LoggerKit.instance));
    });

    test('should chain multiple configuration methods', () {
      final logger = LoggerKit.builder()
        ..minLevel(LogLevel.info)
        ..console(prettyPrint: false)
        ..timestamp(false)
        ..tag(true)
        ..emoji(false)
        ..privacyFields(['password'])
        ..noFile()
        ..noRemote()
        ..build();

      expect(logger.config.minLevel, equals(LogLevel.info));
      expect(logger.config.prettyPrint, isFalse);
      expect(logger.config.includeTimestamp, isFalse);
      expect(logger.config.includeEmoji, isFalse);
    });
  });
}
