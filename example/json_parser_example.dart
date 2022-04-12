import 'dart:convert' as C;
import 'package:json_parser/json_parser.dart' as P;

// Part of your application domain
class StringAndInt {
  final String s;
  final int i;
  StringAndInt(this.s, this.i);
}

// Definitive source of how to deserialise
P.Parser<StringAndInt> parseStringAndInt(dynamic v) =>
  P.withObject(v, (o) =>
    P.Parser.pure(StringAndInt(
      P.parseField(o, 'str-foobar', P.parseString).force(),
      P.parseField(o, 'int67', P.parseInt).force(),
    ))
  );

void main() {
  final decoder = C.JsonDecoder();
  final j = '{ "str-foobar": 5 }';
  print('StringAndInt: ${parseStringAndInt(decoder.convert(j)).safe()}');
}
