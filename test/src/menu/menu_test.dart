import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/sound.dart';
import 'package:ziggurat/ziggurat.dart';

import '../../helpers.dart';

void main() {
  final sdl = Sdl();
  group('Menu', () {
    final game = Game(
      title: 'Menu Testing Game',
      sdl: sdl,
      soundBackend: SilentSoundBackend(),
    );
    test('Initialisation', () {
      var menu = Menu(game: game, title: const Message(text: 'Test Menu'));
      expect(menu.title, isA<Message>());
      expect(menu.menuItems, isEmpty);
      expect(menu.onCancel, isNull);
      expect(menu.currentMenuItem, isNull);
      menu =
          Menu(game: game, title: const Message(text: 'Test Menu'), position: 0)
            ..addLabel(text: 'Label')
            ..addButton(() {});
      expect(menu.currentMenuItem, equals(menu.menuItems.first));
    });
    test('Using Menus', () {
      var menu = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        items: [
          const MenuItem(Message(text: 'First Item'), menuItemLabel),
          MenuItem(
            const Message(text: 'Second Item'),
            ListButton(['First', 'Second', 'Third'], (final value) {}),
          ),
          MenuItem(const Message(text: 'Quit'), Button(game.stop))
        ],
      );
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
      menu.menuItems.add(
        MenuItem(const Message(text: 'Increment'), Button(() => number++)),
      );
      menu
        ..down()
        ..down();
      expect(menu.currentMenuItem!.label.text, equals('Increment'));
      menu.activate();
      expect(number, equals(1));
      menu =
          Menu(game: game, title: const Message(text: 'Default Commands Menu'));
      var value = true;
      final checkbox =
          MenuItem(const Message(), Checkbox((final b) => value = b));
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
        title: const Message(text: 'Test Menu'),
        onCancel: () => cancel++,
      );
      expect(cancel, isZero);
      menu.cancel();
      expect(cancel, equals(1));
    });
    test('.handleSdlEvent', () {
      var cancel = 0;
      var activate = 0;
      final menu = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        onCancel: () => cancel++,
      )..addButton(() => activate++);
      expect(cancel, isZero);
      expect(activate, isZero);
      menu.handleSdlEvent(
        makeKeyboardEvent(sdl, menu.cancelScanCode, KeyCode.escape),
      );
      expect(cancel, isZero);
      expect(menu.currentMenuItem, isNull);
      final downEvent = makeKeyboardEvent(
        sdl,
        ScanCode.down,
        KeyCode.down,
        state: PressedState.pressed,
      );
      menu.handleSdlEvent(downEvent);
      expect(menu.currentMenuItem, equals(menu.menuItems.first));
      menu.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.up,
          KeyCode.up,
          state: PressedState.pressed,
        ),
      );
      expect(menu.currentMenuItem, isNull);
      menu
        ..handleSdlEvent(downEvent)
        ..handleSdlEvent(
          makeKeyboardEvent(
            sdl,
            ScanCode.escape,
            KeyCode.escape,
            state: PressedState.pressed,
          ),
        );
      expect(cancel, equals(1));
      menu.handleSdlEvent(
        makeKeyboardEvent(sdl, ScanCode.space, KeyCode.space),
      );
      expect(activate, isZero);
      menu.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.space,
          KeyCode.space,
          state: PressedState.pressed,
        ),
      );
      expect(activate, equals(1));
    });
    test('Moving with number lock on', () {
      final menu = Menu(
        game: game,
        title: const Message(text: 'Testing With Number Lock'),
        items: [const MenuItem(Message(text: 'First Item'), menuItemLabel)],
      );
      expect(menu.currentMenuItem, isNull);
      menu.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.down,
          KeyCode.down,
          modifiers: {KeyMod.num},
          state: PressedState.pressed,
        ),
      );
      expect(menu.currentMenuItem, menu.menuItems.first);
      menu.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.up,
          KeyCode.up,
          modifiers: {KeyMod.num},
          state: PressedState.pressed,
        ),
      );
      expect(menu.currentMenuItem, isNull);
    });
    test('ListButton', () {
      final menu = Menu(
        game: Game(
          title: 'ListButton',
          sdl: sdl,
          soundBackend: SilentSoundBackend(),
        ),
        title: emptyMessage,
      );
      var newValue = '';
      final listButton = ListButton<String>(
        ['First', 'Second', 'Third'],
        (final value) => newValue = value,
      );
      expect(listButton.index, isZero);
      final menuItem = MenuItem(const Message(text: 'Button'), listButton);
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
      final menu = Menu(
        game: Game(
          title: 'ListButton',
          sdl: sdl,
          soundBackend: SilentSoundBackend(),
        ),
        title: emptyMessage,
      );
      bool? value;
      final checkbox = Checkbox((final b) => value = b);
      expect(checkbox.value, isTrue);
      expect(value, isNull);
      final menuItem = MenuItem(const Message(text: 'Checkbox'), checkbox);
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
      final game = Game(
        title: 'Menu Sounds',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      const sound1 = AssetReference('Sound 1', AssetType.file);
      const sound2 = AssetReference('Sound 2', AssetType.file);
      final menu = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        items: [
          const MenuItem(Message(sound: sound1), menuItemLabel),
          const MenuItem(Message(sound: sound2), menuItemLabel)
        ],
      );
      expect(menu.oldSound, isNull);
      menu.down();
      final oldSound = menu.oldSound;
      expect(oldSound, isNotNull);
      menu.down();
      expect(
        menu.oldSound,
        predicate((final value) => value is Sound && value != oldSound),
      );
      menu.up();
      expect(
        menu.oldSound,
        predicate((final value) => value is Sound && value != oldSound),
      );
      menu.up();
      expect(menu.oldSound, isNull);
    });
    test('Button Widget', () {
      final game = Game(
        title: 'Button Widget',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      var number = 0;
      final button = Button(
        () {
          number++;
        },
        activateSound: const AssetReference.file('something.wav'),
      );
      final menu = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        items: [MenuItem(const Message(text: 'Button'), button)],
      )..activate();
      expect(number, isZero);
      expect(menu.oldSound, isNull);
      menu.down();
      expect(menu.currentMenuItem?.widget, button);
      expect(menu.oldSound, isNull);
      menu.activate();
      expect(number, equals(1));
      expect(menu.oldSound, isNotNull);
    });
    test('.addButton', () {
      final game = Game(
        title: 'Menu.addButton',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final menu = Menu(game: game, title: const Message());
      expect(menu.menuItems, isEmpty);
      var i = 0;
      const activateSound = AssetReference.file('activate.wav');
      const selectSound = AssetReference.file('select.wav');
      final item = menu.addButton(
        () => i++,
        activateSound: activateSound,
        label: 'Activate',
        selectSound: selectSound,
      );
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
      final game = Game(
        title: 'Menu.addLabel',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final menu = Menu(game: game, title: const Message());
      const selectSound = AssetReference.file('select.wav');
      final item = menu.addLabel(text: 'Testing', selectSound: selectSound);
      expect(item.label.text, equals('Testing'));
      expect(item.label.sound, equals(selectSound));
      expect(item.widget, equals(menuItemLabel));
    });
    test('.onPop', () {
      final menu = Menu(
        game: game,
        title: const Message(),
        items: [
          const MenuItem(
            Message(sound: AssetReference.file('file1.wav')),
            menuItemLabel,
          ),
          const MenuItem(
            Message(sound: AssetReference.file('file2.wav'), keepAlive: true),
            menuItemLabel,
          )
        ],
      );
      game.pushLevel(menu);
      expect(game.currentLevel, equals(menu));
      expect(menu.oldSound, isNull);
      menu.down();
      expect(menu.oldSound, isNotNull);
      game.popLevel();
      expect(game.currentLevel, isNull);
      expect(menu.oldSound, isNull);
      game.pushLevel(menu);
      expect(game.currentLevel, equals(menu));
      expect(menu.oldSound, isNotNull);
      menu.down();
      expect(menu.oldSound, isNotNull);
      game.popLevel();
      expect(game.currentLevel, isNull);
      expect(menu.oldSound, isNull);
    });
    test('Searching', () async {
      final menuItems = [
        const MenuItem(Message(text: 'First Item'), menuItemLabel),
        const MenuItem(Message(text: 'Second Item'), menuItemLabel)
      ];
      var menu = Menu(
        game: game,
        title: const Message(),
        items: menuItems,
        searchInterval: 20,
      );
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
      await Future<void>.delayed(const Duration(milliseconds: 25));
      menu.handleSdlEvent(makeTextInputEvent(sdl, 's'));
      expect(menu.searchString, equals('s'));
      expect(menu.currentMenuItem, equals(menuItems.last));
      menu = Menu(
        game: game,
        title: menu.title,
        items: menuItems,
        searchEnabled: false,
      );
      expect(menu.searchEnabled, isFalse);
      menu.handleSdlEvent(makeTextInputEvent(sdl, 'asdf'));
      expect(menu.searchString, isEmpty);
    });
    test('Moving in an empty menu', () {
      final menu = Menu(game: game, title: const Message());
      expect(menu.menuItems, isEmpty);
      expect(menu.currentMenuItem, isNull);
      menu.down();
      expect(menu.currentMenuItem, isNull);
    });
    test('Menu commands', () {
      const quitCommand = CommandTrigger(
        name: 'quit',
        description: 'Quit the game',
        keyboardKey: CommandKeyboardKey(ScanCode.q),
      );
      const helpCommand = CommandTrigger(
        name: 'help',
        description: 'Get help',
        keyboardKey: CommandKeyboardKey(
          ScanCode.f1,
        ),
      );
      final game = Game(
        title: 'Test Menu Game',
        sdl: sdl,
        triggerMap: const TriggerMap(
          [
            quitCommand,
            helpCommand,
          ],
        ),
        soundBackend: SilentSoundBackend(),
      );
      var quit = 0;
      final m = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        items: [
          MenuItem(
            const Message(text: 'Quit'),
            Button(
              () => quit++,
            ),
          )
        ],
      );
      game.pushLevel(m);
      expect(m.position, isNull);
      var command = 0;
      m.registerCommand(
        quitCommand.name,
        Command(
          onStart: () => command++,
        ),
      );
      var help = 0;
      m.registerCommand(
        helpCommand.name,
        Command(
          onStart: () => help++,
        ),
      );
      game.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.f1,
          KeyCode.f1,
          state: PressedState.pressed,
        ),
      );
      expect(help, 1);
      expect(quit, isZero);
      expect(command, isZero);
      game.handleSdlEvent(
        makeKeyboardEvent(
          sdl,
          ScanCode.q,
          KeyCode.q,
          state: PressedState.pressed,
        ),
      );
      expect(command, 1);
      expect(help, 1);
      expect(quit, isZero);
    });
  });
  group('MenuItem', () {
    test('DynamicWidget', () {
      final widget =
          DynamicWidget((final menuItem) => const Message(text: 'Test Widget'));
      final menuItem = MenuItem(const Message(), widget);
      expect(widget.getLabel(menuItem), isNotNull);
      expect(widget.getLabel(menuItem)?.text, equals('Test Widget'));
    });
    test('Activate Dynamic Widgets', () {
      final game = Game(
        title: 'Activate Dynamic Widgets',
        sdl: sdl,
        soundBackend: SilentSoundBackend(),
      );
      final widget = DynamicWidget((final menuItem) => emptyMessage);
      final menu = Menu(
        game: game,
        title: emptyMessage,
        items: [MenuItem(emptyMessage, widget)],
      )..down();
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
      final menuItem = SimpleMenuItem(
        label,
        onActivate,
        activateSound: activateSound,
        selectSound: selectSound,
      );
      expect(
        menuItem.label,
        predicate(
          (final value) =>
              value is Message &&
              value.keepAlive == true &&
              value.sound == selectSound &&
              value.text == label,
        ),
      );
      expect(
        menuItem.widget,
        predicate(
          (final value) =>
              value is Button &&
              value.activateSound == activateSound &&
              value.onActivate == onActivate,
        ),
      );
    });
  });
}
