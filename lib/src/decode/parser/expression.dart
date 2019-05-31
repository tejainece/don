part of 'parser.dart';

const precedenceLookup = <TokenType, int>{
  TokenType.pow: 10,
  TokenType.asterisk: 20,
  TokenType.div: 20,
  TokenType.mod: 20,
  TokenType.plus: 30,
  TokenType.minus: 30,
  TokenType.bitwiseAnd: 40,
  TokenType.bitwiseXor: 50,
  TokenType.bitwiseOr: 60,
};

class ExpressionParser {
  static Value parse(State state) {
    return _parse(state, null);
  }

  static Value _parse(State state, Value left) {
    left ??= ValueParser.parse(state);
    Token op = state.peek();
    if(op?.type == TokenType.pow) {
      left = _exponent(state, left);
      op = state.peek();
    }
    final int precedence = precedenceLookup[op?.type];
    if (precedence == null) return left;

    while (state.peek() != null) {
      // Consume operator
      {
        op = state.peek();
        final int newPrecedence = precedenceLookup[op?.type];
        if (newPrecedence == null) return left;
        state.consume();
      }
      Value right = _testNextOp(state, precedence);

      final operator = Operator.fromToken(op);
      left = Expression(left.span.expand(right.span), left, operator, right);
    }

    return left;
  }

  static Value _testNextOp(State state, int precedence) {
    state.consumeMany(TokenType.newLine);
    var next = ValueParser.parse(state);
    Token op = state.peek();
    if(op?.type == TokenType.pow) {
      next = _exponent(state, next);
      op = state.peek();
    }
    final newPrecedence = precedenceLookup[op?.type];
    if (newPrecedence == null || newPrecedence >= precedence) {
      return next;
    }
    return _parse(state, next);
  }

  static Value _exponent(State state, Value left) {
    left ??= ValueParser.parse(state);
    Token op = state.consumeIf(TokenType.pow);
    if (op == null) return left;
    state.consumeMany(TokenType.newLine);
    var right = _exponent(state, null);
    return Expression(
        left.span.expand(right.span), left, Operator.fromToken(op), right);
  }
}

class ParenthesizedExpressionParser {
  static Value parse(State state) {
    final leftBracket = state.consumeIf(TokenType.leftBracket);
    if (leftBracket == null) {
      throw SyntaxError(
          leftBracket?.span, "Left bracket expected on expression");
    }

    final value = ExpressionParser.parse(state);

    final rightBracket = state.consumeIf(TokenType.rightBracket);
    if (rightBracket == null) {
      throw SyntaxError(
          leftBracket?.span, "Right bracket expected on end expression");
    }

    return value;
  }
}
