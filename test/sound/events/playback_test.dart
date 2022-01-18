import 'package:test/test.dart';
import 'package:ziggurat/notes.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/wave_types.dart';
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
            '<PlaySound id: ${event.id}, sound: test.wav (encrypted '
            'AssetType.file), '
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
            sound: AssetReference.collection('test.wav'),
            channel: 5,
            keepAlive: true,
            looping: true,
            gain: 0.5,
            pitchBend: 0.8,
          );
          expect(
            event.toString(),
            '<PlaySound id: ${event.id}, sound: test.wav (unencrypted '
            'AssetType.collection), '
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
      test(
        'PlayWave',
        () {
          final event = PlayWave(game: game, waveType: WaveType.sine);
          expect(event.frequency, a4);
          expect(event.gain, 0.7);
          expect(event.game, game);
          expect(event.partials, isZero);
          expect(event.waveType, WaveType.sine);
          expect(event.id, isNotNull);
          expect(
            event.toString(),
            '<PlayWave id: ${event.id}, wave type: WaveType.sine, partials: 0>',
          );
        },
      );
      test(
        'SetWaveGain',
        () {
          final event = SetWaveGain(id: 45, gain: 0.3);
          expect(
            event.toString(),
            '<SetWaveGain id: 45, gain: 0.3>',
          );
        },
      );
      test(
        'SetWaveFrequency',
        () {
          final event = SetWaveFrequency(id: 3, frequency: c4);
          expect(
            event.toString(),
            '<SetWaveFrequency id: 3, frequency: $c4>',
          );
        },
      );
      test(
        'DestroyWave',
        () {
          final event = DestroyWave(4);
          expect(event.toString(), '<DestroyWave id: 4>');
        },
      );
      test(
        'AutomateWaveFrequency',
        () {
          final event = AutomateWaveFrequency(
            id: 8,
            startFrequency: a4,
            length: 2.0,
            endFrequency: c3,
          );
          expect(
            event.toString(),
            '<AutomateWaveFrequency id: 8, start frequency: $a4, '
            'length: 2.0, end frequency: $c3>',
          );
        },
      );
      test(
        'PlayWave.automateFrequency',
        () {
          final wave = PlayWave(game: game, waveType: WaveType.triangle);
          final event = wave.automateFrequency(length: 3.0, endFrequency: c2);
          expect(event.endFrequency, c2);
          expect(event.length, 3.0);
          expect(event.startFrequency, wave.frequency);
          expect(event.id, wave.id);
        },
      );
    },
  );
}
