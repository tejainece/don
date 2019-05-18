part of 'scanner.dart';

class ScannerError implements Exception {
  final ErrorSeverity severity;
  final String message;
  final FileSpan span;

  ScannerError(this.severity, this.message, this.span);

  @override
  String toString() {
    if (span == null) return message;
    return '${span.start.toolString}: $message';
  }
}

class ErrorSeverity {
  final String name;

  const ErrorSeverity._(this.name);

  String toString() => name;

  static const warning = ErrorSeverity._("Warning");

  static const error = ErrorSeverity._("Error");

  static const info = ErrorSeverity._("Info");

  static const hint = ErrorSeverity._("Hint");
}