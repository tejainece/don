import '../ast/ast.dart';

class Variables {
  final variables = <String, dynamic>{};

  dynamic get(VarUse use) {
    var data = variables[use.identifier];
    if (use.accesses.isEmpty) return Clone.perform(data);

    for (Access access in use.accesses) {
      if (access is MemberAccess) {
        data = _getFromMap(data, access.member);
      } else if (access is SubscriptAccess) {
        final Value val = access.index;
        // TODO handle expression
        if (val is IntValue) {
          data = _getFromList(data, val.value);
        } else {
          throw UnsupportedError("Cannot handle ${val.runtimeType}");
        }
      } else {
        throw Exception("Unknown access clause");
      }
    }

    return Clone.perform(data);
  }

  dynamic _getFromMap(dynamic data, String key) {
    if (data == null) throw Exception("Accessing non-existant value");
    if (data is! Map) throw Exception("Data is not Map");
    return data[key];
  }

  dynamic _getFromList(dynamic data, int key) {
    if (data == null) throw Exception("Accessing non-existant value");
    if (data is! List) throw Exception("Data is not List");
    if (data.length <= key) {
      throw Exception("Index out of range");
    }
    return data[key];
  }
}

dynamic execute(Unit unit) {
  final variables = Variables();

  for (String id in unit.variables.keys) {
    variables.variables[id] =
        _value(null, AssignOp.assign, unit.variables[id], variables);
  }

  return _value(null, AssignOp.assign, unit.value, variables);
}

dynamic _value(
    dynamic oldValue, AssignOp op, Value value, Variables variables) {
  if (op.isAssign || oldValue == null) {
    if (value is SimpleValue) return value.value;
    if (value is MapValue) {
      return _map(oldValue, op, value, variables);
    }
    if (value is ListValue) {
      return _list(oldValue, op, value, variables);
    }
    if (value is VarUse) {
      return variables.get(value);
    }
    throw UnimplementedError("Unknown value type ${value?.runtimeType}");
  }

  if (oldValue is bool) {
    throw UnsupportedError("Operators are not supported on bool");
  }

  if (value is VarUse) {
    final v = variables.get(value);
    if (v == null) {
      throw Exception("Variable not found");
    }

    if (oldValue is Map) {
      if (!op.isAddAssign) {
        throw Exception("Invalid operator on Map");
      }
      if (v is Map) {
        oldValue.addAll(v);
        return oldValue;
      }
      throw Exception("Invalid assignment");
    }

    if (oldValue is List) {
      if (v == null) {
        throw Exception("Variable not found");
      }
      if (op.isAddAssign) {
        oldValue.add(v);
        return oldValue;
      }
      if (op.isMulAssign) {
        if (v is! List) {
          throw Exception("Target not List");
        }
        oldValue.addAll(v);
        return oldValue;
      }
      throw Exception("Invalid operation on List");
    }
  }

  if (oldValue is Map) {
    if (value is! MapValue) {
      throw Exception("Invalid assignment");
    }
    return _map(oldValue, op, value, variables);
  }
  if (oldValue is List) {
    if (value is! ListValue) {
      throw Exception("Invalid assignment");
    }
    return _list(oldValue, op, value, variables);
  }

  if (oldValue is num) {
    if (value is NumberValue) {
      return oldValue + value.value;
    }
    throw Exception("Invalid assignment");
  }

  if (oldValue is String) {
    if (value is StringValue) {
      return oldValue + value.value;
    }
    throw Exception("Invalid assignment");
  }

  throw UnimplementedError("Unknown value type ${value?.runtimeType}");
}

Map _map(dynamic oldValue, AssignOp op, MapValue value, Variables variables) {
  if ((oldValue != null && oldValue is! Map) && op != AssignOp.assign) {
    throw Exception("Cannot modify Map with non Map");
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
            throw Exception("Member access on non-Map value");
          }
          m = ov ?? {};
        } else if (next is SubscriptAccess) {
          if (ov != null && ov is! List) {
            throw Exception("Subscript access on non-List value");
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
              throw Exception("Member access on non-Map value");
            }
            m = m[cur.member] = ov ?? {};
          } else if (next is SubscriptAccess) {
            if (ov != null && ov is! List) {
              throw Exception("Subscript access on non-List value");
            }
            m = m[cur.member] = ov ?? [];
          }
        } else if (cur is SubscriptAccess) {
          int index;
          if (cur.index is IntValue) {
            index = (cur.index as IntValue).value;
          } else {
            throw Exception("Unknown index type");
          }
          final ov = m[index];
          if (next is MemberAccess) {
            if (ov != null && ov is! Map) {
              throw Exception("Member access on non-Map value");
            }
            m = m[index] = ov ?? {};
          } else if (next is SubscriptAccess) {
            if (ov != null && ov is! List) {
              throw Exception("Subscript access on non-List value");
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
            throw Exception("Unknown index type");
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
  if ((oldValue != null && oldValue is! List) && op != AssignOp.assign) {
    throw Exception("Cannot modify List with non list");
  }

  final ret = oldValue == null ? [] : oldValue;

  for (Value value in list.values) {
    ret.add(_value(null, AssignOp.assign, value,
        variables)); // TODO how to do assign thing?
  }

  return ret;
}

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
