/// A quick example.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/menus.dart';
import 'package:ziggurat/src/sound/backend/synthizer/buffer_cache.dart';
import 'package:ziggurat/src/sound/backend/synthizer/synthizer_sound_backend.dart';
import 'package:ziggurat/ziggurat.dart';

const sound = AssetReference.file('sound.wav');
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
const rightCommandTrigger = CommandTrigger(
  name: 'right',
  description: 'Increase the coordinate',
  keyboardKey: CommandKeyboardKey(ScanCode.right),
  button: GameControllerButton.dpadRight,
);
const upCommandTrigger = CommandTrigger(
  name: 'up',
  description: 'Move up in the menu',
  keyboardKey: CommandKeyboardKey(ScanCode.up),
  button: GameControllerButton.dpadUp,
);
const downCommandTrigger = CommandTrigger(
  name: 'down',
  description: 'Move down in a menu',
  keyboardKey: CommandKeyboardKey(ScanCode.down),
  button: GameControllerButton.dpadDown,
);

/// A level with some commands registered.
class ExcitingLevel extends Level {
  /// Create the level.
  ExcitingLevel(final Game game)
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
          game.outputMessage(
            Message(
              sound: sound,
              text: 'Left: $coordinate',
            ),
          );
        },
        interval: 500,
      ),
    );
    registerCommand(
      rightCommandTrigger.name,
      Command(
        onStart: () {
          coordinate++;
          game.outputMessage(
            Message(
              sound: sound,
              text: 'Right: $coordinate',
            ),
          );
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
  MainMenu(final Game game)
      : super(
          game: game,
          title: const Message(text: 'Main Menu'),
          items: [
            MenuItem(
              const Message(text: 'Play'),
              Button(() => game.replaceLevel(ExcitingLevel(game))),
            ),
            MenuItem(
              const Message(text: 'Quit'),
              Button(game.stop),
            )
          ],
          onCancel: () => game.outputText('You cannot exit from this menu.'),
        );
}

Future<void> main() async {
  final sdl = Sdl()..init();
  final synthizer = Synthizer()..initialize();
  final context = synthizer.createContext();
  final random = Random();
  final bufferCache = BufferCache(
    synthizer: synthizer,
    maxSize: 1.gb,
    random: random,
  );
  final sounds = SynthizerSoundBackend(
    context: context,
    bufferCache: bufferCache,
  );
  final game = Game(
    title: 'Ziggurat Example',
    sdl: sdl,
    soundBackend: sounds,
    triggerMap: TriggerMap([
      quitCommandTrigger,
      CommandTrigger.basic(
        name: quitCommandTrigger.name,
        description: 'Quit the game',
        scanCode: ScanCode.escape,
      ),
      leftCommandTrigger,
      rightCommandTrigger,
      upCommandTrigger,
      downCommandTrigger,
    ]),
  );
  final level = MainMenu(game);
  try {
    await game.run(
      onStart: () => game.pushLevel(level),
    );
  } finally {
    sdl.quit();
    sounds.shutdown();
  }
}
