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
  });
}