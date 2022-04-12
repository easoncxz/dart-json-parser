<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

Compile-time-checked runtime-type-safety during JSON deserialisation

## Features

Safely convert a `dynamic`-typed value returned from `dart:convert` /
[`JsonDecoder`](https://api.dart.dev/stable/2.16.2/dart-convert/JsonDecoder-class.html)
/ `#convert` into a value of a type in your application domain. If your parser
compiles, there should be no runtime type-errors thrown during
deserialisation.

You need to write parsers for your domain type using this library. See example
below for what you need to do.

## Getting started

You can use this library straight from Github here. In your `pubspec.yaml`:

```yaml
dependencies:
  json_parser:
    git: https://github.com/easoncxz/dart-json-parser
```

Then, anywhere in your code (but probably close to your domain models or
serialisation logic):

```dart
import 'package:json_parser/json_parser.dart' as P;
```

## Usage

The example in `example/` is executable. Copied here:

```dart
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
```

To run this example yourself:

```
$ dart run example/json_parser_example.dart
```

Expected standard output:

```
is null: Left<JsonParseException>(FormatException: Expecting object, got Null: null)
wrong top-level type: Left<JsonParseException>(FormatException: Expecting object, got int: 3)
missing key: Left<JsonParseException>(FormatException: Expected to find key str-foobar in object: {irrelevant: 5})
wrong type at value: Left<JsonParseException>(FormatException: Expected String, got int: 100)
ok: Right<StringAndInt>(StringAndInt(something, 1))
```

## Additional information

### Motivation

I implemented this library mostly for fun, but also because I was looking for
an equivalent library to this one, but I couldn't find it.

### Inspiration

First and foremost, the idea of these combinators come from the Haskell
ecosystem, in particular from the [Aeson][aeson] library for JSON parsing and
formatting. Secondarily, the existance of the great project [`io-ts`][io-ts] in
the TypeScript ecosystem gives me confidence that such a type-safe parser could
probably be written in even some languages that lean towards object-oriented
programming a bit more.

[aeson]: https://hackage.haskell.org/package/aeson
[io-ts]: https://github.com/gcanti/io-ts
