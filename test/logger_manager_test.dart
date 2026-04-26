import 'package:flutter_test/flutter_test.dart';
import 'package:logger_kit/logger_kit.dart';

void main() {
  group('LoggerManager', () {
    late LoggerManager manager;

    setUp(() {
      manager = LoggerManager.instance;
    });

    tearDown(() async {
      await manager.clearAll();
    });

    test('should create namespace logger', () {
      final logger = manager.namespace('test');
      expect(logger, isNotNull);
      expect(logger.namespace, equals('test'));
    });

    test('should return same logger for same namespace', () {
      final logger1 = manager.namespace('test');
      final logger2 = manager.namespace('test');

      expect(logger1, equals(logger2));
    });

    test('should create logger with custom config', () {
      const customConfig = LogConfig(
        minLevel: LogLevel.warning,
        enableConsole: true,
      );

      final logger = manager.namespace('custom', config: customConfig);

      expect(logger.config.minLevel, equals(LogLevel.warning));
    });

    test('should check if namespace exists', () {
      expect(manager.hasNamespace('nonexistent'), isFalse);

      manager.namespace('exists');

      expect(manager.hasNamespace('exists'), isTrue);
    });

    test('should get all namespace names', () {
      manager.namespace('ns1');
      manager.namespace('ns2');
      manager.namespace('ns3');

      final names = manager.namespaceNames;

      expect(names, containsAll(['ns1', 'ns2', 'ns3']));
    });

    test('should remove namespace', () async {
      manager.namespace('toremove');
      expect(manager.hasNamespace('toremove'), isTrue);

      await manager.removeNamespace('toremove');

      expect(manager.hasNamespace('toremove'), isFalse);
    });

    test('should register preset namespace', () {
      manager.registerNamespace('preset',
          config: const LogConfig(
            minLevel: LogLevel.error,
          ));

      final logger = manager.namespace('preset');

      expect(logger.config.minLevel, equals(LogLevel.error));
    });

    test('should clear all namespaces', () async {
      manager.namespace('ns1');
      manager.namespace('ns2');

      await manager.clearAll();

      expect(manager.namespaceNames, isEmpty);
    });

    test('should create logger without registering', () {
      final logger = manager.createLogger(
        namespace: 'unregistered',
        config: const LogConfig(minLevel: LogLevel.info),
      );

      expect(logger.namespace, equals('unregistered'));
      expect(manager.hasNamespace('unregistered'), isFalse);
    });

    test('preset shortcuts should work', () {
      final networkLogger = manager.network;
      final dbLogger = manager.database;
      final uiLogger = manager.ui;

      expect(networkLogger.namespace, equals('network'));
      expect(dbLogger.namespace, equals('database'));
      expect(uiLogger.namespace, equals('ui'));
    });
  });

  group('LoggerKit namespace', () {
    tearDown(() async {
      await LoggerKit.close();
      await LoggerManager.instance.clearAll();
    });

    test('LoggerKit.namespace should create namespace logger', () {
      final logger = LoggerKit.namespace('test');
      expect(logger, isNotNull);
      expect(logger.namespace, equals('test'));
    });

    test('LoggerKit.network shortcut should work', () {
      final logger = LoggerKit.network;
      expect(logger.namespace, equals('network'));
    });
  });
}
