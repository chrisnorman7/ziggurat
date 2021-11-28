import 'dart:math';

import 'package:test/test.dart';
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
    });
  });
}
