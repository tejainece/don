import 'package:don/parser.dart';
import 'package:source_span/source_span.dart';
import '../scanner/scanner.dart';

part 'comment.dart';

abstract class AstNode {
  FileSpan get span;

  // TODO final List<Comment> comments;

  // TODO AstNode(this.span, this.comments);

  // visitor
}

class MapValue implements Value, AstNode {
  final FileSpan span;

  final List<MapEntryValue> values;

  MapValue(this.span, this.values);

  @override
  String toString() {
    final sb = StringBuffer('{');
    values.forEach((v) {
      sb.writeln(v);
    });
    sb.write('}');

    return sb.toString();
  }

  factory MapValue.empty() {
    return MapValue(null, []);
  }
}

class AssignOp implements AstNode {
  final FileSpan span;

  final TokenType type;

  AssignOp(this.span, this.type);

  factory AssignOp.fromToken(Token token) => AssignOp(token.span, token.type);

  AssignOp.mkAssign(this.span): type = TokenType.assign;

  bool get isAssign => type == TokenType.assign;

  bool get isAddAssign => type == TokenType.addAssign;

  bool get isMulAssign => type == TokenType.mulAssign;

  String toString() => type.toString();
}

class MapEntryValue implements AstNode {
  final FileSpan span;

  final KeyChain key;

  final Value value;

  final AssignOp op;

  MapEntryValue(this.span, this.key, this.value, this.op);

  String toString() => '$key: $value';
}

abstract class Value implements AstNode {}

abstract class SimpleValue<T> implements Value {
  T get value;
}

abstract class NumberValue<T extends num> implements SimpleValue<T> {}

class StringValue implements SimpleValue<String>, Value, AstNode {
  final FileSpan span;

  final String value;

  StringValue(this.span, this.value);

  @override
  String toString() => value;
}

class IntValue implements NumberValue<int>, Value, AstNode {
  final FileSpan span;

  final int value;

  IntValue(this.span, this.value);

  @override
  String toString() => value.toString();
}

class DoubleValue implements NumberValue<double>, Value, AstNode {
  final FileSpan span;

  final double value;

  DoubleValue(this.span, this.value);

  @override
  String toString() => value.toString();
}

class BoolValue implements SimpleValue<bool>, Value, AstNode {
  final FileSpan span;

  final bool value;

  BoolValue(this.span, this.value);

  @override
  String toString() => value.toString();
}

class ListValue implements Value, AstNode {
  final FileSpan span;

  final List<Value> values;

  ListValue(this.span, this.values);

  @override
  String toString() {
    final sb = StringBuffer('[');
    values.forEach((v) {
      sb.writeln(v);
    });
    sb.write(']');

    return sb.toString();
  }
}

class Let implements AstNode {
  final FileSpan span;

  final String name;

  final Value value;

  Let(this.span, this.name, this.value);
}

class Unit {
  final Map<String, Value> variables;

  final Value value;

  Unit(this.variables, this.value);

  @override
  String toString() {
    final sb = StringBuffer();

    sb.writeln(variables);

    sb.writeln(value);

    return sb.toString();
  }
}

class Expression implements Value {
  final FileSpan span;

  // TODO

  Expression(this.span);
}

abstract class Access implements AstNode {}

class SubscriptAccess implements Access {
  final FileSpan span;

  final Value index;

  SubscriptAccess(this.span, this.index);
}

class MemberAccess implements Access {
  final FileSpan span;

  final String member;

  MemberAccess(this.span, this.member);
}

class VarUse implements Value, AstNode {
  final FileSpan span;

  final String identifier;

  final List<Access> accesses;

  VarUse(this.span, this.identifier, this.accesses);

  factory VarUse.fromToken(Token token, List<Access> accesses) {
    return VarUse(token.span, token.text, accesses);
  }
}

class KeyChain implements Value, AstNode {
  final FileSpan span;

  final String identifier;

  final List<Access> accesses;

  KeyChain(this.span, this.identifier, this.accesses);

  factory KeyChain.fromToken(Token token, List<Access> accesses) {
    return KeyChain(token.span, token.text, accesses);
  }
}