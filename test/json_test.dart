import 'package:test/test.dart';
// ignore: avoid_relative_lib_imports
import '../lib/g_json.dart';

void main() {
  test('[error] json', () {
    final json = JSON.nil;
    expect(json[0].error.toString(), 'List(0) failure, It is not a List');
    expect(json['address'].error.toString(), 'Map(address) failure, It is not a Map');
  });
  test('[dynamic member] json', () {
    dynamic j = JSON({'a': 1, 'b': 2});
    j.a = -1;
    assert(j.a == -1);
  });
  test('[iterable] json', () {
    final j2 = JSON({'a': 1, 'b': 2, 'c': 3}).entries;
    for (final j in j2) {
      print(j.toString());
    }
  });
  test('[equal] json', () {
    final j1 = JSON(0);
    final j2 = j1;
    assert(j1 == j2);

    final j3 = JSON(0);
    assert(j3 == j1);

    final j4 = JSON(1);
    assert(j4 != j3);
  });
  test('[setter] json', () {
    final j1 = JSON({'a': 1, 'b': 2});
    j1['a'] = 2;

    expect(2, j1['a'].integerValue);

    final j2 = JSON([1, 2, 3, 4, 5]);
    j2[0] = 0;
    expect(0, j2[0].integerValue);

    final j3 = JSON({
      'a': {
        'b': [
          {
            'c': [1, 2, 3, 4]
          }
        ]
      }
    });
    final path = ['a', 'b', 0, 'c', 3];
    j3[path] = -1;
    expect(-1, j3[path].integerValue);
  });
  test('[getter] json', () {
    final j1 = JSON(3);

    expect('3', j1.stringValue);
    expect(false, j1.booleanValue);
    expect(3, j1.numberValue);

    final j2 = JSON(true);

    expect('true', j2.stringValue);
    expect(1, j2.numberValue);
    expect(true, JSON(1).booleanValue);
    expect(true, j2.booleanValue);

    final j3 = JSON('3');
    expect('3', j3.stringValue);
    expect(false, j3.booleanValue);
    expect(3, j3.numberValue);

    final j4 = JSON.parse('[1,2,3,4]');
    final j5 = JSON(j4.listValue);

    expect(4, j5.listValue.length);
    expect(1, j5.listObject.first);

    final j6 = JSON.parse('{"a": 1, "b": "2"}');
    final j7 = JSON(j6.map);

    expect(2, j7.mapObject.length);
    expect(1, j7['a'].integerValue);

    final j8 = JSON({
      'a': {
        'b': [
          {
            'c': [1, 2, 3, 4]
          }
        ]
      }
    });

    expect(3, j8[['a', 'b', 0, 'c', 2]].integerValue);
  });
}
