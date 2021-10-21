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
    test('.fromDict', () {
      int? i;
      void f(int value) => i = value;
      const firstMessage = Message(text: 'First Item');
      const secondMessage = Message(text: 'Second Item');
      final row = MultiGridLevelRow.fromDict(Message(text: 'Test Row'), {
        firstMessage: f,
        secondMessage: f
      }, actions: [
        MultiGridLevelRowAction(Message(text: 'Action'), () => i = 1234)
      ]);
      expect(i, isNull);
      expect(row.label.text, equals('Test Row'));
      expect(row.getNumberOfEntries(), equals(2));
      expect(row.actions.length, equals(1));
      row.actions.first.func();
      expect(i, equals(1234));
      expect(row.getEntryLabel(0).text, equals('First Item'));
      expect(row.getEntryLabel(1).text, equals('Second Item'));
      row.onActivate(0);
      expect(i, isZero);
      row.onActivate(1);
      expect(i, equals(1));
    });
  });
}
