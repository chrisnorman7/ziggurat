import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Sound Event Tests', () {
    test('Ensure listening works', () async {
      final game = Game('Ensure Listener');
      expect(game.soundsController.hasListener, isFalse);
      expect(game.sounds, equals(game.soundsController.stream));
      final events = <SoundEvent>[];
      final subscription = game.sounds.listen(events.add);
      expect(game.soundsController.hasListener, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(2));
      game.queueSoundEvent(SoundEvent(SoundEvent.nextId()));
      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(3));
      events.clear();
      subscription.pause();
      game.queueSoundEvent(SoundEvent(SoundEvent.nextId()));
      expect(events.isEmpty, isTrue);
      subscription.resume();
      await Future<void>.delayed(Duration.zero);
      expect(events.length, equals(1));
      subscription.cancel();
    });
    test('Default sound channels', () {
      final game = Game('Sound Channels');
      expect(game.interfaceSounds.id, equals(SoundEvent.maxEventId - 1));
      expect(game.ambianceSounds.id, equals(game.interfaceSounds.id + 1));
    });
    test('Event ID increment', () {
      final game = Game('Sound Channel');
      expect(SoundEvent.maxEventId, equals(game.ambianceSounds.id));
      final channel = game.createSoundChannel();
      expect(channel.id, equals(game.ambianceSounds.id + 1));
      expect(SoundEvent.maxEventId, equals(channel.id));
      final sound =
          channel.playSound(SoundReference('testing', SoundType.file));
      expect(sound.id, equals(channel.id + 1));
      expect(SoundEvent.maxEventId, equals(sound.id));
    });
    test('Sound Keep Alive', () async {
      final game = Game('Sound Keep Alive');
      final reference = SoundReference('testing', SoundType.file);
      var sound = game.interfaceSounds.playSound(reference, keepAlive: true)
        ..destroy();
      sound = game.interfaceSounds.playSound(reference);
      expect(sound.destroy, throwsA(isA<DeadSound>()));
      expect(
          game.sounds,
          emitsInOrder(<Matcher>[
            isA<SoundChannel>(),
            isA<SoundChannel>(),
            isA<PlaySound>(),
            isA<DestroySound>(),
            isA<PlaySound>(),
          ]));
    });
  });
  group('Sounds stream tests', () {
    final game = Game('Test Sounds');
    test('Events', () async {
      final reverb = game.createReverb(ReverbPreset('Test Reverb'));
      final channel = game.createSoundChannel(position: SoundPositionPanned());
      expect(channel.position, isA<SoundPositionPanned>());
      channel
        ..gain = 1.0
        ..position = SoundPositionPanned(azimuthOrScalar: 1.0);
      expect(channel.gain, equals(1.0));
      expect(
          channel.position,
          predicate((value) =>
              value is SoundPositionPanned &&
              value.azimuthOrScalar == 1.0 &&
              value.elevation == null));
      final sound = channel.playSound(
          SoundReference('testing.wav', SoundType.file),
          keepAlive: true);
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
      expect(
          game.sounds,
          emitsInOrder(<Matcher>[
            equals(game.interfaceSounds),
            equals(game.ambianceSounds),
            equals(reverb),
            equals(channel),
            predicate((value) =>
                value is SetSoundChannelGain &&
                value.id == channel.id &&
                value.gain == channel.gain),
            predicate((value) =>
                value is SetSoundChannelPosition &&
                value.id == channel.id &&
                value.position == channel.position),
            equals(sound),
            predicate((value) => value is PauseSound && value.id == sound.id),
            predicate((value) => value is UnpauseSound && value.id == sound.id),
            predicate((value) =>
                value is SetSoundGain &&
                value.id == sound.id &&
                value.gain == sound.gain),
            predicate((value) =>
                value is SetLoop &&
                value.looping == true &&
                value.id == sound.id),
            predicate((value) =>
                value is SetSoundPitchBend &&
                value.id == sound.id &&
                value.pitchBend == sound.pitchBend),
            predicate((value) =>
                value is SoundChannelBandpass &&
                value.id == channel.id &&
                value.frequency == 440.0 &&
                value.bandwidth == 200.0),
            predicate((value) =>
                value is SoundChannelHighpass &&
                value.id == channel.id &&
                value.frequency == 440.0 &&
                value.q == 0.7071135624381276),
            predicate((value) =>
                value is SoundChannelLowpass &&
                value.id == channel.id &&
                value.frequency == 440.0 &&
                value.q == 0.7071135624381276),
            predicate((value) =>
                value is SoundChannelFilter &&
                value is! SoundChannelLowpass &&
                value is! SoundChannelHighpass &&
                value is! SoundChannelBandpass),
            predicate((value) =>
                value is AutomationFade &&
                value.game == game &&
                value.preFade == 0.0 &&
                value.fadeLength == 2.0 &&
                value.startGain == sound.gain &&
                value.endGain == 0.0),
            predicate((value) =>
                value is CancelAutomationFade && value.id == sound.id),
            predicate((value) => value is DestroySound && value.id == sound.id),
            predicate(
                (value) => value is DestroyReverb && value.id == reverb.id)
          ]));
    });
    test('SoundChannel.playSound', () {
      final sound = game.ambianceSounds
          .playSound(SoundReference.file('loop.wav'), looping: true, gain: 0.2);
      expect(sound.looping, isTrue);
      expect(sound.gain, equals(0.2));
    });
    test('Destroy test', () async {
      Game('Test Destroy').destroy();
    });
    test('Level.onPop', () {
      final game = Game('Test onPop');
      final ambiance1 = SoundReference.file('ambiance1.wav');
      final ambiance2 = SoundReference.file('ambiance2.wav');
      final level = Level(game, ambiances: <Ambiance>[
        Ambiance(sound: ambiance1),
        Ambiance(sound: ambiance2)
      ]);
      game
        ..pushLevel(level)
        ..popLevel()
        ..pushLevel(level)
        ..popLevel(ambianceFadeTime: 2.0);
      expect(game.tasks.length, equals(2));
      expect(
          game.sounds,
          emitsInOrder(<Matcher>[
            equals(game.interfaceSounds),
            equals(game.ambianceSounds),
            predicate(
                (value) =>
                    value is PlaySound &&
                    value.channel == game.ambianceSounds.id &&
                    value.sound == ambiance1 &&
                    value.id == game.ambianceSounds.id + 1,
                'Plays ambiance1'),
            predicate(
                (value) =>
                    value is PlaySound &&
                    value.channel == game.ambianceSounds.id &&
                    value.sound == ambiance2 &&
                    value.id == game.ambianceSounds.id + 2,
                'Plays ambiance2'),
            predicate(
                (value) =>
                    value is DestroySound &&
                    value.id == game.ambianceSounds.id + 2,
                'Destroys ambiance2'),
            predicate(
                (value) =>
                    value is DestroySound &&
                    value.id == game.ambianceSounds.id + 1,
                'Destroys ambiance1'),
            predicate(
                (value) =>
                    value is PlaySound &&
                    value.channel == game.ambianceSounds.id &&
                    value.sound == ambiance1 &&
                    value.id == game.ambianceSounds.id + 3,
                'Replays ambiance1'),
            predicate(
                (value) =>
                    value is PlaySound &&
                    value.channel == game.ambianceSounds.id &&
                    value.sound == ambiance2 &&
                    value.id == game.ambianceSounds.id + 4,
                'Replays ambiance2'),
            predicate(
                (value) =>
                    value is AutomationFade &&
                    value.id == game.ambianceSounds.id + 4 &&
                    value.fadeLength == 2.0,
                'Fades ambiance2'),
            predicate(
                (value) =>
                    value is AutomationFade &&
                    value.id == game.ambianceSounds.id + 3 &&
                    value.fadeLength == 2.0,
                'Fades ambiance1'),
          ]));
    });
    test('Sound positions', () {
      final game = Game('Sound positions');
      var channel = game.createSoundChannel();
      expect(() => channel.position = SoundPositionPanned(),
          throwsA(isA<PositionMismatchError>()));
      expect(() => channel.position = SoundPosition3d(),
          throwsA(isA<PositionMismatchError>()));
      channel = game.createSoundChannel(position: SoundPositionPanned());
      expect(() => channel.position = SoundPosition3d(),
          throwsA(isA<PositionMismatchError>()));
      expect(() => channel.position = unpanned,
          throwsA(isA<PositionMismatchError>()));
      channel = game.createSoundChannel(position: SoundPosition3d());
      expect(() => channel.position = SoundPositionPanned(),
          throwsA(isA<PositionMismatchError>()));
      expect(() => channel.position = unpanned,
          throwsA(isA<PositionMismatchError>()));
    });
  });
}
