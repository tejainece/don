import 'dart:io';

import '../scanner/scanner.dart';
import '../ast/ast.dart';
import 'state.dart';
import 'package:don/src/decode/error/error.dart';
import 'package:source_span/source_span.dart';

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
      } else if (token.type == TokenType.comment) {
        _state.consume();
      } else {
        throw SyntaxError(token?.span, 'Invalid root clause');
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
      if (state.done) break;

      state.consumeMany(TokenType.newLine);

      if (state.peek()?.type != TokenType.key) break;
    }

    FileSpan span;

    if (values.isNotEmpty) {
      span = values.first.span.expand(values.last.span);
    } // TODO compute span if values are empty

    return MapValue(span, values);
  }
}

class MapParser {
  MapParser();

  static MapValue parse(State state) {
    final leftBracket = state.consumeIf(TokenType.leftCurlyBracket);
    if (leftBracket == null) {
      throw SyntaxError(state.peek()?.span, "Map value should start with '{'");
    }

    final values = MapBodyParser.parse(state);

    final rightBracket = state.consumeIf(TokenType.rightCurlyBracket);
    if (rightBracket == null) {
      throw SyntaxError(state.peek()?.span, "Map value should end with '}'");
    }

    return MapValue(leftBracket.span.expand(rightBracket.span), values.values);
  }
}

class MapEntryParser {
  static MapEntryValue parse(State state) {
    state.consumeMany(TokenType.newLine);

    final key = MapKeyParser.parse(state);

    final op = AssignOpParser.parse(state);
    if (op == null) {
      throw SyntaxError(state.peek()?.span, "Operator missing on Map entry");
    }

    final value = ValueParser.parse(state);
    return MapEntryValue(key.span.expand(value.span), key, value, op);
  }
}

class ValueParser {
  static Value parse(State state) {
    final value = state.peek();
    if (value.type == TokenType.integer) {
      state.consume();
      return IntValue(value.span, int.parse(value.text));
    } else if (value.type == TokenType.double) {
      state.consume();
      return DoubleValue(value.span, double.parse(value.text));
    } else if (value.type == TokenType.string) {
      state.consume();
      // TODO support multiple string literals
      return StringValue(
          value.span, value.text.substring(1, value.text.length - 1));
    } else if (value.type == TokenType.leftCurlyBracket) {
      return MapParser.parse(state);
    } else if (value.type == TokenType.leftSquareBracket) {
      return ListParser.parse(state);
    } else if (value.type == TokenType.true_) {
      state.consume();
      return BoolValue(value.span, true);
    } else if (value.type == TokenType.false_) {
      state.consume();
      return BoolValue(value.span, false);
    } else if (value.type == TokenType.identifier) {
      return IdentifierValueParser.parse(state);
    }
    throw SyntaxError(value?.span, "Unknown value");
  }
}

class IntParser {
  static IntValue parse(State state) {
    final value = state.consumeIf(TokenType.integer);
    if (value == null) {
      throw SyntaxError(state.peek()?.span, "Integer expected");
    }

    return IntValue(value.span, int.parse(value.text));
  }
}

class ListParser {
  static ListValue parse(State state) {
    final leftBracket = state.consumeIf(TokenType.leftSquareBracket);
    if (leftBracket == null) {
      throw SyntaxError(state.peek()?.span, "List value should start with '['");
    }

    state.consumeMany(TokenType.newLine);

    var rightBracket = state.consumeIf(TokenType.rightSquareBracket);
    if (rightBracket != null) {
      return ListValue(leftBracket.span.expand(rightBracket.span), []);
    }

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

    rightBracket = state.consumeIf(TokenType.rightSquareBracket);
    if (rightBracket == null) {
      throw SyntaxError(state.peek()?.span, "List value should end with ']'");
    }

    return ListValue(leftBracket.span.expand(rightBracket.span), values);
  }
}

class LetParser {
  static Let parse(State state) {
    final let = state.consumeIf(TokenType.let);
    if (let == null) {
      throw SyntaxError(state.peek()?.span, "'let' expected");
    }

    final identifier = state.consumeIf(TokenType.identifier);
    if (identifier == null) {
      throw SyntaxError(state.peek()?.span ?? let.span,
          "Identifier missing in 'let' statement");
    }

    if (state.consumeIf(TokenType.assign) == null) {
      throw SyntaxError(state.peek()?.span ?? let.span,
          "Assign operator ':' missing in 'let' statement");
    }

    final value = ValueParser.parse(state);

    return Let(let.span.expand(value.span), identifier.text, value);
  }
}
