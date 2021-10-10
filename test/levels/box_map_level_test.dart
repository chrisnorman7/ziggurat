import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('GameMapLevel', () {
    final game = Game('GameMapLevel');
    test('Initialisation', () {
      final map = BoxMap(
          name: 'Test Map',
          boxes: [Box('Only box', Point(0, 0), Point(9, 9), Surface())]);
      final level = BoxMapLevel(game, map);
      expect(level.boxMap, equals(map));
      expect(level.width, equals(map.boxes.first.width));
      expect(level.height, equals(map.boxes.first.height));
      expect(level.tileAt(0, 0), equals(map.boxes.first));
      expect(level.tileAtPoint(map.boxes.last.end), equals(map.boxes.first));
    });
    test('Multiple boxes', () {
      final westField =
          Box('East Field', Point(0, 0), Point(10, 20), Surface());
      final path = Box('Path', westField.cornerSe + Point(1, 0),
          westField.end + Point(5, 0), Surface());
      final eastField = Box('West Field', path.cornerSe + Point(1, 0),
          path.end + Point(westField.width, 0), Surface());
      final map =
          BoxMap(name: 'Multiple boxes', boxes: [westField, path, eastField]);
      final level = BoxMapLevel(game, map);
      expect(level.tileAt(0, 0), equals(westField));
      expect(level.tileAtPoint(eastField.end), equals(eastField));
    });
  });
}
