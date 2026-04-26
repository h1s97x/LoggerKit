import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/log_record.dart';
import '../models/log_config.dart';
import 'log_writer.dart';

/// 文件写入器
class FileWriter implements LogWriter {
  FileWriter(this.config);

  final LogConfig config;
  File? _currentFile;
  IOSink? _sink;
  int _currentSize = 0;

  Future<void> _ensureFile() async {
    if (_currentFile == null || _currentSize >= config.maxFileSize) {
      await _rotateFile();
    }

    _sink ??= _currentFile!.openWrite(mode: FileMode.append);
  }

  Future<void> _rotateFile() async {
    await _sink?.close();
    _sink = null;

    final dir = Directory(config.filePath ?? 'logs');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 生成新文件名
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'log_$timestamp.txt';
    _currentFile = File(path.join(dir.path, fileName));
    _currentSize = 0;

    // 清理旧文件
    await _cleanOldFiles(dir);
  }

  Future<void> _cleanOldFiles(Directory dir) async {
    final files = await dir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.txt'))
        .cast<File>()
        .toList();

    if (files.length > config.maxFileCount) {
      // 按修改时间排序
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return aStat.modified.compareTo(bStat.modified);
      });

      // 删除最旧的文件
      final toDelete = files.length - config.maxFileCount;
      for (var i = 0; i < toDelete; i++) {
        await files[i].delete();
      }
    }
  }

  @override
  Future<void> write(LogRecord record, String formatted) async {
    await _ensureFile();

    _sink?.writeln(formatted);
    _currentSize += formatted.length + 1; // +1 for newline
  }

  @override
  Future<void> flush() async {
    await _sink?.flush();
  }

  @override
  Future<void> close() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }
}
