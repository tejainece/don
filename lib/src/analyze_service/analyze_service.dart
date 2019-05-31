import 'package:don/parser.dart';
import 'package:don/src/decode/scanner/scanner.dart';
import 'package:don/src/decode/parser/parser.dart';

class AnalyzerService {
  String _uri;

  String get uri => _uri;

  set uri(String newValue) {
    _uri = newValue;
    // TODO
  }

  Future<void> _analyzeText(String content) async {
    final scanner = Scanner(content, sourceUrl: uri);
    //TODO report scanner errors
    final parser = Parser(scanner);
    // TODO report parser error
    // TODO

  }

  // TODO
}