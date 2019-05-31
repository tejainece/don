import 'dart:io';
import 'dart:convert';

import 'package:don/don.dart';
import 'package:test/test.dart';

void main() {
  group('Expression', () {
    setUp(() {});

    test('Simple', () async {
      final inputStr =
      await File("test_data/expression/simple.don").readAsString();
      final value = decode(inputStr);
      print(value);
      /*
      // print(JsonEncoder.withIndent('  ').convert(value));
      final compare =
          json.decode(await File("test_data/list/int.json").readAsString());
      expect(value, equals(compare));
       */
    });
  });
}
