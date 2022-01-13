import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';

void main() {
  group(
    'sound_position.dart',
    () {
      test(
        'SoundPosition',
        () {
          const position = SoundPosition();
          expect(position, unpanned);
          expect(position.toString(), '<SoundPosition unpanned>');
        },
      );
      test(
        'SoundPositionScalar',
        () {
          const position = SoundPositionScalar(scalar: 1.0);
          expect(position.toString(), '<SoundPositionScalar scalar: 1.0>');
        },
      );
      test(
        'SoundPositionAngular',
        () {
          const position = SoundPositionAngular(azimuth: 1.0, elevation: 0.5);
          expect(
            position.toString(),
            '<SoundPositionAngular azimuth: 1.0, elevation: 0.5>',
          );
        },
      );
      test(
        'SoundPosition3d',
        () {
          const position = SoundPosition3d(x: 1.0, y: 2.0, z: 3.0);
          expect(
            position.toString(),
            '<SoundPosition3d x: 1.0, y: 2.0, z: 3.0>',
          );
        },
      );
    },
  );
}
