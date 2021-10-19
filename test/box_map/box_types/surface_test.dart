import 'package:test/test.dart';
import 'package:ziggurat/mapping.dart';

void main() {
  group('Surface', () {
    test('Initialise', () {
      final surface = Surface();
      expect(surface.footstepSize, equals(1.0));
      expect(surface.minMoveInterval, equals(500.0));
      expect(surface.minTurnInterval, equals(100));
      expect(surface.reverbPreset, isNull);
      expect(surface.turnAmount, equals(5.0));
    });
  });
}
