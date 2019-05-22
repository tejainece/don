import 'package:don/parser.dart';
import 'package:don/src/decode/error/error.dart';
import '../ast/ast.dart';

class Variables {
  final variables = <String, dynamic>{};

  dynamic get(VarUse use) {
    var data = variables[use.identifier];
    if (use.accesses.isEmpty) return Clone.perform(data);

    for (Access access in use.accesses) {
      if (access is MemberAccess) {
        data = _getFromMap(data, access.member, access);
      } else if (access is SubscriptAccess) {
        final Value val = access.index;
        // TODO handle expression
        if (val is IntValue) {
          data = _getFromList(data, val.value, access);
        } else {
          throw SyntaxError(val.span, "Incompatible value");
        }
      } else {
        throw SyntaxError(access.span, "Unknown access clause");
      }
    }

    return Clone.perform(data);
  }

  dynamic _getFromMap(dynamic data, String key, MemberAccess access) {
    if (data == null) {
      throw SyntaxError(access.span, "Accessing non-existant value");
    }
    if (data is! Map) throw SyntaxError(access.span, "Data is not Map");
    return data[key];
  }

  dynamic _getFromList(dynamic data, int key, SubscriptAccess access) {
    if (data == null) {
      throw SyntaxError(access.span, "Accessing non-existant value");
    }
    if (data is! List) throw SyntaxError(access.span, "Data is not List");
    if (data.length <= key) {
      throw SyntaxError(access.index.span, "Index out of range");
    }
    return data[key];
  }
}
