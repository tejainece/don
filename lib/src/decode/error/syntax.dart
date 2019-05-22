import 'package:source_span/source_span.dart';

class SyntaxError {
  final FileSpan span;

  final String message;

  SyntaxError(this.span, this.message);

  String toString() {
    if(span == null) {
      return "Unexpected end of file: $message";
    }
    return span.message(message, color: true);
  }
}