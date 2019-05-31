import 'dart:io';
import 'package:don/don.dart';

main() async {
  final oomlName = 'test_data/primitive/date.don';

  final string = await File(oomlName).readAsString();

  print(decode(string));
}
