import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('TriggerMap', () {
    test('Initialise', () {
      var triggerMap = TriggerMap(<String, CommandTrigger>{});
      expect(triggerMap.triggers, isEmpty);
      triggerMap = TriggerMap({
        'first': CommandTrigger.basic(
            button: GameControllerButton.a, scanCode: ScanCode.SCANCODE_A)
      });
      expect(triggerMap.triggers.length, equals(1));
    });
    test('.registerCommand', () {
      final triggerMap = TriggerMap({});
      final trigger1 = CommandTrigger.basic(scanCode: ScanCode.SCANCODE_1);
      final trigger2 = CommandTrigger.basic(scanCode: ScanCode.SCANCODE_2);
      triggerMap.registerCommand(name: 'first', trigger: trigger1);
      expect(triggerMap.triggers.length, equals(1));
      expect(triggerMap.triggers['first'], equals(trigger1));
      triggerMap.registerCommand(name: 'second', trigger: trigger2);
      expect(triggerMap.triggers.length, equals(2));
      expect(triggerMap.triggers['second'], equals(trigger2));
      expect(
          () => triggerMap.registerCommand(
              name: 'first', trigger: CommandTrigger.basic()),
          throwsA(isA<DuplicateCommandName>()));
    });
  });
}
