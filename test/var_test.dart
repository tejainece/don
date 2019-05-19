import 'dart:io';
import 'dart:convert';

import 'package:don/don.dart';
import 'package:test/test.dart';

void main() {
  group('Variable', () {

    setUp(() {
    });

    test('Simple', () async {
      final inputStr = await File("test_data/var/var.don").readAsString();
      final value = decode(inputStr);
      // print(JsonEncoder.withIndent('  ').convert(value));
      final compare = json.decode(await File("test_data/var/var.json").readAsString());
      expect(value, equals(compare));
    });

    test('KeyChain', () async {
      final inputStr = await File("test_data/var/mod.don").readAsString();
      final value = decode(inputStr);
      print(JsonEncoder.withIndent('  ').convert(value));
      // final compare = json.decode(await File("test_data/var/var.json").readAsString());
      // expect(value, equals(compare));
    });

    test('List mod', () async {
      final inputStr = await File("test_data/var/list_mod.don").readAsString();
      final value = decode(inputStr);
      print(JsonEncoder.withIndent('  ').convert(value));
      // final compare = json.decode(await File("test_data/var/var.json").readAsString());
      // expect(value, equals(compare));
    });
  });
}
