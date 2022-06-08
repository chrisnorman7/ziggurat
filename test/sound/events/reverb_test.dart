import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';

void main() {
  final sdl = Sdl();
  final game = Game(
    title: 'Test Game',
    sdl: sdl,
  );
  group(
    'reverb.dart',
    () {
      test(
        'CreateReverb',
        () {
          const reverb = ReverbPreset(name: 'Test Reverb');
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
