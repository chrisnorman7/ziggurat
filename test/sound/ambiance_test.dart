/// Test ambiances.
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Ambiance tests', () {
    test('Initialisation', () {
      final a = Ambiance(
          sound: AssetReference('sound.wav', AssetType.file),
          position: Point(5.0, 4.0));
      expect(a.sound.name, equals('sound.wav'));
      expect(a.sound.type, equals(AssetType.file));
      expect(a.position, equals(Point<double>(5.0, 4.0)));
    });
  });
}
