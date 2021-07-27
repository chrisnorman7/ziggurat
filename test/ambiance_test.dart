/// Test ambiances.
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Ambiance tests', () {
    test('Initialisation', () {
      final a = Ambiance(File('sound.wav'), Point(5.0, 4.0));
      expect(a.path.path, equals('sound.wav'));
      expect(a.position, equals(Point<double>(5.0, 4.0)));
    });
  });
}
