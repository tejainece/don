import '../scanner/scanner.dart';
import '../ast/ast.dart';
import 'state.dart';

part 'member.dart';
part 'set.dart';

class Parser {
  State _state;

  Parser(Scanner scanner) {
    _state = State(scanner);
  }

  Unit parse() {
    final variables = <String, Value>{};
    Value value;

    while (!_state.done) {
      _state.consumeMany(TokenType.newLine);

      final token = _state.peek();

      if (token.type == TokenType.key) {
        value = MapBodyParser.parse(_state);
      } else if (token.type == TokenType.leftSquareBracket) {
        value = ListParser.parse(_state);
      } else if (token.type == TokenType.let) {
        final Let let = LetParser.parse(_state);
        variables[let.name] = let.value;
      } else if (token.type == TokenType.set) {
        throw UnimplementedError("Set expression not implemented yet");
        // final Let let = SetPar.parse(_state);
        // variables[let.name] = let.value;
      } else if (token.type == TokenType.comment) {
        _state.consume();
      } else {
        throw Exception('Invalid root clause!');
      }
    }

    return Unit(variables, value);
  }
}

class MapBodyParser {
  static MapValue parse(State state) {
    final values = <MapEntryValue>[];

    state.consumeMany(TokenType.newLine);

    while (!state.done) {
      final value = MapEntryParser.parse(state);
      values.add(value);

      // Separator
      if (state.done) return MapValue(values);

      state.consumeMany(TokenType.newLine);

      if (state.peek()?.type != TokenType.key) break;
    }

    return MapValue(values);
  }
}

class MapParser {
  MapParser();

  static MapValue parse(State state) {
    if (state.consumeIf(TokenType.leftCurlyBracket) == null) {
      throw Exception("Map value should start with '{'");
    }

    final values = MapBodyParser.parse(state);

    if (state.consumeIf(TokenType.rightCurlyBracket) == null) {
      throw Exception("Map value should end with '}'");
    }

    return values;
  }
}

class MapEntryParser {
  static MapEntryValue parse(State state) {
    state.consumeMany(TokenType.newLine);

    final key = MapKeyParser.parse(state);

    if (state.consumeIf(TokenType.colon) == null) {
      throw Exception("Map entry must contain operator");
    }

    final value = ValueParser.parse(state);
    return MapEntryValue(key, value);
  }
}

class ValueParser {
  static Value parse(State state) {
    final value = state.peek();
    if (value.type == TokenType.integer) {
      state.consume();
      return IntValue(int.parse(value.text));
    } else if (value.type == TokenType.double) {
      state.consume();
      return DoubleValue(double.parse(value.text));
    } else if (value.type == TokenType.string) {
      state.consume();
      return StringValue(value.text.substring(1, value.text.length-1));
    } else if (value.type == TokenType.leftCurlyBracket) {
      return MapParser.parse(state);
    } else if (value.type == TokenType.leftSquareBracket) {
      return ListParser.parse(state);
    } else if (value.type == TokenType.true_) {
      state.consume();
      return BoolValue(true);
    } else if (value.type == TokenType.false_) {
      state.consume();
      return BoolValue(false);
    } else if (value.type == TokenType.identifier) {
      return IdentifierValueParser.parse(state);
    }
    throw UnimplementedError("Unknown value");
  }
}

class IntParser {
  static IntValue parse(State state) {
    final value = state.consumeIf(TokenType.integer);
    if (value == null) {
      throw Exception("Integer expected!");
    }

    return IntValue(int.parse(value.text));
  }
}

class ListParser {
  static ListValue parse(State state) {
    if (state.consumeIf(TokenType.leftSquareBracket) == null) {
      throw Exception("List value should start with '['");
    }

    state.consumeMany(TokenType.newLine);

    bool rawMap = false;
    if (state.peek().type == TokenType.key) rawMap = true;

    bool angles = false;
    if (state.peek().type == TokenType.rightAngleBracket) {
      angles = true;
      rawMap = true;
    }

    final values = <Value>[];

    while (!state.done) {
      if (angles) {
        if (state.consumeIf(TokenType.rightAngleBracket) == null) break;
      }

      Value value;
      if (!rawMap) {
        value = ValueParser.parse(state);
      } else {
        value = MapBodyParser.parse(state);
      }
      values.add(value);

      state.consumeMany(TokenType.newLine);

      if (!angles) {
        if (state.nextToken(TokenType.comma) == null) break;
      }

      state.consumeMany(TokenType.newLine);

      if (state.peek().type == TokenType.rightSquareBracket) break;
    }

    state.consumeMany(TokenType.newLine);

    if (state.consumeIf(TokenType.rightSquareBracket) == null) {
      throw Exception("List value should end with ']'");
    }

    return ListValue(values);
  }
}

class LetParser {
  static Let parse(State state) {
    if (state.consumeIf(TokenType.let) == null) {
      throw Exception("'let' expected");
    }

    final identifier = state.consumeIf(TokenType.identifier);

    state.consumeIf(TokenType.equal);

    final value = ValueParser.parse(state);

    return Let(identifier.text, value);
  }
}
