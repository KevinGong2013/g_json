library g_json;

import 'dart:convert';

class _JSONNilReason extends Error {
  final String message;

  _JSONNilReason.wrongType(dynamic key, bool map)
      : message =
            '${map ? 'Map($key)' : 'List($key)'} failure, It is not a ${map ? 'Map' : 'List'}';

  _JSONNilReason.notExist(String key)
      : message = 'Map($key) key does not exist.';

  _JSONNilReason.nullObject() : message = 'null object';

  _JSONNilReason.outOfBounds(int index)
      : message = 'List($index) Index is out of bounds.';

  _JSONNilReason(this.message);

  @override
  String toString() {
    return message;
  }
}

/// JSON type definitions.
///
/// See http://www.json.org
enum Type { string, number, bool, list, map, nil, unknown }

/// abstract json object
class JSON {
  dynamic _value;
  late Type _type;

  List<dynamic> _rawList = [];
  Map<String, dynamic> _rawMap = {};
  String _rawString = '';
  num _rawNum = 0;
  bool _rawBool = false;

  // 取值为空时的错误原因
  Error? error;

  /// JSON Type
  Type get rawJSONType => _type;

  // Object in json
  dynamic get value => _value;
  set value(dynamic newValue) {
    final unwrappedValue = _unwrap(newValue);
    if (unwrappedValue is String) {
      _type = Type.string;
      _rawString = unwrappedValue;
    } else if (unwrappedValue is int || unwrappedValue is num) {
      _type = Type.number;
      _rawNum = unwrappedValue;
    } else if (unwrappedValue is List) {
      _type = Type.list;
      _rawList = unwrappedValue;
    } else if (unwrappedValue is bool) {
      _type = Type.bool;
      _rawBool = unwrappedValue;
    } else if (unwrappedValue is Map) {
      _type = Type.map;
      _rawMap = Map.from(unwrappedValue);
    } else {
      _type = Type.unknown;
      error = _JSONNilReason('${unwrappedValue.toString()}');
    }
    _value = unwrappedValue;
    if (unwrappedValue == null) {
      _type = Type.nil;
      error = _JSONNilReason.nullObject();
    }
  }

  /// Optional num
  num? get number => _type == Type.number ? _rawNum : null;

  /// Non-optional num
  num get numberValue {
    switch (_type) {
      case Type.number:
        return _rawNum;
      case Type.string:
        return num.tryParse(_rawString) ?? 0;
      case Type.bool:
        return booleanValue ? 1 : 0;
      default:
        return 0;
    }
  }

  /// Optional int
  int? get integer => number?.toInt();

  /// Non-optional int
  int get integerValue => numberValue.toInt();

  /// Optional double
  double? get ddouble => number?.toDouble();

  /// Non-optional double
  double get ddoubleValue => _rawNum.toDouble();

  /// Optional string
  String? get string => _type == Type.string ? _rawString : null;

  /// Non-optional string
  String get stringValue {
    switch (_type) {
      case Type.string:
        return _rawString;
      case Type.number:
        return '$numberValue';
      case Type.bool:
        return '$booleanValue';
      default:
        return '';
    }
  }

  /// Optional bool
  bool? get boolean => _type == Type.bool ? _rawBool : null;

  /// Non-optional bool
  bool get booleanValue {
    switch (_type) {
      case Type.bool:
        return _rawBool;
      case Type.string:
        return ['true', 't', 'y', 'yes', '1']
            .where((element) => element.contains(_rawString.toLowerCase()))
            .isNotEmpty;
      case Type.number:
        return number?.toInt() == 1;
      default:
        return false;
    }
  }

  /// Optional [JSON]
  List<JSON>? get list => _type == Type.list
      ? List.unmodifiable(_rawList.map((i) => JSON(i)))
      : null;

  /// Non-optional [JSON]
  List<JSON> get listValue => list ?? List.unmodifiable([]);

  /// Optional [dynamic]
  List<dynamic>? get listObject =>
      _type == Type.list ? List.unmodifiable(_rawList) : null;

  /// Optional `<String, JSON>{}`
  Map<String, JSON>? get map => _type == Type.map
      ? Map<String, JSON>.unmodifiable(
          _rawMap.map((k, v) => MapEntry(k, JSON(v))))
      : null;

  /// Non-optional `<String, JSON>{}`
  Map<String, JSON> get mapValue => map ?? Map.unmodifiable({});

  /// Optional `<String, dynamic>{}`
  Map<String, dynamic>? get mapObject =>
      _type == Type.map ? Map<String, dynamic>.unmodifiable(_rawMap) : null;

  // JSON string
  String rawString() {
    return jsonEncode(_value);
  }

  String prettyString([String indent = ' ']) {
    final encoder = JsonEncoder.withIndent(indent);
    return _type == Type.nil ? error.toString() : encoder.convert(value);
  }

  @override
  String toString() {
    print('❌[JSON] Please use `rawString()` instead `toString()`');
    return rawString();
  }

  static JSON nil = JSON(null);

  /// Convenience method `type == Type.nil`
  bool get isNull => _type == Type.nil;

  /// if `key` is `String` & `type` is `map` return json whose object is `map[k]` , otherwise return `json.nil` with error.
  /// if `key` is `int` & `type` is `list` return json whose object is `list[k]`, otherwise return `json.nil` with error.
  /// if `key` is `List<String/int>` recursive aboves.
  JSON operator [](dynamic key) {
    var r = JSON.nil;
    if (key is String) {
      if (_type == Type.map) {
        final o = _rawMap[key];
        if (o == null) {
          r.error = _JSONNilReason.notExist(key);
        } else {
          return JSON(o);
        }
      } else {
        r.error = _JSONNilReason.wrongType(key, true);
      }
      return r;
    } else if (key is List) {
      return key.fold(this, (j, sk) => j[sk]);
    } else if (key is int) {
      if (_type == Type.list) {
        if (key < _rawList.length) {
          return JSON(_rawList[key]);
        } else {
          r.error = _JSONNilReason.outOfBounds(key);
        }
      }
      r.error = _JSONNilReason.wrongType(key, false);
      return r;
    }
    return r;
  }

  /// if `key` is `String` & `type` is `map` set map value
  /// if `key` is `int` & `type` is `list` set list value
  /// if `key` is `List<String/int>` recursive aboves.
  void operator []=(dynamic key, dynamic dNewValue) {
    final newValue = JSON(dNewValue);
    if (key is int &&
        _type == Type.list &&
        key < _rawList.length &&
        newValue.error == null) {
      value = _rawList..[key] = newValue.value;
    } else if (key is String && _type == Type.map) {
      if (newValue.error == null) {
        value = _rawMap..[key] = newValue.value;
      } else {
        value = _rawMap..remove(key);
      }
    } else if (key is List) {
      switch (key.length) {
        case 0:
          return;
        case 1:
          this[key[0]] = newValue;
          break;
        default:
          final path = List.from(key);
          path.removeAt(0);
          final nextJSON = this[key[0]];
          nextJSON[path] = newValue;
          this[key[0]] = nextJSON;
      }
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isAccessor) {
      final memberName = invocation.memberName.toString();
      // flutter does not support `import 'dart:mirrors'`
      // final memberName = MirrorSystem.getName(invocation.memberName);
      if (memberName.startsWith('Symbol("') && memberName.endsWith('")')) {
        final realName = memberName.substring(8, memberName.length - 2);
        if (invocation.isSetter) {
          // for setter real name looks like "prop=" so we remove the "="
          final name = realName.substring(0, realName.length - 1);
          this[name] = invocation.positionalArguments.first;
          return this;
        } else {
          return this[realName].value;
        }
      }
    }
    return super.noSuchMethod(invocation);
  }

  void remove(String key) {
    this[key] = null;
  }

  /// if `type` is `map` && contains this `key` return `true`, otherwise return `false`
  bool exist(String key) {
    if (_type != Type.map) return false;
    return _rawMap.containsKey(key);
  }

  String get _identifier {
    final bf = StringBuffer();
    switch (_type) {
      case Type.list:
        bf.write('[${listValue.map((j) => j._identifier).join(',')}]');
        break;
      case Type.map:
        final sortedKeys = mapValue.keys.toList(growable: false);
        sortedKeys.sort();
        bf.write(
            '{${sortedKeys.map((key) => '$key:${mapValue[key]!._identifier}').join(',')}}');
        break;
      default:
        bf.write(_value);
    }
    return bf.toString();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || _identifier == JSON(other)._identifier;
  }

  @override
  int get hashCode => _value.hashCode;

  /// Only support JSON types object.
  JSON(dynamic obj) {
    value = obj;
  }

  /// Parse json string as JSON object
  factory JSON.parse(String jsonStr) {
    if (jsonStr.isEmpty) {
      return JSON.nil;
    }
    return JSON(json.decode(jsonStr));
  }

  dynamic _unwrap(object) {
    if (object is JSON) {
      return _unwrap(object.value);
    } else if (object is List) {
      return object.map(_unwrap).toList();
    } else if (object is Map) {
      return object.map((k, v) => MapEntry(k, _unwrap(v)));
    } else {
      return object;
    }
  }
}

extension JSONIterable on JSON {
  Iterable<MapEntry<String, dynamic>>? get entries =>
      _type == Type.map ? _rawMap.entries : null;
}
