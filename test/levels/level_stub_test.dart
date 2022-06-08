import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';
import 'package:ziggurat/src/json/asset_reference.dart';

void main() {
  final sdl = Sdl();
  group('LevelStub', () {
    test('Initialisation', () {
      const stub = LevelStub();
      expect(stub.ambiances, isEmpty);
      expect(stub.randomSounds, isEmpty);
    });
  });
  group('Level', () {
    test('.fromStub', () {
      final game = Game(
        title: 'Level.fromStub',
        sdl: sdl,
      );
      const stub = LevelStub(
        ambiances: [
          Ambiance(sound: AssetReference.file('ambiance1.wav')),
          Ambiance(sound: AssetReference.collection('ambiances'))
        ],
        randomSounds: [
          RandomSound(
            sound: AssetReference.file('random_sound_1.wav'),
            minCoordinates: Point(0, 1),
            maxCoordinates: Point(2, 3),
            minInterval: 5000,
            maxInterval: 10000,
          )
        ],
      );
      final level = Level.fromStub(game, stub);
      expect(level.game, equals(game));
      expect(level.randomSounds, equals(stub.randomSounds));
      expect(level.ambiances, equals(stub.ambiances));
    });
  });
}
