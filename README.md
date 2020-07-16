# json

json package spirit by SwiftyJSON.

# Example

``` dart
import 'package:json/json.dart';

void someFunc() {

  final model = JSON.parse('{"name": "Demo", "value": 2}')

  final name = model['name'].stringValue
  // OR
  final name = model['name'].string ?? 'default_name'
}

```