# Dart Tips #

## Tips ##

Option 2: Create a factory constructor
Use Dart's factory keyword to create a factory constructor.

~~~dart
abstract class Shape {
  factory Shape(String type) {
    if (type == 'circle') return Circle(2);
    if (type == 'square') return Square(2);
    throw 'Can\'t create $type.';
  }
  num get area;
}

final circle = Shape('circle');
final square = Shape('square');
~~~

[dart-cheatsheet](https://dart.dev/codelabs/dart-cheatsheet)