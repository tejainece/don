part of 'parser.dart';

class AssignOpParser {
  static AssignOp parse(State state) {
    final token = state.peek();

    switch(token.type) {
      case TokenType.assign:
      case TokenType.addAssign:
      case TokenType.mulAssign:
        state.consume();
        return AssignOp.fromToken(token);
      default:
        throw SyntaxError(token?.span, "Assign operator expected");
    }
  }
}