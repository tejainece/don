part of 'parser.dart';

class AssignOpParser {
  static AssignOp parse(State state) {
    final opToken = state.peek();

    if(opToken.type == TokenType.assign) {
      state.consume();
      return AssignOp.assign;
    } else if(opToken.type == TokenType.addAssign) {
      state.consume();
      return AssignOp.addAssign;
    } else if(opToken.type == TokenType.mulAssign) {
      state.consume();
      return AssignOp.mulAssign;
    }

    throw SyntaxError("Invalid assign operator");
  }
}