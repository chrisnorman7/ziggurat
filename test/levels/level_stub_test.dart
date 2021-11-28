import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';
import 'package:ziggurat/src/json/asset_reference.dart';

void main() {
  group('LevelStub', () {
    test('Initialisation', () {
      const stub = LevelStub([], []);
      expect(stub.ambiances, isEmpty);
      expect(stub.randomSounds, isEmpty);
    });
  });
  group('Level', () {
    test('.fromStub', () {
      final game = Game('Level.fromStub');
      const stub = LevelStub([
        Ambiance(sound: AssetReference.file('ambiance1.wav')),
        Ambiance(sound: AssetReference.collection('ambiances'))
      ], [
        RandomSound(AssetReference.file('random_sound_1.wav'), Point(0, 1),
            Point(2, 3), 5000, 10000)
      ]);
      final level = Level.fromStub(game, stub);
      expect(level.game, equals(game));
      expect(level.randomSounds, equals(stub.randomSounds));
      expect(level.ambiances, equals(stub.ambiances));
    });
  });
}
