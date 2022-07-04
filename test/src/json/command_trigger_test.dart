import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('CommandTrigger', () {
    test('Initialise', () {
      var triggerMap = const TriggerMap([]);
      expect(triggerMap.triggers, isEmpty);
      triggerMap = TriggerMap([
        CommandTrigger.basic(
          name: 'first',
          description: 'The first command',
          button: GameControllerButton.a,
          scanCode: ScanCode.a,
        )
      ]);
      expect(triggerMap.triggers.length, equals(1));
    });
    test('.basic', () {
      final trigger = CommandTrigger.basic(
        name: 'trigger',
        description: 'This is a test command trigger',
        button: GameControllerButton.b,
        scanCode: ScanCode.digit1,
      );
      expect(trigger.button, equals(GameControllerButton.b));
      expect(trigger.keyboardKey?.scanCode, equals(ScanCode.digit1));
    });
  });
  group('CommandKeyboardKey', () {
    test('./toPrintableString', () {
      var key = const CommandKeyboardKey(ScanCode.digit0);
      expect(key.toPrintableString(), equals('digit0'));
      key = const CommandKeyboardKey(
        ScanCode.space,
        controlKey: true,
        shiftKey: true,
        altKey: true,
      );
      expect(key.toPrintableString(), equals('ctrl+shift+alt+space'));
    });
    test('.toString', () {
      const key = CommandKeyboardKey(ScanCode.digit1, shiftKey: true);
      expect(key.toString(), equals('<CommandKeyboardKey shift+digit1>'));
    });
  });
}
