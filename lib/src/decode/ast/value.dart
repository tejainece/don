part of 'ast.dart';

abstract class Value implements AstNode {
  String get type;
}

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

  @override
  String get type => "String";
}

class IntValue implements NumberValue<int>, Value, AstNode {
  final FileSpan span;

  final int value;

  IntValue(this.span, this.value);

  @override
  String toString() => value.toString();

  @override
  String get type => "Int";
}

class DoubleValue implements NumberValue<double>, Value, AstNode {
  final FileSpan span;

  final double value;

  DoubleValue(this.span, this.value);

  @override
  String toString() => value.toString();

  @override
  String get type => "Double";
}

class BoolValue implements SimpleValue<bool>, Value, AstNode {
  final FileSpan span;

  final bool value;

  BoolValue(this.span, this.value);

  @override
  String toString() => value.toString();

  @override
  String get type => "Bool";
}

class DateValue implements SimpleValue<DateTime>, Value, AstNode {
  final FileSpan span;

  final String rep;

  DateValue(this.span, this.rep);

  DateTime get value {
    final r = rep.substring(2, rep.length - 1);
    return DateTime.tryParse(r);
  }

  @override
  String toString() => value?.toIso8601String();

  @override
  String get type => "Date";
}
