import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('GameMapLevel', () {
    final events = <SoundEvent>[];
    final game = Game('BoxMapLevel.coordinates')..sounds.listen(events.add);
    setUp(() async {
      await Future<void>.delayed(Duration(milliseconds: 1));
      events.clear();
    });
    test('Initialisation', () {
      final map = BoxMap(
          name: 'Test Map',
          boxes: [Box('Only box', Point(0, 0), Point(9, 9), Surface())]);
      final level = BoxMapLevel(game, map);
      expect(level.boxMap, equals(map));
      expect(level.coordinates, equals(map.initialCoordinates));
      expect(level.heading, equals(map.initialHeading));
      expect(level.width, equals(map.boxes.first.width));
      expect(level.height, equals(map.boxes.first.height));
      expect(level.tileAt(0, 0), equals(map.boxes.first));
      expect(level.tileAtPoint(map.boxes.last.end), equals(map.boxes.first));
    });
    test('Multiple boxes', () {
      final westField =
          Box('West Field', Point(0, 0), Point(10, 20), Surface());
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
    test('.coordinates', () async {
      final level = BoxMapLevel(game, BoxMap(name: game.title, boxes: []));
      expect(level.coordinates, equals(level.boxMap.initialCoordinates));
      await Future<void>.delayed(Duration(milliseconds: 1));
      events.clear();
      level.coordinates = Point(1.0, 2.0);
      expect(level.coordinates, equals(Point(1.0, 2.0)));
      await Future<void>.delayed(Duration(milliseconds: 1));
      expect(events.length, equals(1));
      var event = events.last as ListenerPositionEvent;
      expect(event.x, equals(level.coordinates.x));
      expect(event.y, equals(level.coordinates.y));
      expect(event.z, isZero);
      expect(event.id, isNull);
      level.coordinates = Point(5.0, 10.0);
      expect(level.coordinates, equals(Point(5.0, 10.0)));
      await Future<void>.delayed(Duration(milliseconds: 1));
      expect(events.length, equals(2));
      event = events.last as ListenerPositionEvent;
      expect(event.x, equals(level.coordinates.x));
      expect(event.y, equals(level.coordinates.y));
      expect(event.z, isZero);
      expect(event.id, isNull);
    });
    test('.heading', () async {
      final level =
          BoxMapLevel(game, BoxMap(name: 'BoxMap.heading', boxes: []));
      expect(level.heading, equals(level.boxMap.initialHeading));
      level.heading = 45.0;
      expect(level.heading, equals(45));
      await Future<void>.delayed(Duration(milliseconds: 1));
      expect(events.length, equals(1));
      final event = events.last as ListenerOrientationEvent;
      expect(event.x1, equals(sin(level.heading * pi / 180)));
      expect(event.y1, equals(cos(level.heading * pi / 180)));
      expect(event.z1, isZero);
      expect(event.x2, isZero);
      expect(event.y2, isZero);
      expect(event.z2, equals(1));
    });
    test('.tileAt', () {
      final box1 = Box('Box 1', Point(0, 0), Point(3, 3), Surface());
      final box2 = Box('Box 2', box1.cornerSe + Point(1, 0),
          box1.end + Point(1, 0), Surface());
      final box3 = Box('Box 3', box2.cornerSe + Point(2, 0),
          box2.end + Point(4, 0), Surface());
      final boxMap =
          BoxMap(name: 'BoxMapLevel.tileAt', boxes: [box1, box2, box3]);
      final level = BoxMapLevel(game, boxMap);
      expect(level.tileAt(box1.start.x, box1.start.y), equals(box1));
      expect(level.tileAt(box1.centre.x.floor(), box1.centre.y.floor()),
          equals(box1));
      expect(level.tileAt(box1.end.x, box1.end.y), equals(box1));
      expect(level.tileAt(box2.start.x, box2.start.y), equals(box2));
      expect(level.tileAt(box2.centre.x.floor(), box2.centre.y.floor()),
          equals(box2));
      expect(level.tileAt(box2.end.x, box2.end.y), equals(box2));
      expect(level.tileAt(box3.start.x, box3.start.y), equals(box3));
      expect(level.tileAt(box3.centre.x.floor(), box3.centre.y.floor()),
          equals(box3));
      expect(level.tileAt(box3.end.x, box3.end.y), equals(box3));
      expect(level.tileAt(box2.cornerSe.x + 1, box2.end.y), isNull);
    });
  });
}
