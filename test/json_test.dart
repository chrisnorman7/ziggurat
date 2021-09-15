/// Test the various JSON components.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('CommandTrigger', () {
    test('Initialise', () {
      final trigger = CommandTrigger(
          button: GameControllerButton.a,
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_0));
      expect(trigger.button, equals(GameControllerButton.a));
      expect(trigger.keyboardKey?.scanCode, equals(ScanCode.SCANCODE_0));
    });
    test('.basic', () {
      final trigger = CommandTrigger.basic(
          button: GameControllerButton.b, scanCode: ScanCode.SCANCODE_1);
      expect(trigger.button, equals(GameControllerButton.b));
      expect(trigger.keyboardKey?.scanCode, equals(ScanCode.SCANCODE_1));
    });
  });
  group('SoundReference', () {
    test('.file', () {
      final sound = SoundReference.file('test.wav');
      expect(sound.name, equals('test.wav'));
      expect(sound.type, equals(SoundType.file));
    });
    test('.collection', () {
      final sound = SoundReference.collection('testing');
      expect(sound.name, equals('testing'));
      expect(sound.type, equals(SoundType.collection));
    });
  });
}
