import 'dart:io';
import 'dart:convert';

import 'package:don/don.dart';
import 'package:test/test.dart';

void main() {
  group('Primitive', () {
    setUp(() {});

    test('Date', () async {
      final inputStr =
          await File("test_data/primitive/date.don").readAsString();
      final value = decode(inputStr);
      print(value);
      /*
      // print(JsonEncoder.withIndent('  ').convert(value));
      final compare =
          json.decode(await File("test_data/list/int.json").readAsString());
      expect(value, equals(compare));
       */
    });

    test('Multiline string', () async {
      final inputStr =
      await File("test_data/primitive/multiline_string.don").readAsString();
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
