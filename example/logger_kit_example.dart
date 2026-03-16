import 'package:logger_kit/logger_kit.dart';

void main() async {
  // 初始化LoggerKit
  LoggerKit.init(
    minLevel: LogLevel.debug,
    enableConsole: true,
    enableFile: true,
    filePath: 'logs',
    enableRemote: false,
    includeEmoji: true,
  );

  // 基本日志
  LoggerKit.d('This is a debug message');
  LoggerKit.i('This is an info message');
  LoggerKit.w('This is a warning message');
  LoggerKit.e('This is an error message');

  // 带标签的日志
  LoggerKit.i('User logged in', tag: 'AUTH');
  LoggerKit.i('Data loaded', tag: 'DATA');

  // 带额外数据的日志
  LoggerKit.i(
    'API request completed',
    tag: 'API',
    data: {
      'url': 'https://api.example.com/users',
      'method': 'GET',
      'status': 200,
      'duration': 150,
    },
  );

  // 错误日志
  try {
    throw Exception('Something went wrong!');
  } catch (e, stack) {
    LoggerKit.e(
      'Failed to process data',
      tag: 'ERROR',
      error: e,
      stackTrace: stack,
    );
  }

  // 事件日志
  LoggerKit.event('user_login', data: {
    'userId': '12345',
    'timestamp': DateTime.now().toIso8601String(),
  });

  LoggerKit.event('button_clicked', data: {
    'buttonId': 'submit_button',
    'screen': 'home',
  });

  // 等待日志写入完成
  await Future.delayed(const Duration(seconds: 1));

  // 关闭LoggerKit
  await LoggerKit.close();

  // ignore: avoid_print
  print('\n LoggerKit example completed!');
}
