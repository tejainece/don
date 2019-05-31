import 'package:don/parser.dart';

import '../scanner/scanner.dart';
import 'package:source_span/source_span.dart';

class State {
  final List<ScannerError> errors = [];
  //final Scanner scanner;
  final List<Token> tokens;
  int _index = -1;

  State(this.tokens);

  List<Token> computeRest() {
    if (done) return [];
    //print(_index);
    //print(scanner.tokens.skip(_index));
    return tokens.skip(_index).toList();
  }

  /// Joins the [tokens] into a single [FileSpan].
  FileSpan spanFrom(Iterable<Token> tokens) {
    return tokens.map((t) => t.span).reduce((a, b) => a.expand(b));
  }

  /// Returns `true` if there is no more input.
  bool get done => _index >= tokens.length - 1;

  /// Lookahead without consuming.
  Token peek() {
    if (done) return null;
    return tokens[_index + 1];
  }

  /// Lookahead and consume.
  Token consume() {
    if (done) return null;
    return tokens[++_index];
  }

  Token consumeIf(TokenType type) {
    final token = peek();
    if(token == null) return null;
    if(token.type != type) return null;
    consume();
    return token;
  }

  void consumeMany(TokenType type) {
    while(consumeIf(type) != null);
  }

  Token nextIfOneOf(Iterable<TokenType> token) {
    Token t = peek();
    for (TokenType ch in token) {
      if (t.type == ch) {
        consume();
        return t;
      }
    }
    return null;
  }

  /* TODO
  /// Parses available comments.
  List<Comment> parseComments() {
    var comments = <Comment>[];
    Token token;

    while ((token = nextToken(TokenType.comment)) != null) {
      comments.add(token as Comment);
    }

    return comments;
  }
   */

  /// Runs [callback]. If the [callback] returns `null`, then the parser's
  /// position will be preserved, and any parse errors will be removed.
  T lookAhead<T>(T callback()) {
    var replay = _index;
    var result = callback();
    var len = errors.length;

    if (result == null) {
      _index = replay;

      if (errors.length > len) errors.removeRange(len, errors.length - 1);
    }

    return result;
  }

  Token get last {
    if(tokens.isEmpty) return null;
    return tokens.last;
  }
}