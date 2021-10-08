/// A quick example.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:ziggurat/ziggurat.dart';

const quitCommandName = 'quit';
const upCommandName = 'up';
const downCommandName = 'down';
const activateCommandName = 'activate';
const cancelCommandName = 'cancel';
const leftCommandName = 'left';
const rightCommandName = 'right';

/// A level with some commands registered.
class ExcitingLevel extends Level {
  /// Create the level.
  ExcitingLevel(Game game)
      : coordinate = 0,
        super(game) {
    registerCommand(quitCommandName,
        Command(onStart: () => game.replaceLevel(MainMenu(game))));
    registerCommand(
        leftCommandName,
        Command(
            onStart: () {
              coordinate--;
              game.outputText('Left: $coordinate');
            },
            interval: 500));
    registerCommand(
        rightCommandName,
        Command(
            onStart: () {
              coordinate++;
              game.outputText('Right: $coordinate');
            },
            interval: 500));
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
              MenuItem(Message(text: 'Play'),
                  Button(() => game.replaceLevel(ExcitingLevel(game)))),
              MenuItem(Message(text: 'Quit'), Button(() => game.stop()))
            ],
            onCancel: () => game.outputText('You cannot exit from this menu.'));
}

Future<void> main() async {
  final sdl = Sdl()..init();
  final game = Game('Ziggurat Example',
      triggerMap: TriggerMap([
        CommandTrigger.basic(
            name: quitCommandName,
            description: 'Quit the game',
            scanCode: ScanCode.SCANCODE_Q,
            button: GameControllerButton.leftshoulder),
        CommandTrigger.basic(
            name: quitCommandName,
            description: 'Quit the game',
            scanCode: ScanCode.SCANCODE_ESCAPE),
        CommandTrigger.basic(
            name: leftCommandName,
            description: 'Decrease the coordinate',
            scanCode: ScanCode.SCANCODE_LEFT,
            button: GameControllerButton.dpadLeft),
        CommandTrigger(
            name: rightCommandName,
            description: 'Increase the coordinate',
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_RIGHT),
            button: GameControllerButton.dpadRight),
        CommandTrigger(
            name: upCommandName,
            description: 'Move up in the menu',
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_UP),
            button: GameControllerButton.dpadUp),
        CommandTrigger(
            name: downCommandName,
            description: 'Move down in a menu',
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_DOWN),
            button: GameControllerButton.dpadDown),
      ]));
  final level = MainMenu(game);
  game.pushLevel(level);
  await game.run(sdl);
}
