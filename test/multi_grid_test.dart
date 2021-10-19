import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('MultiGridLevelRowAction', () {
    test('Initialisation', () {
      var i = 0;
      final action = MultiGridLevelRowAction(Message(text: 'Test'), () => i++);
      expect(action.label,
          predicate((value) => value is Message && value.text == 'Test'));
      expect(i, isZero);
      action.func();
      expect(i, equals(1));
    });
  });
  group('MultiGridLevelRow', () {
    test('Initialise', () {
      var i = 0;
      final row = MultiGridLevelRow(
          label: Message(text: 'Testing'),
          getNumberOfEntries: () => 5,
          getEntryLabel: (int value) => Message(text: 'Label $value'),
          onActivate: (int value) => i = value);
      expect(row.actions, isEmpty);
      expect(i, isZero);
      expect(row.label,
          predicate((value) => value is Message && value.text == 'Testing'));
      expect(row.getNumberOfEntries(), equals(5));
    });
  });
}
