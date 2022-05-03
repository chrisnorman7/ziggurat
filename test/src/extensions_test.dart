import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group(
    'Point<double>',
    () {
      test(
        '.angleBetween',
        () {
          const origin = Point(0.0, 0.0);
          expect(origin.angleBetween(const Point(0.0, 1.0)), 0.0);
          expect(origin.angleBetween(const Point(1.0, 1.0)), 45.0);
          expect(origin.angleBetween(const Point(1.0, 0.0)), 90.0);
          expect(origin.angleBetween(const Point(1, -1)), 135.0);
          expect(origin.angleBetween(const Point(0, -1)), 180.0);
          expect(origin.angleBetween(const Point(-1, -1)), 225.0);
          expect(origin.angleBetween(const Point(-1, 0)), 270.0);
          expect(origin.angleBetween(const Point(-1, 1)), 315.0);
        },
      );
    },
  );
}
