import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  final sdl = Sdl();
  group('Sound Event Tests', () {
    test('Ensure listening works', () async {
      final game = Game(
        title: 'Ensure Listener',
        sdl: sdl,
      );
      expect(game.soundsController.hasListener, isFalse);
      expect(game.sounds, equals(game.soundsController.stream));
      final events = <SoundEvent>[];
      final subscription = game.sounds.listen(events.add);
      expect(game.soundsController.hasListener, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 3);
      game.queueSoundEvent(SoundEvent(id: SoundEvent.nextId()));
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 4);
      events.clear();
      subscription.pause();
      game.queueSoundEvent(SoundEvent(id: SoundEvent.nextId()));
      expect(events.isEmpty, isTrue);
      subscription.resume();
      await Future<void>.delayed(Duration.zero);
      expect(events.length, 1);
      await subscription.cancel();
    });
    test('Default sound channels', () {
      final game = Game(
        title: 'Sound Channels',
        sdl: sdl,
      );
      expect(game.interfaceSounds.id, SoundEvent.maxEventId - 2);
      expect(game.ambianceSounds.id, equals(game.interfaceSounds.id! + 1));
    });
    test('Event ID increment', () {
      final game = Game(
        title: 'Sound Channel',
        sdl: sdl,
      );
      expect(SoundEvent.maxEventId, game.ambianceSounds.id! + 1);
      final channel = game.createSoundChannel();
      expect(channel.id, game.ambianceSounds.id! + 2);
      expect(SoundEvent.maxEventId, equals(channel.id));
      final sound =
          channel.playSound(const AssetReference('testing', AssetType.file));
      expect(sound.id, equals(channel.id! + 1));
      expect(SoundEvent.maxEventId, equals(sound.id));
    });
    test('Sound Keep Alive', () async {
      final game = Game(
        title: 'Sound Keep Alive',
        sdl: sdl,
      );
      const reference = AssetReference('testing', AssetType.file);
      var sound = game.interfaceSounds.playSound(reference, keepAlive: true)
        ..destroy();
      sound = game.interfaceSounds.playSound(reference);
      expect(sound.destroy, throwsA(isA<DeadSound>()));
      expect(
        game.sounds,
        emitsInOrder(
          <Matcher>[
            equals(game.interfaceSounds),
            equals(game.ambianceSounds),
            equals(game.musicSounds),
            isA<PlaySound>(),
            isA<DestroySound>(),
            isA<PlaySound>(),
          ],
        ),
      );
    });
    test('PlaySound with a custom ID', () {
      final game = Game(
        title: 'PlaySound',
        sdl: sdl,
      );
      final sound1 = PlaySound(
        game: game,
        sound: const AssetReference('something.mp3', AssetType.collection),
        channel: 45,
        keepAlive: false,
      );
      final sound2 = PlaySound(
        game: sound1.game,
        sound: sound1.sound,
        channel: sound1.channel,
        keepAlive: sound1.keepAlive,
        id: sound1.id,
      );
      expect(sound2.id, sound1.id);
    });
  });
  group('Sounds stream tests', () {
    final game = Game(
      title: 'Test Sounds',
      sdl: sdl,
    );
    test('Events', () async {
      game
        ..setDefaultPannerStrategy(DefaultPannerStrategy.hrtf)
        ..setListenerOrientation(180)
        ..setListenerPosition(3.0, 4.0, 5.0);
      final reverb = game.createReverb(const ReverbPreset(name: 'Test Reverb'));
      const echoTap = EchoTap(
        delay: 10.0,
        gainL: 0.5,
        gainR: 0.4,
      );
      final echo = game.createEcho(
        [echoTap],
      );
      expect(echo.game, game);
      expect(echo.taps, [echoTap]);
      final echoTaps = [
        const EchoTap(delay: 1.0),
        const EchoTap(delay: 2.0),
        const EchoTap(delay: 3.0),
      ];
      echo.taps = echoTaps;
      final channel = game.createSoundChannel(
        position: const SoundPositionScalar(),
      );
      expect(channel.position, isA<SoundPositionScalar>());
      channel
        ..gain = 1.0
        ..position = const SoundPositionScalar(scalar: 1.0);
      expect(channel.gain, equals(1.0));
      expect(
        channel.position,
        predicate(
          (final value) => value is SoundPositionScalar && value.scalar == 1.0,
        ),
      );
      expect(channel.reverb, null);
      expect(channel.echo, null);
      channel.reverb = reverb.id;
      expect(channel.reverb, equals(reverb.id));
      channel.reverb = null;
      expect(channel.reverb, isNull);
      channel.echo = echo.id;
      expect(channel.echo, echo.id);
      channel.echo = null;
      expect(channel.echo, null);
      final sound = channel.playSound(
        const AssetReference('testing.wav', AssetType.file),
        keepAlive: true,
      );
      expect(sound.keepAlive, isTrue);
      sound.paused = true;
      expect(sound.paused, isTrue);
      sound.paused = false;
      expect(sound.paused, isFalse);
      sound.gain = 1.0;
      expect(sound.gain, equals(1.0));
      sound.looping = true;
      expect(sound.looping, isTrue);
      expect(sound.pitchBend, equals(1.0));
      sound.pitchBend = 2.0;
      expect(sound.pitchBend, equals(2.0));
      channel
        ..filterBandpass(440.0, 200.0)
        ..filterHighpass(440.0)
        ..filterLowpass(440.0)
        ..clearFilter();
      final fade = sound.fade(length: 2.0);
      expect(fade.game, equals(game));
      expect(fade.id, equals(sound.id));
      fade.cancel();
      sound.destroy();
      reverb.destroy();
      echo.destroy();
      expect(
        game.sounds,
        emitsInOrder(
          <Matcher>[
            equals(game.interfaceSounds),
            equals(game.ambianceSounds),
            equals(game.musicSounds),
            predicate(
              (final value) =>
                  value is SetDefaultPannerStrategy &&
                  value.strategy == DefaultPannerStrategy.hrtf,
              'sets the default panner strategy to HRTF',
            ),
            predicate(
              (final value) =>
                  value is ListenerOrientationEvent &&
                  value.x1 == sin(180.0 * pi / 180) &&
                  value.y1 == cos(180.0 * pi / 180) &&
                  value.z1 == 0 &&
                  value.x2 == 0 &&
                  value.y2 == 0 &&
                  value.z2 == 1.0,
              'sets the listener orientation',
            ),
            predicate(
              (final value) =>
                  value is ListenerPositionEvent &&
                  value.x == 3.0 &&
                  value.y == 4.0 &&
                  value.z == 5.0,
              'sets the listener position',
            ),
            equals(reverb),
            equals(echo),
            predicate(
              (final value) =>
                  value is ModifyEchoTaps &&
                  value.id == echo.id &&
                  value.taps == echoTaps,
            ),
            equals(channel),
            predicate(
              (final value) =>
                  value is SetSoundChannelGain &&
                  value.id == channel.id &&
                  value.gain == channel.gain,
            ),
            predicate(
              (final value) =>
                  value is SetSoundChannelPosition &&
                  value.id == channel.id &&
                  value.position == channel.position,
            ),
            predicate(
              (final value) =>
                  value is SetSoundChannelReverb &&
                  value.id == channel.id &&
                  value.reverb == reverb.id,
            ),
            predicate(
              (final value) =>
                  value is SetSoundChannelReverb &&
                  value.id == channel.id &&
                  value.reverb == null,
            ),
            predicate(
              (final value) =>
                  value is SetSoundChannelEcho &&
                  value.id == channel.id &&
                  value.echo == echo.id,
            ),
            predicate(
              (final value) =>
                  value is SetSoundChannelEcho &&
                  value.id == channel.id &&
                  value.echo == null,
            ),
            equals(sound),
            predicate(
              (final value) => value is PauseSound && value.id == sound.id,
            ),
            predicate(
              (final value) => value is UnpauseSound && value.id == sound.id,
            ),
            predicate(
              (final value) =>
                  value is SetSoundGain &&
                  value.id == sound.id &&
                  value.gain == sound.gain,
            ),
            predicate(
              (final value) =>
                  value is SetSoundLooping &&
                  value.looping == true &&
                  value.id == sound.id,
            ),
            predicate(
              (final value) =>
                  value is SetSoundPitchBend &&
                  value.id == sound.id &&
                  value.pitchBend == sound.pitchBend,
            ),
            predicate(
              (final value) =>
                  value is SoundChannelBandpass &&
                  value.id == channel.id &&
                  value.frequency == 440.0 &&
                  value.bandwidth == 200.0,
            ),
            predicate(
              (final value) =>
                  value is SoundChannelHighpass &&
                  value.id == channel.id &&
                  value.frequency == 440.0 &&
                  value.q == 0.7071135624381276,
            ),
            predicate(
              (final value) =>
                  value is SoundChannelLowpass &&
                  value.id == channel.id &&
                  value.frequency == 440.0 &&
                  value.q == 0.7071135624381276,
            ),
            predicate(
              (final value) =>
                  value is SoundChannelFilter &&
                  value is! SoundChannelLowpass &&
                  value is! SoundChannelHighpass &&
                  value is! SoundChannelBandpass,
            ),
            predicate(
              (final value) =>
                  value is AutomationFade &&
                  value.game == game &&
                  value.preFade == 0.0 &&
                  value.fadeLength == 2.0 &&
                  value.startGain == sound.gain &&
                  value.endGain == 0.0,
            ),
            predicate(
              (final value) =>
                  value is CancelAutomationFade && value.id == sound.id,
            ),
            predicate(
              (final value) => value is DestroySound && value.id == sound.id,
            ),
            predicate(
              (final value) => value is DestroyReverb && value.id == reverb.id,
            ),
            predicate(
              (final value) => value is DestroyEcho && value.id == echo.id,
            )
          ],
        ),
      );
    });
    test('SoundChannel.playSound', () {
      final sound = game.ambianceSounds.playSound(
        const AssetReference.file('loop.wav'),
        looping: true,
        gain: 0.2,
      );
      expect(sound.looping, isTrue);
      expect(sound.gain, equals(0.2));
    });
    test('Destroy test', () async {
      Game(
        title: 'Test Destroy',
        sdl: sdl,
      ).destroy();
    });
    test('Level.onPop', () {
      final game = Game(
        title: 'Test onPop',
        sdl: sdl,
      );
      const reference1 = AssetReference.file('ambiance1.wav');
      const reference2 = AssetReference.file('ambiance2.wav');
      const ambiance1 = Ambiance(sound: reference1, gain: 0.4);
      const ambiance2 = Ambiance(
        sound: reference2,
        position: Point(4.0, 5.0),
      );
      final level = Level(
        game: game,
        ambiances: <Ambiance>[ambiance1, ambiance2],
      );
      game.pushLevel(level);
      final playback1 = level.ambiancePlaybacks[ambiance1]!;
      expect(playback1.channel, equals(game.ambianceSounds));
      expect(playback1.sound.gain, equals(ambiance1.gain));
      expect(playback1.sound.sound, equals(reference1));
      final playback2 = level.ambiancePlaybacks[ambiance2]!;
      expect(playback2.sound.gain, equals(ambiance2.gain));
      expect(playback2.sound.sound, equals(reference2));
      expect(playback2.channel, isNot(game.ambianceSounds));
      expect(playback2.channel.position, isA<SoundPosition3d>());
      var position = playback2.channel.position as SoundPosition3d;
      expect(position.x, equals(ambiance2.position!.x));
      expect(position.y, equals(ambiance2.position!.y));
      game
        ..popLevel()
        ..pushLevel(level);
      final playback3 = level.ambiancePlaybacks[ambiance1]!;
      expect(playback3.channel, equals(game.ambianceSounds));
      expect(playback3.sound.sound, equals(reference1));
      expect(playback3.sound.gain, equals(ambiance1.gain));
      final playback4 = level.ambiancePlaybacks[ambiance2]!;
      expect(playback4.channel, isNot(game.ambianceSounds));
      expect(playback4.channel.position, isA<SoundPosition3d>());
      position = playback4.channel.position as SoundPosition3d;
      expect(position.x, equals(ambiance2.position!.x));
      expect(position.y, equals(ambiance2.position!.y));
      expect(playback4.channel, isNot(playback2.channel));
      game.popLevel(ambianceFadeTime: 2.0);
      expect(game.tasks.length, equals(2));
      expect(
        game.sounds,
        emitsInOrder(
          <Matcher>[
            equals(game.interfaceSounds),
            equals(game.ambianceSounds),
            equals(game.musicSounds),
            equals(playback1.sound),
            equals(playback2.channel),
            equals(playback2.sound),
            predicate(
              (final value) =>
                  value is DestroySound && value.id == playback1.sound.id,
              'Destroys ambiance1',
            ),
            predicate(
              (final value) =>
                  value is DestroySound && value.id == playback2.sound.id,
              'Destroys ambiance2',
            ),
            predicate(
              (final value) =>
                  value is DestroySoundChannel &&
                  value.id == playback2.channel.id,
              'destroys ambiance2 channel',
            ),
            equals(playback3.sound),
            equals(playback4.channel),
            equals(playback4.sound),
            predicate(
              (final value) =>
                  value is AutomationFade &&
                  value.id == playback3.sound.id &&
                  value.fadeLength == 2.0,
              'Fades ambiance1',
            ),
            predicate(
              (final value) =>
                  value is AutomationFade &&
                  value.id == playback4.sound.id &&
                  value.fadeLength == 2.0,
              'Fades ambiance2',
            ),
          ],
        ),
      );
    });
    test('Sound positions', () {
      final game = Game(
        title: 'Sound positions',
        sdl: sdl,
      );
      var channel = game.createSoundChannel();
      expect(
        () => channel.position = const SoundPositionScalar(),
        throwsA(isA<PositionMismatchError>()),
      );
      expect(
        () => channel.position = const SoundPosition3d(),
        throwsA(isA<PositionMismatchError>()),
      );
      channel = game.createSoundChannel(position: const SoundPositionScalar());
      expect(
        () => channel.position = const SoundPosition3d(),
        throwsA(isA<PositionMismatchError>()),
      );
      expect(
        () => channel.position = unpanned,
        throwsA(isA<PositionMismatchError>()),
      );
      channel = game.createSoundChannel(position: const SoundPosition3d());
      expect(
        () => channel.position = const SoundPositionScalar(),
        throwsA(isA<PositionMismatchError>()),
      );
      expect(
        () => channel.position = unpanned,
        throwsA(isA<PositionMismatchError>()),
      );
    });
  });
}
