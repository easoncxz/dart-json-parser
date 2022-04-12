import 'dart:convert' as C;
import 'package:json_parser/json_parser.dart' as P;

// Part of your application domain
class StringAndInt {
  final String s;
  final int i;
  StringAndInt(this.s, this.i);
  String toString() =>
      'StringAndInt(${this.s}, ${this.i})';
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
  print('is null: ${parseStringAndInt(decoder.convert('null')).safe()}');
  print('wrong top-level type: ${parseStringAndInt(decoder.convert('3')).safe()}');
  print('missing key: ${parseStringAndInt(decoder.convert('{ "irrelevant": 5 }')).safe()}');
  print('wrong type at value: ${parseStringAndInt(decoder.convert('{ "str-foobar": 100 }')).safe()}');
  print('ok: ${parseStringAndInt(decoder.convert('{ "str-foobar": "something", "int67": 1 }')).safe()}');
}
