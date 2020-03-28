library json;

import 'dart:collection';
import 'dart:convert';

enum Type { number, string, bool, list, map, nil, unknown }

class JSONNilReason extends Error {
  final String message;

  JSONNilReason.wrongType() : message = 'wrong type';

  JSONNilReason.notExist() : message = 'Dictionary key does not exist.';

  JSONNilReason.nullObject() : message = 'null object';

  JSONNilReason.outOfBounds() : message = 'Array Index is out of bounds.';

  JSONNilReason(this.message);
}

class JSON {
  dynamic _value;
  Type type;

  List<dynamic> _rawList = [];
  Map<String, dynamic> _rawMap = {};
  String _rawString = "";
  num _rawNum = 0;
  bool _rawBool = false;

  // 取值为空时的错误原因
  JSONNilReason error;

  // 原始值
  dynamic get value => _value;

  // num
  num get number => type == Type.number ? _rawNum : null;

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

  // int
  int get integer => number == null ? null : number.toInt();

  int get integerValue => numberValue.toInt();

  // double
  double get ddouble => number == null ? null : number.toDouble();

  double get ddoubleValue => _rawNum.toDouble();

  // string
  String get string => type == Type.string ? _rawString : null;

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

  // bool
  bool get boolean => type == Type.bool ? _rawBool : null;

  bool get booleanValue {
    switch (type) {
      case Type.bool:
        return _rawBool ?? false;
      case Type.string:
        return ['true', 'y', 't', 'yes', '1']
            .where((element) => element.contains(_rawString.toLowerCase()))
            .isNotEmpty;
      case Type.number:
        return number.toInt() == 1;
      default:
        return false;
    }
  }

  UnmodifiableListView<JSON> get list => type == Type.list
      ? UnmodifiableListView<JSON>(_rawList.map((i) => JSON(i)))
      : null;

  UnmodifiableListView<JSON> get listValue => list ?? UnmodifiableListView([]);

  UnmodifiableListView<dynamic> get listObject =>
      type == Type.list ? UnmodifiableListView<dynamic>(_rawList) : null;

  UnmodifiableMapView<String, JSON> get map => type == Type.map
      ? UnmodifiableMapView<String, JSON>(
          _rawMap.map((k, v) => MapEntry(k, JSON(v))))
      : null;

  UnmodifiableMapView<String, JSON> get mapValue =>
      map ?? UnmodifiableMapView({});

  UnmodifiableMapView<String, dynamic> get mapObject =>
      type == Type.map ? UnmodifiableMapView<String, dynamic>(_rawMap) : null;

  // json 字符串
  String rawString() {
    return jsonEncode(_value);
  }

  @override
  String toString() {
    return rawString();
  }

  static JSON nil = JSON(null);

  bool get isNull => type == Type.nil;

  JSON operator [](dynamic k) {
    var r = JSON.nil;
    if (k is String) {
      if (type == Type.map) {
        final o = _rawMap[k];
        if (o == null) {
          r.error = JSONNilReason.notExist();
        } else {
          return JSON(o);
        }
      } else {
        r.error = JSONNilReason.wrongType();
      }
      return r;
    } else if (k is List) {
      return k.fold(this, (j, sk) => j[sk]);
    } else if (k is int) {
      if (type == Type.list) {
        if (k < _rawList.length) {
          return JSON(this._rawList[k]);
        } else {
          r.error = JSONNilReason.outOfBounds();
        }
      }
      return r;
    }
    return r;
  }

  JSON(dynamic value) {
    value = _unwrap(value);
    if (value is String) {
      type = Type.string;
      _rawString = value;
    } else if (value is int || value is num) {
      type = Type.number;
      _rawNum = value;
    } else if (value is List) {
      type = Type.list;
      _rawList = value;
    } else if (value is bool) {
      type = Type.bool;
      _rawBool = value;
    } else if (value is Map) {
      type = Type.map;
      _rawMap = Map.from(value);
    } else {
      type = Type.unknown;
      error = JSONNilReason('${value.toString()}');
    }
    _value = value;
    if (value == null) {
      type = Type.nil;
      error = JSONNilReason.nullObject();
    }
  }

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
