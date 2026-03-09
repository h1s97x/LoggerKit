import 'dart:async';
import 'dart:io';
import 'package:log_kit/log_kit.dart';

/// LogKit性能基准测试
/// 运行命令: dart benchmark/log_kit_benchmark.dart
void main() async {
  print('🚀 Starting LogKit Benchmarks...\n');

  // 基础日志性能测试
  await _benchmarkBasicLogging();

  // 不同日志级别性能测试
  await _benchmarkLogLevels();

  // 带数据的日志性能测试
  await _benchmarkLoggingWithData();

  // 文件写入性能测试
  await _benchmarkFileLogging();

  // 并发日志性能测试
  await _benchmarkConcurrentLogging();

  // 清理
  await LogKit.close();
  print('\n✅ All benchmarks completed!');
}

/// 基础日志性能测试
Future<void> _benchmarkBasicLogging() async {
  print('=== Basic Logging Benchmark ===');

  LogKit.init(
    enableConsole: false,
    enableFile: false,
    enableRemote: false,
  );

  final iterations = 10000;
  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    LogKit.i('Test message $i');
  }

  stopwatch.stop();
  _printBenchmarkResult(
    'Basic Info Logging',
    iterations,
    stopwatch.elapsedMilliseconds,
  );

  await LogKit.close();
}

/// 不同日志级别性能测试
Future<void> _benchmarkLogLevels() async {
  print('\n=== Log Levels Benchmark ===');

  final iterations = 5000;
  final levels = {
    'Debug': () => LogKit.d('Debug message'),
    'Info': () => LogKit.i('Info message'),
    'Warning': () => LogKit.w('Warning message'),
    'Error': () => LogKit.e('Error message'),
    'Fatal': () => LogKit.f('Fatal message'),
  };

  for (var entry in levels.entries) {
    LogKit.init(
      enableConsole: false,
      enableFile: false,
      enableRemote: false,
    );

    final stopwatch = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      entry.value();
    }
    stopwatch.stop();

    _printBenchmarkResult(
      '${entry.key} Level',
      iterations,
      stopwatch.elapsedMilliseconds,
    );

    await LogKit.close();
  }
}

/// 带数据的日志性能测试
Future<void> _benchmarkLoggingWithData() async {
  print('\n=== Logging with Data Benchmark ===');

  LogKit.init(
    enableConsole: false,
    enableFile: false,
    enableRemote: false,
  );

  final iterations = 5000;
  final testData = {
    'userId': '12345',
    'action': 'click',
    'timestamp': DateTime.now().toIso8601String(),
    'metadata': {'screen': 'home', 'button': 'submit'},
  };

  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    LogKit.i('User action', tag: 'EVENT', data: testData);
  }

  stopwatch.stop();
  _printBenchmarkResult(
    'Logging with Data',
    iterations,
    stopwatch.elapsedMilliseconds,
  );

  await LogKit.close();
}

/// 文件写入性能测试
Future<void> _benchmarkFileLogging() async {
  print('\n=== File Logging Benchmark ===');

  final tempDir = Directory.systemTemp.createTempSync('log_kit_bench_');
  final logPath = '${tempDir.path}/benchmark.log';

  LogKit.init(
    enableConsole: false,
    enableFile: true,
    filePath: logPath,
    enableRemote: false,
  );

  final iterations = 1000;
  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    LogKit.i('File log message $i', tag: 'FILE_TEST');
  }

  // 等待文件写入完成
  await Future.delayed(Duration(milliseconds: 100));
  stopwatch.stop();

  _printBenchmarkResult(
    'File Logging',
    iterations,
    stopwatch.elapsedMilliseconds,
  );

  await LogKit.close();

  // 清理临时文件
  try {
    if (await tempDir.exists()) {
      // 等待文件句柄释放
      await Future.delayed(Duration(milliseconds: 200));
      tempDir.deleteSync(recursive: true);
    }
  } catch (e) {
    // 忽略清理错误
  }
}

/// 并发日志性能测试
Future<void> _benchmarkConcurrentLogging() async {
  print('\n=== Concurrent Logging Benchmark ===');

  LogKit.init(
    enableConsole: false,
    enableFile: false,
    enableRemote: false,
  );

  final iterations = 1000;
  final concurrency = 10;
  final stopwatch = Stopwatch()..start();

  final futures = <Future>[];
  for (var c = 0; c < concurrency; c++) {
    futures.add(Future(() {
      for (var i = 0; i < iterations; i++) {
        LogKit.i('Concurrent message from thread $c: $i');
      }
    }));
  }

  await Future.wait(futures);
  stopwatch.stop();

  _printBenchmarkResult(
    'Concurrent Logging ($concurrency threads)',
    iterations * concurrency,
    stopwatch.elapsedMilliseconds,
  );

  await LogKit.close();
}

/// 打印基准测试结果
void _printBenchmarkResult(String name, int iterations, int milliseconds) {
  final avgMs = milliseconds / iterations;
  final opsPerSec = (iterations / milliseconds * 1000).toStringAsFixed(2);

  print('  📊 $name:');
  print('     Iterations: $iterations');
  print('     Total Time: ${milliseconds}ms');
  print('     Average: ${avgMs.toStringAsFixed(4)}ms/op');
  print('     Throughput: $opsPerSec ops/sec');
}
