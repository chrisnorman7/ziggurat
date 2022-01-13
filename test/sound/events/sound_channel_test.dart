import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';

void main() {
  final game = Game('Test Game');
  group(
    'sound_channel.dart',
    () {
      test(
        'SoundChannel',
        () {
          final event = SoundChannel(
            game: game,
            id: 4,
            gain: 0.5,
          );
          expect(
            event.toString(),
            '<SoundChannel id: 4, position: <SoundPosition unpanned>, '
            'reverb: null, gain: 0.5>',
          );
        },
      );
      test(
        'DestroySoundChannel',
        () {
          const event = DestroySoundChannel(5);
          expect(event.toString(), '<DestroySoundChannel id: 5>');
        },
      );
      test(
        'SetSoundChannelGain',
        () {
          const event = SetSoundChannelGain(id: 4, gain: 0.5);
          expect(event.toString(), '<SetSoundChannelGain id: 4, gain: 0.5>');
        },
      );
      test(
        'SetSoundChannelPosition',
        () {
          const event = SetSoundChannelPosition(7, unpanned);
          expect(
            event.toString(),
            '<SetSoundChannelPosition id: 7, '
            'position: <SoundPosition unpanned>>',
          );
        },
      );
      test(
        'SetSoundChannelReverb',
        () {
          const event = SetSoundChannelReverb(5, 4);
          expect(event.toString(), '<SetSoundChannelReverb id: 5, reverb: 4>');
        },
      );
    },
  );
}
