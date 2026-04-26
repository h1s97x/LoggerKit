import '../models/log_record.dart';
import 'log_interceptor.dart';

/// Interceptor that filters sensitive data from log records.
///
/// This interceptor automatically removes or masks sensitive fields
/// such as passwords, tokens, and API keys from log data.
///
/// ## Default Sensitive Fields
///
/// - password
/// - passwd
/// - token
/// - accessToken
/// - refreshToken
/// - apiKey
/// - api_key
/// - secret
/// - auth
/// - authorization
/// - credential
/// - creditCard
/// - cardNumber
/// - cvv
/// - ssn
/// - socialSecurityNumber
///
/// ## Usage
///
/// ```dart
/// LoggerKit.builder()
///   ..addInterceptor(PrivacyInterceptor())
///   ..build();
/// ```
///
/// ## Custom Fields
///
/// You can customize which fields are considered sensitive:
///
/// ```dart
/// LoggerKit.builder()
///   ..addInterceptor(PrivacyInterceptor(
///     sensitiveFields: ['mySecret', 'privateData'],
///   ))
///   ..build();
/// ```
class PrivacyInterceptor implements LogInterceptor {
  /// Create a new [PrivacyInterceptor].
  ///
  /// Parameters:
  /// - [sensitiveFields]: Additional field names to filter
  /// - [maskValue]: The value to replace sensitive data with (default: '***')
  /// - [recursive]: Whether to filter nested objects (default: true)
  PrivacyInterceptor({
    List<String>? sensitiveFields,
    this.maskValue = '***',
    this.recursive = true,
  }) : sensitiveFields = {
    // Default sensitive field names
    'password',
    'passwd',
    'pwd',
    'token',
    'accessToken',
    'access_token',
    'refreshToken',
    'refresh_token',
    'apiKey',
    'api_key',
    'secret',
    'auth',
    'authorization',
    'bearer',
    'credential',
    'credentials',
    'creditCard',
    'cardNumber',
    'card_number',
    'cvv',
    'ssn',
    'socialSecurityNumber',
    'private',
    'privateKey',
    'private_key',
    // Add custom fields
    ...?sensitiveFields,
  };

  /// Set of field names considered sensitive.
  final Set<String> sensitiveFields;

  /// The value used to mask sensitive data.
  final String maskValue;

  /// Whether to recursively filter nested objects.
  final bool recursive;

  @override
  int get order => 50; // Run after context injection

  @override
  LogRecord? intercept(LogRecord record) {
    if (record.data == null || record.data!.isEmpty) {
      return record;
    }

    // Filter the data map
    final filteredData = _filterMap(record.data!);

    // Return new record with filtered data
    return LogRecord(
      level: record.level,
      message: record.message,
      timestamp: record.timestamp,
      tag: record.tag,
      error: record.error,
      stackTrace: record.stackTrace,
      data: filteredData,
    );
  }

  /// Filter a map, recursively processing nested maps and lists.
  Map<String, dynamic> _filterMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      final key = entry.key.toLowerCase();
      final value = entry.value;

      if (_isSensitiveField(key)) {
        // Replace sensitive data with mask
        result[entry.key] = maskValue;
      } else if (recursive) {
        // Recursively filter nested structures
        result[entry.key] = _filterValue(value);
      } else {
        result[entry.key] = value;
      }
    }

    return result;
  }

  /// Filter a value, recursively processing nested maps and lists.
  dynamic _filterValue(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return _filterMap(value);
    } else if (value is List) {
      return _filterList(value);
    } else {
      return value;
    }
  }

  /// Filter a list, recursively processing nested structures.
  List<dynamic> _filterList(List<dynamic> list) {
    return list.map(_filterValue).toList();
  }

  /// Check if a field name is sensitive.
  bool _isSensitiveField(String fieldName) {
    final lower = fieldName.toLowerCase();
    
    // Check exact match
    if (sensitiveFields.contains(lower)) {
      return true;
    }

    // Check if contains sensitive keywords
    for (final sensitive in sensitiveFields) {
      if (lower.contains(sensitive)) {
        return true;
      }
    }

    return false;
  }
}
