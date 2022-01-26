import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';

void main() {
  final game = Game('Test Game');
  group(
    'reverb.dart',
    () {
      test(
        'CreateReverb',
        () {
          final reverb = ReverbPreset(name: 'Test Reverb');
          final event = CreateReverb(
            game: game,
            id: 5,
            reverb: reverb,
          );
          expect(
            event.toString(),
            '<CreateReverb id: 5, reverb: Test Reverb>',
          );
        },
      );
      test(
        'DestroyReverb',
        () {
          const event = DestroyReverb(1234);
          expect(event.toString(), '<DestroyReverb id: 1234>');
        },
      );
    },
  );
}
