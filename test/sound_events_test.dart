import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Sound Event Tests', () {
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
  });
  group('Sounds stream tests', () {
    final game = Game('Test Sounds');
    test('Events', () async {
      final reverb = game.createReverb(ReverbPreset('Test Reverb'));
      final channel = game.createSoundChannel()..gain = 1.0;
      expect(channel.gain, equals(1.0));
      final sound = channel.playSound(
        SoundReference('testing.wav', SoundType.file),
      )..paused = true;
      expect(sound.paused, isTrue);
      sound.paused = false;
      expect(sound.paused, isFalse);
      sound.gain = 1.0;
      expect(sound.gain, equals(1.0));
      sound.looping = true;
      expect(sound.looping, isTrue);
      sound.destroySound();
      final destroyReverb = game.destroyReverb(reverb);
      expect(
          game.sounds.stream,
          emitsInOrder(<Matcher>[
            equals(game.interfaceSounds),
            equals(game.ambianceSounds),
            equals(reverb),
            equals(channel),
            predicate((value) =>
                value is SetSoundChannelGain &&
                value.id == channel.id &&
                value.gain == channel.gain),
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
            predicate((value) => value is DestroySound && value.id == sound.id),
            equals(destroyReverb)
          ]));
    });
  });
}
