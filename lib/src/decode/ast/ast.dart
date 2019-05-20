import 'package:source_span/source_span.dart';
import '../scanner/scanner.dart';

part 'comment.dart';

abstract class AstNode {
  // TODO final FileSpan span;

  // TODO final List<Comment> comments;

  // TODO AstNode(this.span, this.comments);

  // visitor
}

class MapValue implements Value, AstNode {
  final List<MapEntryValue> values;

  MapValue(this.values);

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
    return MapValue([]);
  }
}

class AssignOp {
  final int id;

  final String rep;

  final String name;

  const AssignOp._(this.id, this.name, this.rep);

  bool get isAssign => this == assign;

  bool get isAddAssign => this == addAssign;

  bool get isMulAssign => this == mulAssign;

  static const assign = AssignOp._(0, '=', 'Equal');

  static const addAssign = AssignOp._(1, '+=', 'Add assign');

  static const mulAssign = AssignOp._(2, '*=', 'Multiply assign');
}

class MapEntryValue implements AstNode {
  final KeyChain key;

  final Value value;

  final AssignOp op;

  MapEntryValue(this.key, this.value, {this.op = AssignOp.assign});

  String toString() => '$key: $value';
}

abstract class Value implements AstNode {}

abstract class SimpleValue<T> implements Value {
  T get value;
}

abstract class NumberValue<T extends num> implements SimpleValue<T> {}

class StringValue implements SimpleValue<String>, Value, AstNode {
  final String value;

  StringValue(this.value);

  @override
  String toString() => value;
}

class IntValue implements NumberValue<int>, Value, AstNode {
  final int value;

  IntValue(this.value);

  @override
  String toString() => value.toString();
}

class DoubleValue implements NumberValue<double>, Value, AstNode {
  final double value;

  DoubleValue(this.value);

  @override
  String toString() => value.toString();
}

class BoolValue implements SimpleValue<bool>, Value, AstNode {
  final bool value;

  BoolValue(this.value);

  @override
  String toString() => value.toString();
}

class ListValue implements Value, AstNode {
  final List<Value> values;

  ListValue(this.values);

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
  final String name;

  final Value value;

  Let(this.name, this.value);
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
  // TODO
}

abstract class Access implements AstNode {

}

class SubscriptAccess implements Access {
  final Value index;

  SubscriptAccess(this.index);
}

class MemberAccess implements Access {
  final String member;

  MemberAccess(this.member);
}

class VarUse implements Value, AstNode {
  final String identifier;

  final List<Access> accesses;

  VarUse(this.identifier, this.accesses);
}

class KeyChain implements Value, AstNode {
  final String identifier;

  final List<Access> accesses;

  KeyChain(this.identifier, this.accesses);
}