
/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

class Lazy<T> {
  final T Function() thunk;
  T get value => this.thunk();
  Lazy(this.thunk);
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
  late final Lazy<T> _lazy;
  Parser(T Function() thunk) {
    this._lazy = Lazy(thunk);
  }

  T get force => this._lazy.value;

  Either<JsonParseException, T> get safe {
    late final T result;
    try {
      result = this.force;
      return Either.fromRight(result);
    } on JsonParseException catch (e) {
      return Either.fromLeft(e);
    }
  }

  // ... methods
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
