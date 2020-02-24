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
  });
}
