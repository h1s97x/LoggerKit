import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/log_record.dart';
import '../models/log_config.dart';
import 'log_writer.dart';

/// 远程写入器
class RemoteWriter implements LogWriter {
  RemoteWriter(this.config) {
    _startFlushTimer();
  }

  final LogConfig config;
  final List<LogRecord> _buffer = [];
  Timer? _flushTimer;

  static const int _bufferSize = 10;
  static const Duration _flushInterval = Duration(seconds: 30);

  void _startFlushTimer() {
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
  }

  @override
  Future<void> write(LogRecord record, String formatted) async {
    _buffer.add(record);

    if (_buffer.length >= _bufferSize) {
      await _flush();
    }
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty || config.remoteUrl == null) return;

    final logs = _buffer.map((r) => r.toJson()).toList();
    _buffer.clear();

    try {
      await http
          .post(
            Uri.parse(config.remoteUrl!),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'logs': logs}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // 上传失败，静默处理
      // ignore: avoid_print
      print('Failed to upload logs: $e');
    }
  }

  @override
  Future<void> flush() async {
    await _flush();
  }

  @override
  Future<void> close() async {
    _flushTimer?.cancel();
    await _flush();
  }
}
