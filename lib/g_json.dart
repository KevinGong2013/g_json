library g_json;

import 'dart:collection';
import 'dart:convert';

class _JSONNilReason extends Error {
  final String message;

  _JSONNilReason.wrongType() : message = 'wrong type';

  _JSONNilReason.notExist() : message = 'Dictionary key does not exist.';

  _JSONNilReason.nullObject() : message = 'null object';

  _JSONNilReason.outOfBounds() : message = 'Array Index is out of bounds.';

  _JSONNilReason(this.message);
}

/// JSON's type definitions.
///
/// See http://www.json.org
enum Type { string, number, bool, list, map, nil, unknown }

/// Abstrct json object
class JSON {
  dynamic _value;
  Type _type;

  List<dynamic> _rawList = [];
  Map<String, dynamic> _rawMap = {};
  String _rawString = '';
  num _rawNum = 0;
  bool _rawBool = false;

  // 取值为空时的错误原因
  Error error;

  /// JSON Type
  Type get type => _type;

  // Object in json
  dynamic get value => _value;

  /// Optional num
  num get number => type == Type.number ? _rawNum : null;

  /// Non-optional num
  num get numberValue {
    switch (type) {
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
  int get integer => number == null ? null : number.toInt();

  /// Non-optional int
  int get integerValue => numberValue.toInt();

  /// Optional double
  double get ddouble => number == null ? null : number.toDouble();

  /// Non-optional double
  double get ddoubleValue => _rawNum.toDouble();

  /// Optional string
  String get string => type == Type.string ? _rawString : null;

  /// Non-optional string
  String get stringValue {
    switch (type) {
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
  bool get boolean => type == Type.bool ? _rawBool : null;

  /// Non-optional bool
  bool get booleanValue {
    switch (type) {
      case Type.bool:
        return _rawBool ?? false;
      case Type.string:
        return ['true', 'y', 't', 'yes', '1'].where((element) => element.contains(_rawString.toLowerCase())).isNotEmpty;
      case Type.number:
        return number.toInt() == 1;
      default:
        return false;
    }
  }

  /// Optional [JSON]
  UnmodifiableListView<JSON> get list => type == Type.list ? UnmodifiableListView<JSON>(_rawList.map((i) => JSON(i))) : null;

  /// Non-optional [JSON]
  UnmodifiableListView<JSON> get listValue => list ?? UnmodifiableListView([]);

  /// Optional [dynamic]
  UnmodifiableListView<dynamic> get listObject => type == Type.list ? UnmodifiableListView<dynamic>(_rawList) : null;

  /// Optional `<String, JSON>{}`
  UnmodifiableMapView<String, JSON> get map =>
      type == Type.map ? UnmodifiableMapView<String, JSON>(_rawMap.map((k, v) => MapEntry(k, JSON(v)))) : null;

  /// Non-optional `<String, JSON>{}`
  UnmodifiableMapView<String, JSON> get mapValue => map ?? UnmodifiableMapView({});

  /// Optional `<String, dynamic>{}`
  UnmodifiableMapView<String, dynamic> get mapObject => type == Type.map ? UnmodifiableMapView<String, dynamic>(_rawMap) : null;

  // JSON string
  String rawString() {
    return jsonEncode(_value);
  }

  @override
  String toString() {
    return rawString();
  }

  static JSON nil = JSON(null);

  /// Convernice method `type == Type.nil`
  bool get isNull => type == Type.nil;

  /// if `key` is `String` & `type` is `map` return json whose object is `map[k]` , otherwise return `json.nil` with error.
  /// if `key` is `int` & `type` is `list` return json whose object is `list[k]`, otherwise return `json.nil` with error.
  /// if `key` is `List<String/int>` recursive aboves.
  JSON operator [](dynamic key) {
    var r = JSON.nil;
    if (key is String) {
      if (type == Type.map) {
        final o = _rawMap[key];
        if (o == null) {
          r.error = _JSONNilReason.notExist();
        } else {
          return JSON(o);
        }
      } else {
        r.error = _JSONNilReason.wrongType();
      }
      return r;
    } else if (key is List) {
      return key.fold(this, (j, sk) => j[sk]);
    } else if (key is int) {
      if (type == Type.list) {
        if (key < _rawList.length) {
          return JSON(_rawList[key]);
        } else {
          r.error = _JSONNilReason.outOfBounds();
        }
      }
      return r;
    }
    return r;
  }

  /// if `key` is `String` & `type` is `map` set map value
  /// if `key` is `int` & `type` is `list` set list value
  /// if `key` is `List<String/int>` recursive aboves.
  void operator []=(dynamic key, dynamic dNewValue) {
    final newValue = JSON(dNewValue);
    if (key is int && type == Type.list && key < _rawList.length && newValue.error == null) {
      _rawList[key] = newValue.value;
      _value = _rawList;
    } else if (key is String && type == Type.map && newValue.error == null) {
      _rawMap[key] = newValue.value;
      _value = _rawMap;
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
  bool operator ==(Object other) {
    return identical(this, other) || (other is JSON && type == other.type && value == other.value);
  }

  @override
  int get hashCode => _value.hashCode;

  /// Only support JSON types object.
  JSON(dynamic value) {
    value = _unwrap(value);
    if (value is String) {
      _type = Type.string;
      _rawString = value;
    } else if (value is int || value is num) {
      _type = Type.number;
      _rawNum = value;
    } else if (value is List) {
      _type = Type.list;
      _rawList = value;
    } else if (value is bool) {
      _type = Type.bool;
      _rawBool = value;
    } else if (value is Map) {
      _type = Type.map;
      _rawMap = Map.from(value);
    } else {
      _type = Type.unknown;
      error = _JSONNilReason('${value.toString()}');
    }
    _value = value;
    if (value == null) {
      _type = Type.nil;
      error = _JSONNilReason.nullObject();
    }
  }

  /// Parse json string as JSON object
  factory JSON.parse(String jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
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
