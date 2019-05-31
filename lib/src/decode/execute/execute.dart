import 'dart:math';
import 'package:don/parser.dart';
import 'package:don/src/decode/error/error.dart';

import '../ast/ast.dart';
import 'variables.dart';

dynamic execute(Unit unit) {
  final variables = Variables();

  for (String id in unit.variables.keys) {
    variables.variables[id] = _value(
        null,
        AssignOp.mkAssign(unit.variables[id].span),
        unit.variables[id],
        variables);
  }

  return _value(
      null, AssignOp.mkAssign(unit.value.span), unit.value, variables);
}

const _opMap = <TokenType, TokenType>{
  TokenType.addAssign: TokenType.plus,
  TokenType.subAssign: TokenType.minus,
  TokenType.mulAssign: TokenType.asterisk,
  TokenType.divAssign: TokenType.div,
  TokenType.modAssign: TokenType.mod,
  TokenType.powAssign: TokenType.pow,
  TokenType.orAssign: TokenType.or,
  TokenType.andAssign: TokenType.and,
  TokenType.xorAssign: TokenType.xor,
};

num _numOp(Operator op, num left, num right) {
  switch (op.token) {
    case TokenType.plus:
      return left + right;
    case TokenType.minus:
      return left - right;
    case TokenType.asterisk:
      return left * right;
    case TokenType.div:
      return left / right;
    case TokenType.mod:
      return left % right;
    case TokenType.pow:
      return pow(left, right);
    case TokenType.or:
      return left.toInt() | right.toInt();
    case TokenType.and:
      return left.toInt() & right.toInt();
    case TokenType.xor:
      return left.toInt() ^ right.toInt();
    default:
      throw SyntaxError(op.span, "Invalid operator");
  }
}

dynamic _expression(Expression exp, Variables variables) {
  dynamic left = _normalValue(exp.left, variables);
  dynamic right = _normalValue(exp.right, variables);

  if (left is num) {
    if (right is! num) {
      throw SyntaxError(exp.span, "Invalid operand ${right.type}");
    }

    final ret = _numOp(exp.op, left, right);
    return ret;
  }

  if (left is String) {
    if (right is String) {
      if (exp.op.token != TokenType.plus) {
        throw SyntaxError(exp.op.span, "Invalid operation");
      }
      return left + right;
    }
    if (right is int) {
      if (exp.op.token != TokenType.asterisk) {
        throw SyntaxError(exp.op.span, "Invalid operation");
      }
      return left * right;
    }
  }

  // TODO bool

  // TODO Date

  // TODO

  throw SyntaxError(exp.span, "Invalid expression");
}

dynamic _normalValue(Value value, Variables variables) {
  if (value is DateValue) return value.value;
  if (value is SimpleValue) return value.value;
  if (value is VarUse) return variables.get(value);
  if (value is Expression) {
    final ret = _expression(value, variables);
    return ret;
  }

  throw UnimplementedError("Unknown value type ${value?.runtimeType}");
}

dynamic _value(
    dynamic oldValue, AssignOp op, Value value, Variables variables) {
  if (op.isAssign || oldValue == null) {
    if (value is MapValue) return _map(oldValue, op, value, variables);
    if (value is ListValue) return _list(oldValue, op, value, variables);

    return _normalValue(value, variables);
  }

  if (oldValue is Map) {
    if (value is MapValue) {
      return _map(oldValue, op, value, variables);
    }
    if (value is VarUse) {
      final v = _normalValue(value, variables);
      if (!op.isAddAssign) {
        throw SyntaxError(value.span, "Invalid operator on Map");
      }
      if (v is Map) {
        oldValue.addAll(v);
        return oldValue;
      }
      throw SyntaxError(value.span, "Invalid assignment");
    }
    throw SyntaxError(value.span, "Invalid assignment");
  }
  if (oldValue is List) {
    if (value is ListValue) {
      return _list(oldValue, op, value, variables);
    }
    if (value is VarUse) {
      final v = _normalValue(value, variables);
      if (op.isAddAssign) {
        oldValue.add(v);
        return oldValue;
      }
      if (op.isMulAssign) {
        if (v is! List) {
          throw SyntaxError(value.span, "Target not List");
        }
        oldValue.addAll(v);
        return oldValue;
      }
      throw SyntaxError(value.span, "Invalid operation on List");
    }
    throw SyntaxError(value.span, "Invalid assignment");
  }

  final v = _normalValue(value, variables);

  if (oldValue is bool) {
    throw SyntaxError(op.span, "Operators are not supported on bool");
  }

  if (oldValue is num) {
    if (v is! num) {
      throw SyntaxError(value.span, "Invalid value");
    }
    final mathOp = _opMap[op.type];
    if (mathOp == null) {
      throw SyntaxError(op.span, "Invalid operator");
    }
    return _numOp(Operator(op.span, mathOp), oldValue, v);
  }

  if (oldValue is String) {
    if (v is String) {
      if (op.type != TokenType.addAssign) {
        throw SyntaxError(op.span, "Invalid operator");
      }
      return oldValue + v;
    }
    if (v is int) {
      if (op.type != TokenType.mulAssign) {
        throw SyntaxError(op.span, "Invalid operator");
      }
      return oldValue * v;
    }
    throw SyntaxError(value.span, "Invalid assignment");
  }

  // TODO date

  throw UnimplementedError("Unknown value type ${value?.runtimeType}");
}

Map _map(dynamic oldValue, AssignOp op, MapValue value, Variables variables) {
  if ((oldValue != null && oldValue is! Map) && !op.isAssign) {
    throw SyntaxError(value.span, "Incompatible operation");
  }
  final Map ret = oldValue == null ? {} : oldValue;

  for (MapEntryValue mapEntry in value.values) {
    if (mapEntry.key.accesses.isEmpty) {
      var old;
      if (ret.containsKey(mapEntry.key.identifier)) {
        old = ret[mapEntry.key.identifier];
      }
      final v = _value(old, mapEntry.op, mapEntry.value, variables);
      ret[mapEntry.key.identifier] = v;
    } else {
      var m;
      {
        Access next = mapEntry.key.accesses.first;
        final ov = ret[mapEntry.key.identifier];
        if (next is MemberAccess) {
          if (ov != null && ov is! Map) {
            throw SyntaxError(next.span, "Member access on non-Map value");
          }
          m = ov ?? {};
        } else if (next is SubscriptAccess) {
          if (ov != null && ov is! List) {
            throw SyntaxError(next.span, "Subscript access on non-List value");
          }
          m = ov ?? [];
        }
        ret[mapEntry.key.identifier] = m;
      }
      for (int i = 0; i < mapEntry.key.accesses.length - 1; i++) {
        Access next = mapEntry.key.accesses[i + 1];
        final cur = mapEntry.key.accesses[i];
        if (cur is MemberAccess) {
          final ov = m[cur.member];

          if (next is MemberAccess) {
            if (ov != null && ov is! Map) {
              throw SyntaxError(next.span, "Member access on non-Map value");
            }
            m = m[cur.member] = ov ?? {};
          } else if (next is SubscriptAccess) {
            if (ov != null && ov is! List) {
              throw SyntaxError(
                  next.span, "Subscript access on non-List value");
            }
            m = m[cur.member] = ov ?? [];
          }
        } else if (cur is SubscriptAccess) {
          int index;
          if (cur.index is IntValue) {
            index = (cur.index as IntValue).value;
          } else {
            throw SyntaxError(cur.index.span, "Unknown index type");
          }
          final ov = m[index];
          if (next is MemberAccess) {
            if (ov != null && ov is! Map) {
              throw SyntaxError(next.span, "Member access on non-Map value");
            }
            m = m[index] = ov ?? {};
          } else if (next is SubscriptAccess) {
            if (ov != null && ov is! List) {
              throw SyntaxError(
                  next.span, "Subscript access on non-List value");
            }
            m = m[index] = ov ?? [];
          }
        }
      }

      {
        final cur = mapEntry.key.accesses.last;
        if (cur is MemberAccess) {
          m[cur.member] =
              _value(m[cur.member], mapEntry.op, mapEntry.value, variables);
        } else if (cur is SubscriptAccess) {
          int index;
          if (cur.index is IntValue) {
            index = (cur.index as IntValue).value;
          } else {
            throw SyntaxError(cur.index.span, "Unknown index type");
          }
          m[index] = _value(m[index], mapEntry.op, mapEntry.value, variables);
        }
      }
    }
  }

  return ret;
}

List<dynamic> _list(
    List oldValue, AssignOp op, ListValue list, Variables variables) {
  if (!op.isAssign && !op.isAddAssign) {
    throw SyntaxError(list.span, "Incompatible operation");
  }

  if ((oldValue != null && oldValue is! List) && !op.isAssign) {
    throw SyntaxError(list.span, "Incompatible operation");
  }

  List ret = [];
  if (op.isAddAssign) {
    ret = oldValue ?? [];
  }

  for (Value value in list.values) {
    ret.add(_value(null, AssignOp.mkAssign(value.span), value, variables));
  }

  return ret;
}

/*
List<dynamic> _listAccess(List oldValue, int index) {
  if (oldValue == null) {
    if (index != 0) {
      throw Exception(
          "Index out of range. Only index '0' is accessible on undefined list");
    }
  }

  if (index >= oldValue.length) {
    throw Exception("Index out of range");
  }

  return oldValue[index];
}
 */

class Clone {
  static dynamic perform(final value) {
    if (value is Map) {
      return cloneMap(value);
    } else if (value is List) {
      return cloneList(value);
    }
    return value;
  }

  static Map cloneMap(Map map) {
    final ret = {};

    for (dynamic key in map.keys) {
      ret[perform(key)] = perform(map[key]);
    }

    return ret;
  }

  static List cloneList(List list) {
    final ret = []..length = list.length;

    for (int i = 0; i < list.length; i++) {
      ret[i] = perform(list[i]);
    }

    return ret;
  }
}
