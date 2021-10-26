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
  group('CommandKeyboardKey', () {
    test('./toPrintableString', () {
      var key = CommandKeyboardKey(ScanCode.SCANCODE_0);
      expect(key.toPrintableString(), equals('0'));
      key = CommandKeyboardKey(ScanCode.SCANCODE_SPACE,
          controlKey: true, shiftKey: true, altKey: true);
      expect(key.toPrintableString(), equals('CTRL+SHIFT+ALT+SPACE'));
    });
  });
}
