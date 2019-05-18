part of 'parser.dart';

class MapKeyParser {
  static KeyChain parse(State state) {
    final variable = state.consumeIf(TokenType.key);
    if(variable == null) {
      throw Exception("Variable expected!");
    }

    final accesses = <MemberAccess>[];

    while(!state.done) {
      final next = state.peek();

      if(next.type == TokenType.dot) {
        state.consume();
        final key = state.consumeIf(TokenType.key);
        if(key == null) {
          throw Exception("Key expected!");
        }
        accesses.add(MemberAccess(key.text));
      } else {
        break;
      }
    }

    return KeyChain(variable.text, accesses);
  }
}

class IdentifierValueParser {
  static VarUse parse(State state) {
    final variable = state.consumeIf(TokenType.identifier);
    if(variable == null) {
      throw Exception("Variable expected!");
    }

    final accesses = <Access>[];

    while(!state.done) {
      final next = state.peek();

      if(next.type == TokenType.dot) {
        state.consume();
        final key = state.consumeIf(TokenType.key);
        if(key == null) {
          throw Exception("Key expected!");
        }
        accesses.add(MemberAccess(key.text));
      } else if(next.type == TokenType.leftSquareBracket) {
        accesses.add(SubscriptParser.parse(state));
      } else {
        break;
      }
    }

    return VarUse(variable.text, accesses);
  }
}

class SubscriptParser {
  static SubscriptAccess parse(State state) {
    if(state.consumeIf(TokenType.leftSquareBracket) == null) {
      throw Exception("'[' expected in a subscript access");
    }

    // TODO could be expression
    final value = IntParser.parse(state);

    if(state.consumeIf(TokenType.rightSquareBracket) == null) {
      throw Exception("']' expected in a subscript access");
    }

    return SubscriptAccess(value);
  }
}

class ExpressionParser {
  static Expression parse(State state) {
    // TODO
  }
}