import 'package:flutter_test/flutter_test.dart';

import 'package:json/json.dart';

void main() {
  test('value convert correct', () {
    final j = JSON({
      "int": 1,
      "double": 2,
      "num": 3,
      "list": [1, 2],
      "map": {"a": "a", "b": "b"}
    });
    expect(j["int"].integer, 1);
    expect(j["double"].ddouble, 2);
    expect(j["num"].number, 3);
  });
}
