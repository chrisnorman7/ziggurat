import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/notes.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/wave_types.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final sdl = Sdl();
  final game = Game(
    title: 'Test events',
    sdl: sdl,
  );
  group(
    'playback.dart',
    () {
      test(
        'PlaySound (encrypted)',
        () {
          final event = PlaySound(
            game: game,
            sound:
                const AssetReference.file('test.wav', encryptionKey: 'asdf123'),
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
            sound: const AssetReference.collection('test.wav'),
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
          final event = PlayWave(
            game: game,
            channel: 4,
            waveType: WaveType.sine,
          );
          expect(event.frequency, a4);
          expect(event.gain, 0.7);
          expect(event.game, game);
          expect(event.channel, 4);
          expect(event.partials, isZero);
          expect(event.waveType, WaveType.sine);
          expect(event.id, isNotNull);
          expect(
            event.toString(),
            '<PlayWave id: ${event.id}, channel: 4, wave type: WaveType.sine, '
            'partials: 0>',
          );
        },
      );
      test(
        'SetWaveGain',
        () {
          const event = SetWaveGain(id: 45, gain: 0.3);
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
          const event = DestroyWave(4);
          expect(event.toString(), '<DestroyWave id: 4>');
        },
      );
      test(
        'AutomateWaveFrequency',
        () {
          const event = AutomateWaveFrequency(
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
          final wave =
              PlayWave(game: game, channel: 2, waveType: WaveType.triangle);
          final event = wave.automateFrequency(length: 3.0, endFrequency: c2);
          expect(event.endFrequency, c2);
          expect(event.length, 3.0);
          expect(event.startFrequency, wave.frequency);
          expect(event.id, wave.id);
        },
      );
      test(
        'PauseWave',
        () {
          const event = PauseWave(8);
          expect(event.id, 8);
          expect(event.toString(), '<PauseWave id: 8>');
        },
      );
      test(
        'UnpauseWave',
        () {
          const event = UnpauseWave(4);
          expect(event.id, 4);
          expect(event.toString(), '<UnpauseWave id: 4>');
        },
      );
      test(
        'PlayWave methods',
        () async {
          final game = Game(
            title: 'PlayWave.pause',
            sdl: sdl,
          );
          final events = <SoundEvent>[];
          game.sounds.listen(events.add);
          await Future<void>.delayed(Duration.zero);
          events.clear();
          final wave = PlayWave(
            game: game,
            channel: 8,
            waveType: WaveType.triangle,
          );
          game.queueSoundEvent(wave);
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 1);
          expect(events.single, wave);
          wave.pause();
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 2);
          expect(events.last, isA<PauseWave>());
          expect(events.last is PauseSound, isFalse);
          final paused = events.last as PauseWave;
          expect(paused.id, wave.id);
          wave.unpause();
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 3);
          expect(events.last, isA<UnpauseWave>());
          expect(events.last is UnpauseSound, isFalse);
          final unpaused = events.last as UnpauseWave;
          expect(unpaused.id, wave.id);
          wave.automateFrequency(length: 3.0, endFrequency: c2);
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 4);
          final automateFrequency = events.last as AutomateWaveFrequency;
          expect(automateFrequency.id, wave.id);
          expect(automateFrequency.endFrequency, c2);
          expect(automateFrequency.length, 3.0);
          expect(automateFrequency.startFrequency, wave.frequency);
          expect(automateFrequency.id, wave.id);
          final fade = wave.fade(length: 4.0);
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 5);
          expect(events.last, fade);
          expect(fade.endGain, isZero);
          expect(fade.fadeLength, 4.0);
          expect(fade.game, game);
          expect(fade.preFade, isZero);
          expect(fade.startGain, wave.gain);
          expect(fade.fadeType, FadeType.wave);
          expect(fade.id, wave.id);
          fade.cancel();
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 6);
          final cancelFade = events.last as CancelAutomationFade;
          expect(cancelFade.fadeType, FadeType.wave);
          expect(cancelFade.id, wave.id);
          wave.destroy();
          await Future<void>.delayed(Duration.zero);
          expect(events.length, 7);
          final destroyWave = events.last as DestroyWave;
          expect(destroyWave.id, wave.id);
        },
      );
    },
  );
}
