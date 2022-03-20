/// A quick example.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/ziggurat.dart';

final quitCommandTrigger = CommandTrigger.basic(
  name: 'quit',
  description: 'Quit the game',
  scanCode: ScanCode.q,
  button: GameControllerButton.leftshoulder,
);
final leftCommandTrigger = CommandTrigger.basic(
  name: 'left',
  description: 'Decrease the coordinate',
  scanCode: ScanCode.left,
  button: GameControllerButton.dpadLeft,
);
final rightCommandTrigger = CommandTrigger(
  name: 'right',
  description: 'Increase the coordinate',
  keyboardKey: CommandKeyboardKey(ScanCode.right),
  button: GameControllerButton.dpadRight,
);
final upCommandTrigger = CommandTrigger(
  name: 'up',
  description: 'Move up in the menu',
  keyboardKey: CommandKeyboardKey(ScanCode.up),
  button: GameControllerButton.dpadUp,
);
final downCommandTrigger = CommandTrigger(
  name: 'down',
  description: 'Move down in a menu',
  keyboardKey: CommandKeyboardKey(ScanCode.down),
  button: GameControllerButton.dpadDown,
);

/// A level with some commands registered.
class ExcitingLevel extends Level {
  /// Create the level.
  ExcitingLevel(Game game)
      : coordinate = 0,
        super(game: game) {
    registerCommand(
      quitCommandTrigger.name,
      Command(
        onStart: () => game.replaceLevel(MainMenu(game)),
      ),
    );
    registerCommand(
      leftCommandTrigger.name,
      Command(
        onStart: () {
          coordinate--;
          game.outputText('Left: $coordinate');
        },
        interval: 500,
      ),
    );
    registerCommand(
      rightCommandTrigger.name,
      Command(
        onStart: () {
          coordinate++;
          game.outputText('Right: $coordinate');
        },
        interval: 500,
      ),
    );
  }

  /// The x/y coordinate.
  int coordinate;
}

/// The main menu.
class MainMenu extends Menu {
  /// Create the menu.
  MainMenu(Game game)
      : super(
          game: game,
          title: Message(text: 'Main Menu'),
          items: [
            MenuItem(
              Message(text: 'Play'),
              Button(() => game.replaceLevel(ExcitingLevel(game))),
            ),
            MenuItem(
              Message(text: 'Quit'),
              Button(() => game.stop()),
            )
          ],
          onCancel: () => game.outputText('You cannot exit from this menu.'),
        );
}

Future<void> main() async {
  final sdl = Sdl()..init();
  final game = Game(
    'Ziggurat Example',
    triggerMap: TriggerMap([
      quitCommandTrigger,
      CommandTrigger.basic(
          name: quitCommandTrigger.name,
          description: 'Quit the game',
          scanCode: ScanCode.escape),
      leftCommandTrigger,
      rightCommandTrigger,
      upCommandTrigger,
      downCommandTrigger,
    ]),
  );
  final level = MainMenu(game);
  await game.run(
    sdl,
    onStart: () => game.pushLevel(level),
  );
}
