import 'package:don/parser.dart';
import 'package:source_span/source_span.dart';
import '../scanner/scanner.dart';

part 'comment.dart';
part 'value.dart';

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

  @override
  String get type => "Map";
}

class AssignOp implements AstNode {
  final FileSpan span;

  final TokenType type;

  AssignOp(this.span, this.type);

  factory AssignOp.fromToken(Token token) => AssignOp(token.span, token.type);

  AssignOp.mkAssign(this.span) : type = TokenType.assign;

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

  @override
  String get type => "List";
}

class Identifier implements AstNode {
  final FileSpan span;

  final String name;

  Identifier(this.span, this.name);
}

class Let implements AstNode {
  final FileSpan span;

  final Identifier name;

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

  final Value left;

  final Operator op;

  final Value right;

  final bool isParenthesized;

  Expression(this.span, this.left, this.op, this.right,
      {this.isParenthesized: false});

  String toString() {
    return "($left $op $right)";
  }

  @override
  String get type => "Expression";
}

class Operator implements AstNode {
  final FileSpan span;

  final TokenType token;

  Operator(this.span, this.token);

  factory Operator.fromToken(Token token) {
    return Operator(token.span, token.type);
  }

  bool get isAdd => token == TokenType.plus;

  bool get isSubtract => token == TokenType.minus;

  bool get isTimes => token == TokenType.asterisk;

  bool get isDiv => token == TokenType.div;

  bool get isMod => token == TokenType.mod;

  bool get isPow => token == TokenType.pow;

  bool get isOr => token == TokenType.bitwiseOr;

  bool get isAnd => token == TokenType.bitwiseAnd;

  bool get isXor => token == TokenType.bitwiseXor;

  @override
  String toString() {
    return token.toString();
  }
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

  @override
  String get type => "VarSuubstitution";
}

class KeyChain implements Value, AstNode {
  final FileSpan span;

  final StartKey startKey;

  final List<Access> accesses;

  KeyChain(this.span, this.startKey, this.accesses);

  factory KeyChain.fromToken(Token token, List<Access> accesses) {
    return KeyChain(token.span, StartKey.fromToken(token), accesses);
  }

  String get identifier => startKey.name;

  @override
  String get type => "KeySubstitution";
}

class StartKey implements AstNode {
  final FileSpan span;

  final String name;

  StartKey(this.span, this.name);

  factory StartKey.fromToken(Token token) => StartKey(token.span, token.text);
}
