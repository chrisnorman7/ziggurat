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
      menu = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        position: 0,
        items: [
          const MenuItem(Message(text: 'Label')),
          MenuItem(
            const Message(),
            activator: MenuItemActivator(onActivate: () {}),
          )
        ],
      );
      expect(menu.currentMenuItem, equals(menu.menuItems.first));
    });
    test('Using Menus', () {
      var i = 0;
      final menu = Menu(
        game: game,
        title: const Message(text: 'Test Menu'),
        items: [
          const MenuItem(Message(text: 'First Item')),
          MenuItem(
            const Message(text: 'Second Item'),
            activator: MenuItemActivator(
              onActivate: () => i++,
            ),
          ),
          MenuItem(
            const Message(text: 'Quit'),
            activator: MenuItemActivator(onActivate: game.stop),
          )
        ],
      );
      expect(menu.menuItems.length, equals(3));
      final firstItem = menu.menuItems.first;
      expect(firstItem.label.text, equals('First Item'));
      expect(firstItem.activator, null);
      final selectItem = menu.menuItems[1];
      expect(selectItem.activator, isNotNull);
      final quitItem = menu.menuItems.last;
      final activator = quitItem.activator;
      expect(activator!.onActivate, game.stop);
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
      expect(i, 1);
      menu.activate();
      expect(i, 2);
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
        items: [
          MenuItem(
            const Message(),
            activator: MenuItemActivator(
              onActivate: () => activate++,
            ),
          )
        ],
      );
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
        items: [const MenuItem(Message(text: 'First Item'))],
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
          const MenuItem(Message(sound: sound1)),
          const MenuItem(Message(sound: sound2))
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
    test('.onPop', () {
      final menu = Menu(
        game: game,
        title: const Message(),
        items: [
          const MenuItem(
            Message(sound: AssetReference.file('file1.wav')),
          ),
          const MenuItem(
            Message(sound: AssetReference.file('file2.wav'), keepAlive: true),
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
        const MenuItem(Message(text: 'First Item')),
        const MenuItem(Message(text: 'Second Item'))
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
            activator: MenuItemActivator(
              onActivate: () => quit++,
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
}
