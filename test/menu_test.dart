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
        MenuItem(Message(text: 'Quit'), Button(game.stop))
      ]);
      expect(menu.menuItems.length, equals(2));
      final firstItem = menu.menuItems.first;
      expect(firstItem.label.text, equals('First Item'));
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
      expect(menu.currentMenuItem, equals(quitItem));
      menu.down();
      expect(menu.currentMenuItem, equals(quitItem));
      menu.up();
      expect(menu.currentMenuItem, equals(firstItem));
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
    });
    test('Menu Sounds', () {
      final game = Game('Menu Sounds');
      final sound1 = SoundReference('Sound 1', SoundType.file);
      final sound2 = SoundReference('Sound 2', SoundType.file);
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
      }, sound: SoundReference.file('something.wav'));
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
      final activateSound = SoundReference.file('activate.wav');
      final selectSound = SoundReference.file('select.wav');
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
      final selectSound = SoundReference.file('select.wav');
      final item = menu.addLabel(label: 'Testing', selectSound: selectSound);
      expect(item.label.text, equals('Testing'));
      expect(item.label.sound, equals(selectSound));
      expect(item.widget, isA<Label>());
    });
  });
}
