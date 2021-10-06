import 'package:test/test.dart';
import 'package:ziggurat/ziggurat.dart';

void main() {
  group('Menu Tests', () {
    final game = Game('Menu Testing Game');
    test('Initialisation', () {
      final menu = Menu(game: game, title: Message(text: 'Test Menu'));
      expect(menu.title, isA<Message>());
      expect(menu.menuItems, isEmpty);
      expect(menu.currentMenuItem, isNull);
    });
    test('Using Menus', () {
      var menu = Menu(game: game, title: Message(text: 'Test Menu'), items: [
        MenuItem(Message(text: 'First Item'), Label()),
        MenuItem(Message(text: 'Second Item'),
            ListButton(['First', 'Second', 'Third'])),
        MenuItem(Message(text: 'Quit'), Button(game.stop))
      ]);
      expect(menu.menuItems.length, equals(3));
      final firstItem = menu.menuItems.first;
      expect(firstItem.label.text, equals('First Item'));
      expect(firstItem.widget, isA<Label>());
      final selectItem = menu.menuItems[1];
      final widget = selectItem.widget;
      expect(widget, isA<ListButton<String>>());
      widget as ListButton<String>;
      expect(widget.onChange, isNull);
      expect(widget.items, equals(['First', 'Second', 'Third']));
      expect(widget.value, equals('First'));
      final quitItem = menu.menuItems.last;
      expect(quitItem.widget, isA<Button>());
      expect(menu.currentMenuItem, isNull);
      menu.down();
      expect(menu.currentMenuItem, equals(firstItem));
      menu.up();
      expect(menu.currentMenuItem, isNull);
      menu
        ..down()
        ..down();
      expect(menu.currentMenuItem, equals(selectItem));
      menu.down();
      expect(menu.currentMenuItem, equals(quitItem));
      menu.down();
      expect(menu.currentMenuItem, equals(quitItem));
      menu.up();
      expect(menu.currentMenuItem, equals(selectItem));
      menu.activate();
      expect(widget.value, equals('Second'));
      menu.activate();
      expect(widget.value, equals('Third'));
      menu.activate();
      expect(widget.value, equals('First'));
      var number = 0;
      menu.menuItems
          .add(MenuItem(Message(text: 'Increment'), Button(() => number++)));
      menu
        ..down()
        ..down();
      expect(menu.currentMenuItem!.label.text, equals('Increment'));
      menu.activate();
      expect(number, equals(1));
      menu = Menu(game: game, title: Message(text: 'Default Commands Menu'))
        ..registerCommands(
            activateCommandName: 'activate',
            cancelCommandName: 'cancel',
            downCommandName: 'down',
            upCommandName: 'up');
      expect(menu.commands.length, equals(4));
      var value = true;
      final checkbox = MenuItem(Message(), Checkbox((b) => value = b));
      menu.menuItems.add(checkbox);
      expect(value, isTrue);
      menu.down();
      expect(menu.currentMenuItem, equals(checkbox));
      menu.activate();
      expect(value, isFalse);
    });
    test('ListButton', () {
      var newValue = '';
      final listButton = ListButton(['First', 'Second', 'Third'],
          onChange: (String value) => newValue = value);
      expect(listButton.index, isZero);
      expect(newValue, isEmpty);
      listButton.changeValue();
      expect(newValue, equals(listButton.items[1]));
      expect(listButton.index, equals(1));
      expect(listButton.value, equals(newValue));
      listButton.changeValue();
      expect(newValue, equals(listButton.value));
      expect(listButton.index, equals(2));
      expect(listButton.value, equals('Third'));
      listButton.changeValue();
      expect(listButton.index, isZero);
      expect(listButton.value, equals('First'));
      expect(newValue, equals(listButton.value));
    });
    test('Checkbox', () {
      bool? value;
      final checkbox = Checkbox((b) => value = b);
      expect(checkbox.value, isTrue);
      expect(value, isNull);
      checkbox.changeValue();
      expect(value, isFalse);
      expect(checkbox.value, isFalse);
      checkbox.changeValue();
      expect(value, isTrue);
      expect(checkbox.value, isTrue);
      checkbox.changeValue();
      expect(value, isFalse);
      expect(checkbox.value, isFalse);
    });
    test('Menu Sounds', () {
      final game = Game('Menu Sounds');
      final sound1 = AssetReference('Sound 1', AssetType.file);
      final sound2 = AssetReference('Sound 2', AssetType.file);
      final menu = Menu(game: game, title: Message(text: 'Test Menu'), items: [
        MenuItem(Message(sound: sound1), Label()),
        MenuItem(Message(sound: sound2), Label())
      ]);
      expect(menu.oldSound, isNull);
      menu.down();
      expect(menu.oldSound,
          predicate((value) => value is PlaySound && value.sound == sound1));
      menu.down();
      expect(menu.oldSound,
          predicate((value) => value is PlaySound && value.sound == sound2));
      menu.up();
      expect(menu.oldSound,
          predicate((value) => value is PlaySound && value.sound == sound1));
      menu.up();
      expect(menu.oldSound, isNull);
    });
    test('Button Widget', () {
      final game = Game('Button Widget');
      var number = 0;
      final button = Button(() {
        number++;
      }, sound: AssetReference.file('something.wav'));
      final menu = Menu(
          game: game,
          title: Message(text: 'Test Menu'),
          items: [MenuItem(Message(text: 'Button'), button)])
        ..activate();
      expect(number, isZero);
      expect(menu.oldSound, isNull);
      menu.down();
      expect(menu.currentMenuItem?.widget, equals(button));
      expect(menu.oldSound, isNull);
      menu.activate();
      expect(number, equals(1));
      expect(menu.oldSound?.sound, equals(button.sound));
    });
    test('.addButton', () {
      final game = Game('Menu.addButton');
      final menu = Menu(game: game, title: Message());
      expect(menu.menuItems, isEmpty);
      var i = 0;
      final activateSound = AssetReference.file('activate.wav');
      final selectSound = AssetReference.file('select.wav');
      final item = menu.addButton(() => i++,
          activateSound: activateSound,
          label: 'Activate',
          selectSound: selectSound);
      expect(menu.menuItems.length, equals(1));
      expect(menu.menuItems.last, equals(item));
      expect(item.label.text, equals('Activate'));
      expect(item.label.sound, equals(selectSound));
      final widget = item.widget;
      expect(widget, isA<Button>());
      expect(widget.sound, equals(activateSound));
      widget.onActivate();
      expect(i, equals(1));
    });
    test('.addLabel', () {
      final game = Game('Menu.addLabel');
      final menu = Menu(game: game, title: Message());
      final selectSound = AssetReference.file('select.wav');
      final item = menu.addLabel(label: 'Testing', selectSound: selectSound);
      expect(item.label.text, equals('Testing'));
      expect(item.label.sound, equals(selectSound));
      expect(item.widget, isA<Label>());
    });
  });
}
