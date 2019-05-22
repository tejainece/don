import 'dart:io';
import 'dart:convert';

import 'package:don/don.dart';
import 'package:test/test.dart';

void main() {
  group('List', () {

    setUp(() {
    });

    test('Int list', () async {
      final inputStr = await File("test_data/list/int.don").readAsString();
      final value = decode(inputStr);
      // print(JsonEncoder.withIndent('  ').convert(value));
      final compare = json.decode(await File("test_data/list/int.json").readAsString());
      expect(value, equals(compare));
    });

    test('Concise list', () async {
      final inputStr = await File("test_data/list/concise.don").readAsString();
      final value = decode(inputStr);
      final compare = json.decode(await File("test_data/list/concise.json").readAsString());
      expect(value, equals(compare));
    });

    test('Nested list', () async {
      final inputStr = await File("test_data/list/nested.don").readAsString();
      final value = decode(inputStr);
      // print(JsonEncoder.withIndent('  ').convert(value));
      final compare = json.decode(await File("test_data/list/nested.json").readAsString());
      expect(value, equals(compare));
    });

    test('Arrow list', () async {
      final inputStr = await File("test_data/list/arrow.don").readAsString();
      final value = decode(inputStr);
      // print(JsonEncoder.withIndent('  ').convert(value));
      final compare = json.decode(await File("test_data/list/arrow.json").readAsString());
      expect(value, equals(compare));
    });
  });
}
