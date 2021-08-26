import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Sound Event Tests', () {
    test('Event ID increment', () {
      final currentId = SoundEvent.maxEventId;
      final playSoundEvent = PlaySound(
          sound: SoundReference('testing', SoundType.file),
          position: unpanned,
          id: SoundEvent.nextId());
      expect(playSoundEvent.id, equals(currentId + 1));
      expect(SoundEvent.maxEventId, equals(playSoundEvent.id));
    });
  });
  group('Sounds stream tests', () {
    final game = Game('Test Sounds');
    test('Events', () {
      final reverb = game.createReverb(ReverbPreset('Test Reverb'));
      final sound = game.playSound(
          SoundReference('testing.wav', SoundType.file),
          reverb: reverb);
      final pause = game.pauseSound(sound);
      final unpause = game.unpauseSound(sound);
      final setGain = game.setGain(sound, 1.0);
      final setLoop = game.setLoop(sound, true);
      final destroySound = game.destroySound(sound);
      final destroyReverb = game.destroyReverb(reverb);
      expect(
          game.sounds.stream,
          emitsInOrder(<SoundEvent>[
            reverb,
            sound,
            pause,
            unpause,
            setGain,
            setLoop,
            destroySound,
            destroyReverb
          ]));
    });
  });
}
