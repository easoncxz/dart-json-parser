
/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

class Either<A, B> {
  final A? left;
  final B? right;

  Either._(this.left, this.right);

  factory Either.fromLeft(A left) {
    return Either._(left, null);
  }

  factory Either.fromRight(B right) {
    return Either._(null, right);
  }

  C match<C>({
    required C Function(A l) onLeft,
    required C Function(B r) onRight,
  }) {
    final left = this.left;
    final right = this.right;
    if (left != null) {
      return onLeft(left);
    } else if (right != null) {
      return onRight(right);
    } else {
      throw AssertionError('Either(null, null)');
    }
  }

  String toString() =>
      this.match(
          onLeft: (left) => 'Left<${A}>(${left})',
          onRight: (right) => 'Right<${B}>(${right})',
      );
}

class JsonParseException extends FormatException {
  final String msg;
  JsonParseException(this.msg): super(msg);
}

class Parser<T> {
  final T Function() _thunk;

  Parser(this._thunk);

  factory Parser.pure(T value) =>
      Parser(() => value);

  T force() => this._thunk();

  Either<JsonParseException, T> safe() {
    late final T result;
    try {
      result = this.force();
      return Either.fromRight(result);
    } on JsonParseException catch (e) {
      return Either.fromLeft(e);
    }
  }
}

Parser<int> parseInt(dynamic v) {
  if (v is int) {
    return Parser(() => v);
  } else {
    return Parser(() {
      throw JsonParseException('Expected int, got ${v.runtimeType}: ${v}');
    });
  }
}

Parser<String> parseString(dynamic v) {
  if (v is String) {
    return Parser(() => v);
  } else {
    return Parser(() {
      throw JsonParseException('Expected String, got ${v.runtimeType}: ${v}');
    });
  }
}

Parser<List<T>> parseArray<T>(Parser<T> Function(dynamic _) parseItem, dynamic v) {
  if (v is List) {
    return Parser(() {
      final List<T> acc = [];
      for (final e in v) {
        acc.add(parseItem(e).force());
      }
      return acc;
    });
  } else {
    throw JsonParseException('Expected List, got ${v.runtimeType}: ${v}');
  }
}

typedef JsonObject = Map<String, dynamic>;

Parser<T> withObject<T>(dynamic v, Parser<T> Function(JsonObject o) parseObject) {
  return Parser(() {
    if (v is JsonObject) {
      return parseObject(v).force();
    } else {
      throw JsonParseException('Expecting object, got ${v.runtimeType}: ${v}');
    }
  });
}

Parser<T> parseField<T>(JsonObject o, String key, Parser<T> Function(dynamic _) parseValue) {
  if (o.containsKey(key)) {
    return parseValue(o[key]);
  } else {
    throw JsonParseException('Expected to find key ${key} in object: ${o}');
  }
}

