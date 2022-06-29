import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/notes.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/src/game.dart';
import 'package:ziggurat/wave_types.dart';

void main() {
  final sdl = Sdl();
  final game = Game(
    title: 'Test Game',
    sdl: sdl,
  );
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
          const event = SetSoundChannelPosition(id: 7, position: unpanned);
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
          const event = SetSoundChannelReverb(id: 5, reverb: 4);
          expect(event.toString(), '<SetSoundChannelReverb id: 5, reverb: 4>');
        },
      );
      test(
        '.playWave',
        () {
          final soundChannel = game.createSoundChannel();
          final wave = soundChannel.playWave(
            waveType: WaveType.saw,
            frequency: a4,
            partials: 5,
            gain: 0.2,
          );
          expect(wave, isA<PlayWave>());
          expect(wave.channel, soundChannel.id);
          expect(wave.frequency, a4);
          expect(wave.gain, 0.2);
          expect(wave.game, game);
          expect(wave.partials, 5);
          expect(wave.waveType, WaveType.saw);
        },
      );
      test(
        '.playSine',
        () {
          final soundChannel = game.createSoundChannel();
          final wave = soundChannel.playSine(c4, gain: 0.8);
          expect(wave.channel, soundChannel.id);
          expect(wave.frequency, c4);
          expect(wave.gain, 0.8);
          expect(wave.game, game);
          expect(wave.partials, 1);
          expect(wave.waveType, WaveType.sine);
        },
      );
      test(
        '.playTriangle',
        () {
          final soundChannel = game.createSoundChannel();
          expect(
            () => soundChannel.playTriangle(
              g4,
              partials: 0,
            ),
            throwsStateError,
          );
          final wave = soundChannel.playTriangle(g3, gain: 1.0, partials: 8);
          expect(wave.channel, soundChannel.id);
          expect(wave.frequency, g3);
          expect(wave.gain, 1.0);
          expect(wave.game, game);
          expect(wave.partials, 8);
          expect(wave.waveType, WaveType.triangle);
        },
      );
      test(
        '.playSquare',
        () {
          final soundChannel = game.createSoundChannel();
          expect(
            () => soundChannel.playSquare(
              g4,
              partials: 0,
            ),
            throwsStateError,
          );
          final wave = soundChannel.playSquare(fSharp6, gain: 0.5, partials: 3);
          expect(wave.channel, soundChannel.id);
          expect(wave.frequency, fSharp6);
          expect(wave.gain, 0.5);
          expect(wave.game, game);
          expect(wave.partials, 3);
          expect(wave.waveType, WaveType.square);
        },
      );
      test(
        '.playSaw',
        () {
          final soundChannel = game.createSoundChannel();
          expect(
            () => soundChannel.playSaw(
              g4,
              partials: 0,
            ),
            throwsStateError,
          );
          final wave = soundChannel.playSaw(a2, gain: 0.25, partials: 7);
          expect(wave.channel, soundChannel.id);
          expect(wave.frequency, a2);
          expect(wave.gain, 0.25);
          expect(wave.game, game);
          expect(wave.partials, 7);
          expect(wave.waveType, WaveType.saw);
        },
      );
    },
  );
}
