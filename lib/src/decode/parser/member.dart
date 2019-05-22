part of 'parser.dart';

class MapKeyParser {
  static KeyChain parse(State state) {
    final variable = state.consumeIf(TokenType.key);
    if(variable == null) {
      throw SyntaxError(state.peek()?.span, "Variable expected");
    }

    final accesses = <Access>[];

    while(!state.done) {
      final next = state.peek();

      if(next.type == TokenType.dot) {
        state.consume();
        final key = state.consumeIf(TokenType.key);
        if(key == null) {
          throw SyntaxError(state.peek()?.span, "Key expected");
        }
        accesses.add(MemberAccess(next.span.expand(key.span), key.text));
      } else if(next.type == TokenType.leftSquareBracket) {
        accesses.add(SubscriptParser.parse(state));
      } else {
        break;
      }
    }

    return KeyChain.fromToken(variable, accesses);
  }
}

class IdentifierValueParser {
  static VarUse parse(State state) {
    final variable = state.consumeIf(TokenType.identifier);
    if(variable == null) {
      throw SyntaxError(state.peek()?.span, "Variable expected");
    }

    final accesses = <Access>[];

    while(!state.done) {
      final next = state.peek();

      if(next.type == TokenType.dot) {
        state.consume();
        final key = state.consumeIf(TokenType.key);
        if(key == null) {
          throw SyntaxError(state.peek()?.span, "Key expected");
        }
        accesses.add(MemberAccess(next.span.expand(key.span), key.text));
      } else if(next.type == TokenType.leftSquareBracket) {
        accesses.add(SubscriptParser.parse(state));
      } else {
        break;
      }
    }

    return VarUse.fromToken(variable, accesses);
  }
}

class SubscriptParser {
  static SubscriptAccess parse(State state) {
    final leftBracket = state.consumeIf(TokenType.leftSquareBracket);
    if(leftBracket == null) {
      throw SyntaxError(state.peek()?.span, "'[' missing in subscript access");
    }

    // TODO could be expression
    final value = IntParser.parse(state);

    final rightBracket = state.consumeIf(TokenType.rightSquareBracket);
    if(rightBracket == null) {
      throw SyntaxError(state.peek()?.span, "']' missing in subscript access");
    }

    return SubscriptAccess(leftBracket.span.expand(rightBracket.span), value);
  }
}

class ExpressionParser {
  static Expression parse(State state) {
    // TODO
  }
}