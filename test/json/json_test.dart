/// Test the various JSON components.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('CommandTrigger', () {
    test('Initialise', () {
      var triggerMap = TriggerMap([]);
      expect(triggerMap.triggers, isEmpty);
      triggerMap = TriggerMap([
        CommandTrigger.basic(
            name: 'first',
            description: 'The first command',
            button: GameControllerButton.a,
            scanCode: ScanCode.SCANCODE_A)
      ]);
      expect(triggerMap.triggers.length, equals(1));
    });
    test('.basic', () {
      final trigger = CommandTrigger.basic(
          name: 'trigger',
          description: 'This is a test command trigger',
          button: GameControllerButton.b,
          scanCode: ScanCode.SCANCODE_1);
      expect(trigger.button, equals(GameControllerButton.b));
      expect(trigger.keyboardKey?.scanCode, equals(ScanCode.SCANCODE_1));
    });
  });
  group('AssetReference', () {
    test('.file', () {
      final sound = AssetReference.file('test.wav');
      expect(sound.name, equals('test.wav'));
      expect(sound.type, equals(AssetType.file));
    });
    test('.collection', () {
      final sound = AssetReference.collection('testing');
      expect(sound.name, equals('testing'));
      expect(sound.type, equals(AssetType.collection));
    });
  });
}
