import '../ast/ast.dart';

class Variables {
  final variables = <String, dynamic>{};

  dynamic get(VarUse use) {
    var data = variables[use.identifier];
    if (use.accesses.isEmpty) return data;

    for (Access access in use.accesses) {
      if (access is MemberAccess) {
        data = _getFromMap(data, access.member);
      } else if (access is SubscriptAccess) {
        final Value val = access.value;
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

    return data;
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
    variables.variables[id] = _value(unit.variables[id], variables);
  }

  return _value(unit.value, variables);
}

dynamic _value(Value value, Variables variables) {
  if (value is SimpleValue) return value.value;
  if (value is MapValue) return _map(value, variables);
  if (value is ListValue) return _list(value, variables);
  if (value is VarUse) {
    return variables.get(value);
  }
  throw UnimplementedError("Unknown value type ${value?.runtimeType}");
}

Map<String, dynamic> _map(MapValue value, Variables variables) {
  final ret = <String, dynamic>{};

  for (MapEntryValue mapEntry in value.values) {
    final v = _value(mapEntry.value, variables);
    if (mapEntry.key.accesses.isEmpty) {
      ret[mapEntry.key.identifier] = v;
    } else {
      var m = ret[mapEntry.key.identifier] = <String, dynamic>{};
      for (int i = 0; i < mapEntry.key.accesses.length - 1; i++) {
        final d = mapEntry.key.accesses[i];
        final nm = <String, dynamic>{};
        m = m[d.member] = nm;
      }
      m[mapEntry.key.accesses.last.member] = v;
    }
  }

  return ret;
}

List<dynamic> _list(ListValue list, Variables variables) {
  final ret = <dynamic>[];

  for (Value value in list.values) {
    ret.add(_value(value, variables));
  }

  return ret;
}
