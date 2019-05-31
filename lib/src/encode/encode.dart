/// Encodes the given [model] into don
String encode(dynamic model,
    {bool root = true, int level = 0, String indent = '  '}) {
  if (model == null) return "";

  if (model is Map) {
    return encodeMap(model, level: level, indent: indent, root: root);
  }
  if (model is List) return encodeList(model, level: level, indent: indent);
  if (model is num) return "$model";
  if (model is String) return "'$model'";
  if (model is bool) return "$model";
  if (model is DateTime) return "@'${model.toIso8601String()}'";

  throw UnsupportedError("Unencodable type ${model.runtimeType}");
}

/// Encodes the given [model] into don
String encodeMap(Map model,
    {bool root = false, int level = 0, String indent = '  '}) {
  final sb = StringBuffer();

  if (!root) sb.writeln("{");

  for (dynamic key in model.keys) {
    if (key is! String) {
      throw Exception("Only string keys are allowed");
    }

    if (!root) sb.write(indent * (level + 1));
    sb.write(key);
    sb.write(" = ");
    sb.writeln(
        encode(model[key], indent: indent, level: level + 1, root: false));
  }

  if (!root) {
    sb.write(indent * level);
    sb.write("}");
  }

  return sb.toString();
}

/// Encodes the given [model] into don
String encodeList(List model, {int level = 0, String indent = '  '}) {
  final sb = StringBuffer();

  if (model.isEmpty) return "[]";

  sb.writeln("[");

  for (dynamic value in model) {
    sb.write(indent * (level + 1));
    sb.write(encode(value, indent: indent, level: level + 1, root: false));
    sb.writeln(",");
  }

  sb.write(indent * level);
  sb.write("]");

  return sb.toString();
}
