import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

/// Test random sounds.
void main() {
  group('Random sounds tests', () {
    test('Initialisation', () {
      final r = RandomSound(
          AssetReference.file('sound.wav'), Point(0, 1), Point(5, 6), 15, 30,
          minGain: 0.1, maxGain: 1.0);
      expect(r.sound, isA<AssetReference>());
      expect(r.minCoordinates.x, equals(0));
      expect(r.maxCoordinates.x, equals(5));
      expect(r.minCoordinates.y, equals(1));
      expect(r.maxCoordinates.y, equals(6));
      expect(r.minInterval, equals(15));
      expect(r.maxInterval, equals(30));
      expect(r.minGain, equals(0.1));
      expect(r.maxGain, equals(1.0));
      expect(r.nextPlay, isNull);
    });
    test('play', () async {
      final sdl = Sdl();
      final game = Game('Play Random Sounds');
      final randomSound1 = RandomSound(AssetReference.file('sound1.wav'),
          Point(1.0, 2.0), Point(5.0, 6.0), 1000, 1000);
      final randomSound2 = RandomSound(AssetReference.file('sound2.wav'),
          Point(23.0, 24.0), Point(38.0, 39.0), 2000, 10000,
          minGain: 0.1, maxGain: 1.0);
      final l = Level(game, randomSounds: [randomSound1, randomSound2]);
      game.pushLevel(l);
      expect(randomSound1.channel, isNull);
      expect(randomSound2.channel, isNull);
      game.time = DateTime.now().millisecondsSinceEpoch;
      await game.tick(sdl, 0);
      expect(randomSound1.channel, isNull);
      expect(
          randomSound1.nextPlay, equals(game.time + randomSound1.minInterval));
      expect(randomSound2.channel, isNull);
      expect(
          randomSound2.nextPlay,
          inOpenClosedRange(game.time + randomSound2.minInterval,
              game.time + randomSound2.maxInterval));
      game.time = randomSound1.nextPlay!;
      await game.tick(sdl, 0);
      expect(randomSound1.channel, isNotNull);
      expect(randomSound2.channel, isNull);
      var channel = randomSound1.channel!;
      expect(channel.gain, equals(randomSound1.minGain));
      expect(channel.position, isA<SoundPosition3d>());
      var position = channel.position as SoundPosition3d;
      expect(
          position.x,
          inOpenClosedRange(
              randomSound1.minCoordinates.x, randomSound1.maxCoordinates.x));
      expect(
          position.y,
          inOpenClosedRange(
              randomSound1.minCoordinates.y, randomSound1.maxCoordinates.y));
      expect(position.z, isZero);
      game.time = randomSound2.nextPlay!;
      await game.tick(sdl, 0);
      expect(randomSound2.channel, isNotNull);
      channel = randomSound2.channel!;
      expect(channel.gain,
          inOpenClosedRange(randomSound2.minGain, randomSound2.maxGain));
      expect(channel.position, isA<SoundPosition3d>());
      position = channel.position as SoundPosition3d;
      expect(
          position.x,
          inOpenClosedRange(
              randomSound2.minCoordinates.x, randomSound2.maxCoordinates.x));
      expect(
          position.y,
          inOpenClosedRange(
              randomSound2.minCoordinates.y, randomSound2.maxCoordinates.y));
      expect(position.z, isZero);
    });
  });
}
