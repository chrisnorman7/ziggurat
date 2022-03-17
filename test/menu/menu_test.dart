import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../helpers.dart';

void main() {
  group('Menu', () {
    final game = Game('Menu Testing Game');
    test('Initialisation', () {
      var menu = Menu(game: game, title: Message(text: 'Test Menu'));
      expect(menu.title, isA<Message>());
      expect(menu.menuItems, isEmpty);
      expect(menu.onCancel, isNull);
      expect(menu.currentMenuItem, isNull);
      menu = Menu(game: game, title: Message(text: 'Test Menu'), position: 0)
        ..addLabel(text: 'Label')
        ..addButton(() {});
      expect(menu.currentMenuItem, equals(menu.menuItems.first));
    });
    test('Using Menus', () {
      var menu = Menu(game: game, title: Message(text: 'Test Menu'), items: [
        MenuItem(Message(text: 'First Item'), menuItemLabel),
        MenuItem(Message(text: 'Second Item'),
            ListButton(['First', 'Second', 'Third'], (value) {})),
        MenuItem(Message(text: 'Quit'), Button(game.stop))
      ]);
      expect(menu.menuItems.length, equals(3));
      final firstItem = menu.menuItems.first;
      expect(firstItem.label.text, equals('First Item'));
      expect(firstItem.widget, equals(menuItemLabel));
      final selectItem = menu.menuItems[1];
      final widget = selectItem.widget;
      expect(widget, isA<ListButton<String>>());
      widget as ListButton<String>;
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
      menu = Menu(game: game, title: Message(text: 'Default Commands Menu'));
      var value = true;
      final checkbox = MenuItem(Message(), Checkbox((b) => value = b));
      menu.menuItems.add(checkbox);
      expect(value, isTrue);
      menu.down();
      expect(menu.currentMenuItem, equals(checkbox));
      menu.activate();
      expect(value, isFalse);
    });
    test('.cancel', () {
      var cancel = 0;
      final menu = Menu(
          game: game,
          title: Message(text: 'Test Menu'),
          onCancel: () => cancel++);
      expect(cancel, isZero);
      menu.cancel();
      expect(cancel, equals(1));
    });
    test('.handleSdlEvent', () {
      final sdl = Sdl();
      var cancel = 0;
      var activate = 0;
      final menu = Menu(
          game: game,
          title: Message(text: 'Test Menu'),
          onCancel: () => cancel++)
        ..addButton(() => activate++);
      expect(cancel, isZero);
      expect(activate, isZero);
      menu.handleSdlEvent(
          makeKeyboardEvent(sdl, menu.cancelScanCode, KeyCode.keycode_ESCAPE));
      expect(cancel, isZero);
      expect(menu.currentMenuItem, isNull);
      final downEvent = makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_DOWN, KeyCode.keycode_DOWN,
          state: PressedState.pressed);
      menu.handleSdlEvent(downEvent);
      expect(menu.currentMenuItem, equals(menu.menuItems.first));
      menu.handleSdlEvent(makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_UP, KeyCode.keycode_UP,
          state: PressedState.pressed));
      expect(menu.currentMenuItem, isNull);
      menu
        ..handleSdlEvent(downEvent)
        ..handleSdlEvent(makeKeyboardEvent(
            sdl, ScanCode.SCANCODE_ESCAPE, KeyCode.keycode_ESCAPE,
            state: PressedState.pressed));
      expect(cancel, equals(1));
      menu.handleSdlEvent(makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_SPACE, KeyCode.keycode_SPACE));
      expect(activate, isZero);
      menu.handleSdlEvent(makeKeyboardEvent(
          sdl, ScanCode.SCANCODE_SPACE, KeyCode.keycode_SPACE,
          state: PressedState.pressed));
      expect(activate, equals(1));
    });
    test('Moving with number lock on', () {
      final sdl = Sdl();
      final menu = Menu(
        game: game,
        title: Message(text: 'Testing With Number Lock'),
        items: [MenuItem(Message(text: 'First Item'), menuItemLabel)],
      );
      expect(menu.currentMenuItem, isNull);
      menu.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.SCANCODE_DOWN,
          KeyCode.keycode_DOWN,
          modifiers: [KeyMod.num],
          state: PressedState.pressed,
        ),
      );
      expect(menu.currentMenuItem, menu.menuItems.first);
      menu.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.SCANCODE_UP,
          KeyCode.keycode_UP,
          modifiers: [KeyMod.num],
          state: PressedState.pressed,
        ),
      );
      expect(menu.currentMenuItem, isNull);
    });
    test('ListButton', () {
      final menu = Menu(game: Game('ListButton'), title: emptyMessage);
      var newValue = '';
      final listButton = ListButton(
          ['First', 'Second', 'Third'], (String value) => newValue = value);
      expect(listButton.index, isZero);
      final menuItem = MenuItem(Message(text: 'Button'), listButton);
      var label = listButton.getLabel(menuItem);
      expect(label.text, equals('Button (First)'));
      expect(newValue, isEmpty);
      listButton.activate(menu);
      expect(newValue, equals(listButton.items[1]));
      expect(listButton.index, equals(1));
      expect(listButton.value, equals(newValue));
      label = listButton.getLabel(menuItem);
      expect(label.text, equals('Button ($newValue)'));
      listButton.activate(menu);
      expect(newValue, equals(listButton.value));
      expect(listButton.index, equals(2));
      expect(listButton.value, equals('Third'));
      label = listButton.getLabel(menuItem);
      expect(label.text, equals('Button ($newValue)'));
      listButton.activate(menu);
      expect(listButton.index, isZero);
      expect(listButton.value, equals('First'));
      expect(newValue, equals(listButton.value));
      label = listButton.getLabel(menuItem);
      expect(label.text, equals('Button ($newValue)'));
    });
    test('Checkbox', () {
      final menu = Menu(game: Game('ListButton'), title: emptyMessage);
      bool? value;
      final checkbox = Checkbox((b) => value = b);
      expect(checkbox.value, isTrue);
      expect(value, isNull);
      final menuItem = MenuItem(Message(text: 'Checkbox'), checkbox);
      var label = checkbox.getLabel(menuItem);
      expect(label.text, equals('Checkbox (checked)'));
      checkbox.activate(menu);
      expect(value, isFalse);
      expect(checkbox.value, isFalse);
      label = checkbox.getLabel(menuItem);
      expect(label.text, equals('Checkbox (unchecked)'));
      checkbox.activate(menu);
      expect(value, isTrue);
      expect(checkbox.value, isTrue);
      label = checkbox.getLabel(menuItem);
      expect(label.text, equals('Checkbox (checked)'));
      checkbox.activate(menu);
      expect(value, isFalse);
      expect(checkbox.value, isFalse);
    });
    test('Menu Sounds', () {
      final game = Game('Menu Sounds');
      final sound1 = AssetReference('Sound 1', AssetType.file);
      final sound2 = AssetReference('Sound 2', AssetType.file);
      final menu = Menu(game: game, title: Message(text: 'Test Menu'), items: [
        MenuItem(Message(sound: sound1), menuItemLabel),
        MenuItem(Message(sound: sound2), menuItemLabel)
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
      }, activateSound: AssetReference.file('something.wav'));
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
      expect(menu.oldSound?.sound, equals(button.activateSound));
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
      expect(widget.activateSound, equals(activateSound));
      widget.onActivate!();
      expect(i, equals(1));
    });
    test('.addLabel', () {
      final game = Game('Menu.addLabel');
      final menu = Menu(game: game, title: Message());
      final selectSound = AssetReference.file('select.wav');
      final item = menu.addLabel(text: 'Testing', selectSound: selectSound);
      expect(item.label.text, equals('Testing'));
      expect(item.label.sound, equals(selectSound));
      expect(item.widget, equals(menuItemLabel));
    });
    test('.onPop', () {
      final menu = Menu(game: game, title: Message(), items: [
        MenuItem(
            Message(sound: AssetReference.file('file1.wav')), menuItemLabel),
        MenuItem(
            Message(sound: AssetReference.file('file2.wav'), keepAlive: true),
            menuItemLabel)
      ]);
      game.pushLevel(menu);
      expect(game.currentLevel, equals(menu));
      expect(menu.oldSound, isNull);
      menu.down();
      expect(menu.oldSound, isNotNull);
      expect(menu.oldSound!.sound, equals(menu.menuItems.first.label.sound));
      game.popLevel();
      expect(game.currentLevel, isNull);
      expect(menu.oldSound, isNull);
      game.pushLevel(menu);
      expect(game.currentLevel, equals(menu));
      expect(menu.oldSound, isNotNull);
      expect(menu.oldSound!.sound, equals(menu.menuItems.first.label.sound));
      menu.down();
      expect(menu.oldSound, isNotNull);
      expect(menu.oldSound!.sound, equals(menu.menuItems.last.label.sound));
      game.popLevel();
      expect(game.currentLevel, isNull);
      expect(menu.oldSound, isNull);
    });
    test('Searching', () async {
      final sdl = Sdl();
      final menuItems = [
        MenuItem(Message(text: 'First Item'), menuItemLabel),
        MenuItem(Message(text: 'Second Item'), menuItemLabel)
      ];
      var menu = Menu(
          game: game, title: Message(), items: menuItems, searchInterval: 20);
      expect(menu.searchEnabled, isTrue);
      expect(menu.searchInterval, equals(20));
      expect(menu.searchString, isEmpty);
      expect(menu.searchTime, isZero);
      menu.handleSdlEvent(makeTextInputEvent(sdl, ''));
      expect(menu.searchString, isEmpty);
      menu.handleSdlEvent(makeTextInputEvent(sdl, 'F'));
      expect(menu.searchString, equals('f'));
      expect(menu.currentMenuItem, equals(menuItems.first));
      menu.handleSdlEvent(makeTextInputEvent(sdl, 'S'));
      expect(menu.searchString, equals('fs'));
      expect(menu.currentMenuItem, equals(menuItems.first));
      await Future<void>.delayed(Duration(milliseconds: 25));
      menu.handleSdlEvent(makeTextInputEvent(sdl, 's'));
      expect(menu.searchString, equals('s'));
      expect(menu.currentMenuItem, equals(menuItems.last));
      menu = Menu(
          game: game,
          title: menu.title,
          items: menuItems,
          searchEnabled: false);
      expect(menu.searchEnabled, isFalse);
      menu.handleSdlEvent(makeTextInputEvent(sdl, 'asdf'));
      expect(menu.searchString, isEmpty);
    });
    test('Moving in an empty menu', () {
      final menu = Menu(game: game, title: Message());
      expect(menu.menuItems, isEmpty);
      expect(menu.currentMenuItem, isNull);
      menu.down();
      expect(menu.currentMenuItem, isNull);
    });
  });
  group('MenuItem', () {
    test('DynamicWidget', () {
      final widget = DynamicWidget((menuItem) => Message(text: 'Test Widget'));
      final menuItem = MenuItem(Message(), widget);
      expect(widget.getLabel(menuItem), isNotNull);
      expect(widget.getLabel(menuItem)?.text, equals('Test Widget'));
    });
    test('Activate Dynamic Widgets', () {
      final game = Game('Activate Dynamic Widgets');
      final widget = DynamicWidget((menuItem) => emptyMessage);
      final menu = Menu(
          game: game,
          title: emptyMessage,
          items: [MenuItem(emptyMessage, widget)])
        ..down();
      expect(menu.currentMenuItem?.widget, equals(widget));
      menu.activate();
    });
  });
  group('SimpleMenuItem', () {
    const label = 'Test Label';
    // ignore: prefer_function_declarations_over_variables
    final onActivate = () {};
    const selectSound = AssetReference.file('select.wav');
    const activateSound = AssetReference.file('activate.wav');
    test('Initialise', () {
      final menuItem = SimpleMenuItem(label, onActivate,
          activateSound: activateSound, selectSound: selectSound);
      expect(
          menuItem.label,
          predicate((value) =>
              value is Message &&
              value.keepAlive == true &&
              value.sound == selectSound &&
              value.text == label));
      expect(
          menuItem.widget,
          predicate((value) =>
              value is Button &&
              value.activateSound == activateSound &&
              value.onActivate == onActivate));
    });
  });
}
