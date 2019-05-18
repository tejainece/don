import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
import '../ast/ast.dart';

part 'error.dart';
part 'token.dart';

class Scanner {
  final List<ScannerError> errors = [];

  final List<Token> tokens = [];

  final SpanScanner scanner;

  LineScannerState errorStart;

  ScannerState state = ScannerState.normal;

  FileSpan _emptySpan;

  static final RegExp whitespace = RegExp(r'[ \t]+');

  Scanner(String string, {sourceUrl})
      : scanner = SpanScanner(string, sourceUrl: sourceUrl) {
    _emptySpan = scanner.emptySpan;
  }

  FileSpan get emptySpan => _emptySpan;

  List<Token> scan() {
    while (!scanner.isDone) {
      switch (state) {
        case ScannerState.normal:
          state = scanNormalToken();
          break;
        case ScannerState.multiLineComment:
          state = scanMultiLineComment();
          break;
      }
    }

    _checkCloseError();

    return tokens;
  }

  ScannerState scanNormalToken() {
    if (scanner.matches('/*')) return ScannerState.multiLineComment;
    if (scanner.scan(whitespace)) return ScannerState.normal;

    final List<Token> tokens = normalPatterns.keys
        .map((Pattern pattern) {
          if (!scanner.matches(pattern)) return null;

          final TokenType type = normalPatterns[pattern];

          if (type == TokenType.comment) {
            return SingleLineComment(scanner.lastSpan);
          }

          return Token(type, scanner.lastSpan, scanner.lastMatch);
        })
        .where((v) => v != null)
        .toList();

    // No match?
    if (tokens.isEmpty) {
      errorStart ??= scanner.state;
      scanner.readChar(); // Keep moving
      return ScannerState.normal;
    }

    _checkCloseError();

    tokens.sort((a, b) => b.span.length.compareTo(a.span.length));
    final token = tokens.first;

    this.tokens.add(tokens.first);
    scanner.scan(token.span.text);

    return ScannerState.normal;
  }

  ScannerState scanMultiLineComment() {
    if (!scanner.matches('/*')) return ScannerState.normal;
    tokens.add(_scanMultilineComment());
    return ScannerState.normal;
  }

  MultiLineComment _scanMultilineComment() {
    scanner.scan('/*');
    var span = scanner.lastSpan;
    var members = <MultiLineCommentMember>[];
    LineScannerState textStart;

    void flush() {
      if (textStart != null) {
        members.add(MultiLineCommentText(scanner.spanFrom(textStart)));
        textStart = errorStart = null;
      }
    }

    while (!scanner.isDone) {
      if (scanner.matches('*/')) {
        flush();
        scanner.scan('*/');
        break;
      } else if (scanner.matches('/*')) {
        flush();
        members.add(NestedMultiLineComment(_scanMultilineComment()));
      } else {
        textStart ??= scanner.state;
        scanner.readChar();
      }
    }

    flush();
    return MultiLineComment(members, span);
  }

  void _checkCloseError() {
    if (errorStart != null) {
      var span = scanner.spanFrom(errorStart);
      var message = 'Unexpected text "${span.text}".';

      errors.add(ScannerError(
        ErrorSeverity.warning,
        message,
        span,
      ));
      errorStart = null;
    }
  }
}

enum ScannerState { normal, multiLineComment }
