import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

import '../helpers.dart';

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
    test('.handleSdlValue (Keyboard Events)', () {
      const keyCode = KeyCode.keycode_ESCAPE;
      final sdl = Sdl();
      final level = TileMapLevel(
          game: game, tileMap: TileMap(tiles: [], width: 10, height: 10));
      expect(level.turnDirection, isNull);
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, isNull);
      var scanCode = level.turnLeftScanCode;
      level
        ..turnDirection = TurnDirections.right
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode,
            state: PressedState.pressed));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      level
        ..turnDirection = TurnDirections.right
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode));
      expect(level.turnDirection, isNull);
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      scanCode = level.turnRightScanCode;
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode,
            state: PressedState.pressed));
      expect(level.turnDirection, equals(TurnDirections.right));
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode));
      expect(level.turnDirection, isNull);
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      scanCode = level.sidestepLeftScanCode;
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode,
            state: PressedState.pressed));
      expect(level.sidestepDirection, equals(TurnDirections.left));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, isNull);
      scanCode = level.sidestepRightScanCode;
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.left
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode,
            state: PressedState.pressed));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, isNull);
      scanCode = level.backwardScanCode;
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.left
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode,
            state: PressedState.pressed));
      expect(level.movementDirection, equals(MovementDirections.backward));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.sidestepDirection, isNull);
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, isNull);
      scanCode = level.forwardScanCode;
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode,
            state: PressedState.pressed));
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.sidestepDirection, isNull);
      level
        ..turnDirection = TurnDirections.left
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..handleSdlEvent(makeKeyboardEvent(sdl, scanCode, keyCode));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, isNull);
    });
    test('.handleSdlValue (Axis Events)', () {
      const minValue = -32768;
      const maxValue = 32767;
      final sdl = Sdl();
      final level = TileMapLevel(
          game: game, tileMap: TileMap(tiles: [], width: 10, height: 10));
      expect(level.turnDirection, isNull);
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, isNull);
      var axis = level.turnSettings.axis;
      level
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.right
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, minValue));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      level
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.right
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, 0));
      expect(level.turnDirection, isNull);
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      level
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.left
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, maxValue));
      expect(level.turnDirection, equals(TurnDirections.right));
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.left));
      level
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, 0));
      expect(level.turnDirection, isNull);
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      axis = level.movementSettings.axis;
      level
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, maxValue));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, equals(MovementDirections.backward));
      expect(level.sidestepDirection, isNull);
      level
        ..movementDirection = MovementDirections.forward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, 0));
      expect(level.turnDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, equals(TurnDirections.right));
      level
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, minValue));
      expect(level.turnDirection, TurnDirections.left);
      expect(level.movementDirection, equals(MovementDirections.forward));
      expect(level.sidestepDirection, isNull);
      level
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, 0));
      expect(level.turnDirection, TurnDirections.left);
      expect(level.movementDirection, isNull);
      expect(level.sidestepDirection, equals(TurnDirections.right));
      axis = level.sidestepSettings.axis;
      level
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, minValue));
      expect(level.sidestepDirection, equals(TurnDirections.left));
      expect(level.movementDirection, isNull);
      expect(level.turnDirection, TurnDirections.left);
      level
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, 0));
      expect(level.sidestepDirection, isNull);
      expect(level.movementDirection, equals(MovementDirections.backward));
      expect(level.turnDirection, TurnDirections.left);
      level
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.left
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, maxValue));
      expect(level.sidestepDirection, equals(TurnDirections.right));
      expect(level.movementDirection, isNull);
      expect(level.turnDirection, TurnDirections.left);
      level
        ..movementDirection = MovementDirections.backward
        ..sidestepDirection = TurnDirections.right
        ..turnDirection = TurnDirections.left
        ..handleSdlEvent(makeControllerAxisEvent(sdl, axis, 0));
      expect(level.sidestepDirection, isNull);
      expect(level.movementDirection, equals(MovementDirections.backward));
      expect(level.turnDirection, TurnDirections.left);
    });
  });
}
