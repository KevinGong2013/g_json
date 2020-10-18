# json  [![Pub Package](https://img.shields.io/pub/v/g_json)](https://pub.dev/packages/g_json)

json package spirit by SwiftyJSON.

# Example

``` dart

// 0x00 import package
import 'package:g_json/g_json.dart';

...

void someMethod() {

  final jsonStr = '''
  {
    "_id": "5f0fd54e54044a55385a0f31",
    "name": {
      "first": "Coleman",
      "last": "Evans"
    },
    "range": [0, 1, 2, 3, 4, 5, 6,7, 8, 9],
    "friends": [
      {
        "id": 0,
        "name": "Gibson Hull"
      },
      {
        "id": 1,
        "name": "Dunlap Bush"
      },
      {
        "id": 2,
        "name": "Bette Herman"
      }
    ]
  }
  ''';

  // 0x01 parse json string to object
  final mode = JSON.parse(jsonStr);

  final _id = mode['_id'].stringValue;

  final secondFriend = mode[['friends', 2]]['name'].stringValue;

  print(mode.prettyString());
}

```

### Initialization

``` dart
import 'package:json/json.dart';

final model = JSON(jsonMap);
// or
final model = JSON.parse(jsonString);

```

### Subscript

``` dart

// Getting a string from a JSON Array
final name = json[0].stringValue;

```

``` dart
// Getting an array of string from a JSON Array
final names = json.arrayValue.map((j) => j['name'].stringValue)
```

``` dart
// Getting a string using a path to the element
final path = [1, 'list', 2, 'name'];
final name = json[path].string;
// or
final name = json[[1, 'list', 2, 'name']].string;
// Just the same
final name = json[1]['list'][2]['name'].string;

```

### Error

``` dart

final json = JSON(['name', 'age']);
final name = json[3].string;
if (name != null) {
  // Do something you want
} else {
  print(json[3].error); // List(3) Index is out of bounds.
}

```

``` dart

final json = JSON({'name': name, 'age': 20});
final address = json['address'].string;
if (address != null) {
  // Do something you want
} else {
  print(json['address'].error); // "Map["address"] does not exist"
}

```

``` dart

final json = JSON.nil;

print(json[0]); // List(0) failure, It is not a List
print(json[0].error); // List(0) failure, It is not a List

print(json['key']); // Map(key) failure, It is not a Map
print(json['key'].error); // Map(key) failure, It is not a Map

```

### Optional getter

``` dart
// num
final count = json['user']['favourites_count'].num;
if (count != null) {
  // DO something
} else {
  print(json['user']['favourites_count'].error);
}

// String
final name = json['user']['favourites_name'].string;
if (name != null) {
  // DO something
} else {
  print(json['user']['favourites_name'].error);
}

// Bool
final isTranslator = json['user']['is_translator'].bool;
if (isTranslator != null) {
  // DO something
} else {
  print(json['user']['is_translator'].error);
}

...

```

### Non-optional getter

Non=optional getter is named `xxxValue`

``` dart

// if not a Number or nil, return 0
int id = json['id'].integerValue;

// if not a string or nil, return ''
String name = json['name'].stringValue;

// if not a list or nil return []
List<JSON> list  = json['list'].listValue;

// if not a map or nil, return {}
Map<String, JSON> map = json['map'].mapValue;

```

### Setter

``` dart

json['name'] = 'G_JSON';
json[0] = 1;

```

### Raw object && convert to jsonString

``` dart

// raw
final value = json.value;

// json string
final jsonString = json.rawString();

```

### Dynamic member

``` dart

dynamic person = JSON({'name': 'kevin', 'language': 'dart'});

person.name = 'icey';
person.language = 'Swift';


print(person.rawString()); // {"name": "icey", "language": "swift"}

```