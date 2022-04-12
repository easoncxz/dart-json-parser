import 'dart:convert' as Convert;
import 'package:json_parser/json_parser.dart' as P;

void main() {
  final decoder = Convert.JsonDecoder();
  final j = '{ "pierre": "yes" }';
  print('StringAndInt: ${P.parseStringAndInt(decoder.convert(j)).safe()}');
}
