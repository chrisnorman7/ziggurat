import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('TileMapLevel', () {
    final game = Game('TileMapLevel tests');
    test('Initialise', () {
      final tile1 = Tile(
          coordinates: Point(0, 0),
          ambiance: AssetReference.file('Ambiance1.wav'));
      final tile2 = Tile(
          coordinates: Point(3, 3),
          ambiance: AssetReference.file('ambiance2.wav'));
      final tileMap = TileMap(tiles: [tile1, tile2], width: 10, height: 10);
      final tileMapLevel = TileMapLevel(game: game, tileMap: tileMap);
      expect(tileMapLevel.tileMap, equals(tileMap));
      expect(tileMapLevel.coordinates, equals(tileMap.start));
      expect(tileMapLevel.ambiances.length, equals(2));
      var ambiance = tileMapLevel.ambiances.first;
      expect(ambiance.sound, equals(tile1.ambiance));
      expect(ambiance.gain, equals(tile1.ambianceGain));
      expect(ambiance.position, equals(tile1.coordinates));
      ambiance = tileMapLevel.ambiances.last;
      expect(ambiance.sound, equals(tile2.ambiance));
      expect(ambiance.gain, equals(tile2.ambianceGain));
      expect(ambiance.position, equals(tile2.coordinates));
    });
    test('.tileAt', () {
      final tile1 = Tile(coordinates: Point(1, 2));
      final tile2 = Tile(coordinates: Point(3, 4));
      final tile3 = Tile(coordinates: Point(5, 6));
      final tileMap =
          TileMap(tiles: [tile1, tile2, tile3], width: 10, height: 10);
      final level = TileMapLevel(game: game, tileMap: tileMap);
      expect(level.tileAt(Point(0, 0)), isNull);
      expect(level.tileAt(Point(1, 1)), isNull);
      expect(level.tileAt(tile1.coordinates), equals(tile1));
      expect(level.tileAt(tile2.coordinates), equals(tile2));
      expect(level.tileAt(tile3.coordinates), equals(tile3));
    });
    test('.coordinates', () async {
      final game = Game('TileMapLevel.coordinates');
      final events = <SoundEvent>[];
      game.sounds.listen(events.add);
      await Future<void>.delayed(Duration(milliseconds: 10));
      events.clear();
      final tileMap = TileMap(tiles: [], width: 10, height: 10);
      final level = TileMapLevel(game: game, tileMap: tileMap);
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(level.coordinates, equals(tileMap.start));
      expect(events, isEmpty);
      events.clear();
      var coordinates = Point(3.5, 6.7);
      level.coordinates = coordinates;
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(level.coordinates, equals(coordinates));
      expect(events.length, equals(1));
      var event = events.first;
      expect(event, isA<ListenerPositionEvent>());
      event as ListenerPositionEvent;
      expect(event.x, equals(coordinates.x));
      expect(event.y, equals(coordinates.y));
      expect(event.z, isZero);
      coordinates = Point(9.5, 4.8);
      level.coordinates = coordinates;
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(level.coordinates, equals(coordinates));
      expect(events.length, equals(2));
      event = events.last as ListenerPositionEvent;
      expect(event.x, equals(coordinates.x));
      expect(event.y, equals(coordinates.y));
      expect(event.z, isZero);
    });
    test('.heading', () async {
      final game = Game('TileMapLevel.heading');
      final events = <SoundEvent>[];
      game.sounds.listen(events.add);
      await Future<void>.delayed(Duration(milliseconds: 10));
      events.clear();
      final level = TileMapLevel(
          game: game, tileMap: TileMap(tiles: [], width: 10, height: 10));
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(level.heading, isZero);
      expect(events, isEmpty);
      level.heading = 45.0;
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(level.heading, equals(45.0));
      expect(events.length, equals(1));
      var event = events.first as ListenerOrientationEvent;
      var orientation = ListenerOrientationEvent.fromAngle(45.0);
      expect(event.x1, equals(orientation.x1));
      expect(event.x2, equals(orientation.x2));
      expect(event.y1, equals(orientation.y1));
      expect(event.y2, equals(orientation.y2));
      expect(event.z1, equals(orientation.z1));
      expect(event.z2, equals(orientation.z2));
      level.heading = 180.0;
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(events.length, equals(2));
      event = events.last as ListenerOrientationEvent;
      orientation = ListenerOrientationEvent.fromAngle(180.0);
      expect(event.x1, equals(orientation.x1));
      expect(event.x2, equals(orientation.x2));
      expect(event.y1, equals(orientation.y1));
      expect(event.y2, equals(orientation.y2));
      expect(event.z1, equals(orientation.z1));
      expect(event.z2, equals(orientation.z2));
    });
    test('.onPush', () async {
      final game = Game('TileMapLevel.onPush');
      final events = <SoundEvent>[];
      game.sounds.listen(events.add);
      await Future<void>.delayed(Duration(milliseconds: 10));
      events.clear();
      final coordinates = Point<double>(3.0, 4.0);
      final level = TileMapLevel(
          game: game,
          tileMap: TileMap(tiles: [], width: 10, height: 10),
          coordinates: coordinates,
          heading: 90.0);
      expect(level.coordinates, equals(coordinates));
      expect(level.heading, equals(90.0));
      game.pushLevel(level);
      await Future<void>.delayed(Duration(milliseconds: 10));
      expect(events.length, equals(2));
      expect(events.first, isA<ListenerOrientationEvent>());
      expect(events.last, isA<ListenerPositionEvent>());
      final listenerOrientation = events.first as ListenerOrientationEvent;
      final listenerPosition = events.last as ListenerPositionEvent;
      expect(listenerPosition.x, equals(coordinates.x));
      expect(listenerPosition.y, equals(coordinates.y));
      final orientation = ListenerOrientationEvent.fromAngle(level.heading);
      expect(listenerOrientation.x1, equals(orientation.x1));
      expect(listenerOrientation.x2, equals(orientation.x2));
      expect(listenerOrientation.y1, equals(orientation.y1));
      expect(listenerOrientation.y2, equals(orientation.y2));
      expect(listenerOrientation.z1, equals(orientation.z1));
      expect(listenerOrientation.z2, equals(orientation.z2));
    });
  });
}
