import 'dart:io';
import 'dart:convert';

import 'package:don/don.dart';
import 'package:test/test.dart';

void main() {
  group('Encode', () {
    setUp(() {});

    test('Int list', () async {
      final input =
          json.decode(await File("test_data/list/int.json").readAsString());
      final enc = encode(input);
      print(enc);
      final compare = decode(enc);
      expect(input, equals(compare));
    });

    test('Concise list', () async {
      final input =
          json.decode(await File("test_data/list/concise.json").readAsString());
      final enc = encode(input);
      print(enc);
      final compare = decode(enc);
      expect(input, equals(compare));
    });

    test('Nested list', () async {
      final input =
          json.decode(await File("test_data/list/nested.json").readAsString());
      final enc = encode(input);
      print(enc);
      final compare = decode(enc);
      expect(input, equals(compare));
    });

    test('Arrow list', () async {
      final input =
          json.decode(await File("test_data/list/arrow.json").readAsString());
      final enc = encode(input);
      print(enc);
      final compare = decode(enc);
      expect(input, equals(compare));
    });
  });
}
