import 'dart:math';

import 'package:test/test.dart';

import '../lib/json.dart';

void main() {
  test('json', () {
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
