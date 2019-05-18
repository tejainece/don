import 'scanner/scanner.dart';
import 'parser/parser.dart';
import 'execute/execute.dart';

dynamic decode(String data) {
  final scanner = Scanner(data, sourceUrl: null);
  scanner.scan();
  if(scanner.errors.isNotEmpty) {
    throw scanner.errors;
  }

  final value = Parser(scanner).parse();

  return execute(value);
}

/*
Stream<dynamic> decodeStream(String data) {
  // TODO
}
 */