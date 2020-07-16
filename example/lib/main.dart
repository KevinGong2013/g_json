import '../../lib/g_json.dart';

main(List<String> args) {
  
  final jsonStr = '''
  {
    "_id": "5f0fd54e54044a55385a0f31",
    "name": {
      "first": "Coleman",
      "last": "Evans"
    },
    "range": [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9
    ],
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

  final j = JSON.parse(jsonStr);

  final _id = j['_id'].stringValue;
  print('_id: $_id');

  final lastName = j[['name', 'last']].stringValue;
  print('name.last: $lastName');

  final r3 = j['range'][3].number ?? -1;
  print('range:3 $r3');

  final friends = j['friends'].listValue;
  print('friends: $friends');

  final value = j.value;
  print('value: $value');

  print('---------------------');
  ////
  ///
  final nj = JSON({'a': 'a', 'b': 1});

  print(nj.rawString());
}
