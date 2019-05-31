import 'package:source_span/source_span.dart';
import 'package:don/src/decode/ast/ast.dart';
import 'package:don/src/decode/error/error.dart';

AnalyzerResult analyze(Unit unit) {
  return _Analyzer(unit).analyze();
}

class AnalyzerResult {
  final Map<String, Let> variables;

  final List<SyntaxError> errors;

  AnalyzerResult(this.variables, this.errors);
}

class _Analyzer {
  final Unit unit;

  final variables = <String, Let>{};

  final errors = <SyntaxError>[];

  _Analyzer(this.unit);

  AnalyzerResult analyze() {
    // Analyze variables
    for (String id in unit.variables.keys) {
      final value = unit.variables[id];

      // TODO analyze variable declaration
    }

    // TODO analyze value clauses
  }

  void analyzeVariable(Let variable) {
    if(variables.containsKey(variable.name)) {
      errors.add(SyntaxError(variable.name.span, "Variable already defined"));
    }
    // TODO make sure
  }

  void analyzeValue(Value value) {
    if(value is SimpleValue) {
      // TODO
      return;
    }
    if(value is SimpleValue) {
      return;
    }
    if(value is MapValue) {
      analyzeMap(value);
    }
    if(value is ListValue) {
      analyzeList(value);
    }
    if(value is VarUse) {
      // TODO
    }
    throw UnsupportedError("Unknown value type");
  }

  void analyzeMap(MapValue value) {
    for(MapEntryValue entry in value.values) {
      analyzeValue(entry.value);
    }
  }

  void analyzeList(ListValue value) {
    for(ListValue entry in value.values) {
      analyzeValue(entry);
    }
  }
}