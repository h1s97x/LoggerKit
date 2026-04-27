/// Error and overflow handling strategies for LoggerKit.
///
/// This module provides strategies for handling:
/// - [ErrorStrategy]: How to handle errors during log writing
/// - [OverflowStrategy]: How to handle queue overflow
///
/// ## Quick Start
///
/// ```dart
/// import 'package:logger_kit/strategy.dart';
///
/// // Use ignore strategy (default)
/// LoggerKit.builder()
///   ..errorStrategy(ErrorStrategy.ignore)
///   ..build();
///
/// // Use dropOldest for high-throughput
/// LoggerKit.builder()
///   ..overflowStrategy(OverflowStrategy.dropOldest)
///   ..build();
/// ```
// ignore_for_file: unnecessary_library_name
library logger_kit.strategy;

export 'error_strategy.dart';
export 'overflow_strategy.dart';
/// ```
// ignore_for_file: unnecessary_library_name
library logger_kit.strategy;

export 'error_strategy.dart';
export 'overflow_strategy.dart';
