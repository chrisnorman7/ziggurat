import 'package:test/test.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final game = Game('Test events');
  group(
    'playback.dart',
    () {
      test(
        'PlaySound (encrypted)',
        () {
          final event = PlaySound(
            game: game,
            sound: AssetReference.file('test.wav', encryptionKey: 'asdf123'),
            channel: 5,
            keepAlive: true,
            looping: true,
            gain: 0.5,
            pitchBend: 0.8,
          );
          expect(
            event.toString(),
            '<PlaySound id: ${event.id}, sound: test.wav (encrypted), '
            'channel: 5, keep alive: true, gain: 0.5, looping: true, '
            'pitch bend: 0.8>',
          );
        },
      );
      test(
        'PlaySound (unencrypted)',
        () {
          final event = PlaySound(
            game: game,
            sound: AssetReference.file('test.wav'),
            channel: 5,
            keepAlive: true,
            looping: true,
            gain: 0.5,
            pitchBend: 0.8,
          );
          expect(
            event.toString(),
            '<PlaySound id: ${event.id}, sound: test.wav (unencrypted), '
            'channel: 5, keep alive: true, gain: 0.5, looping: true, '
            'pitch bend: 0.8>',
          );
        },
      );
      test(
        'PauseSound',
        () {
          const event = PauseSound(5);
          expect(event.toString(), '<PauseSound id: 5>');
        },
      );
      test(
        'UnpauseSound',
        () {
          const event = UnpauseSound(4);
          expect(event.toString(), '<UnpauseSound id: 4>');
        },
      );
      test(
        'DestroySound',
        () {
          const event = DestroySound(10);
          expect(event.toString(), '<DestroySound id: 10>');
        },
      );
      test(
        'SetSoundGain',
        () {
          const event = SetSoundGain(id: 12, gain: 0.5);
          expect(event.toString(), '<SetSoundGain id: 12, gain: 0.5>');
        },
      );
      test(
        'SetLoop',
        () {
          const event = SetSoundLooping(id: 5, looping: true);
          expect(event.toString(), '<SetSoundLooping id: 5, looping: true>');
        },
      );
      test(
        'SetSoundPitchBend',
        () {
          const event = SetSoundPitchBend(id: 9, pitchBend: 0.5);
          expect(
            event.toString(),
            '<SetSoundPitchBend id: 9, pitch bend: 0.5>',
          );
        },
      );
    },
  );
}
