import 'package:test/test.dart';
import 'package:ziggurat/mapping.dart';

void main() {
  group('Door', () {
    test('Initialise', () {
      final door = Door();
      expect(door.reverbPreset, isNull);
      expect(door.open, isTrue);
      expect(door.closeAfter, isNull);
      expect(door.openMessage, isNull);
      expect(door.closeMessage, isNull);
      expect(door.collideMessage, isNull);
      expect(door.filterFrequency, equals(20000));
    });
  });
}
