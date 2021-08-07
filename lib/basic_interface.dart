/// Provides the [BasicInterface] class.
import 'package:dart_sdl/dart_sdl.dart';

import 'src/command.dart';
import 'src/directions.dart';
import 'src/event_loop.dart';
import 'src/extensions.dart';
import 'src/json/sound_reference.dart';
import 'src/math.dart';
import 'src/runner.dart';

/// A basic command line interface for working with a single runner.
class BasicInterface extends EventLoop {
  /// Create an interface.
  BasicInterface(Sdl sdl, Runner runner, this.echoSound) : super(sdl) {
    commandHandler = CommandHandler([
      Command(
          name: 'pause',
          description: 'Pause or unpause the game',
          button: GameControllerButton.rightShoulder,
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_P),
          onStart: () {
            if (state == EventLoopState.running) {
              pause();
              runner.outputText('Paused.');
            } else if (state == EventLoopState.paused) {
              unpause();
              runner.outputText('Unpaused.');
            }
          }),
      Command(
          name: 'quit',
          description: 'Quit the game',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_Q),
          button: GameControllerButton.leftShoulder,
          onStart: () {
            runner
              ..outputText('Goodbye.')
              ..stop()
              ..bufferStore.clear(includeProtected: true)
              ..context.destroy()
              ..context.synthizer.shutdown();
            stop();
          }),
      Command(
          name: 'coordinates',
          description: 'Show current coordinates',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_C),
          button: GameControllerButton.y,
          onStart: () {
            final c = runner.coordinates.floor();
            runner.outputText('${c.x}, ${c.y}');
          }),
      Command(
          name: 'describeCurrentBox',
          description: "Describe the player's position within the current box",
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_C, shiftKey: true),
          button: GameControllerButton.x,
          onStart: () {
            final b = runner.currentBox;
            if (b != null) {
              final x =
                  (100 / b.width * (runner.coordinates.x - b.start.x)).round();
              final y =
                  (100 / b.height * (runner.coordinates.y - b.start.y)).round();
              runner.outputText('${b.name} ($x%, $y%)');
            }
          }),
      Command(
          name: 'showFacing',
          description: 'Show which direction the player is facing in',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_F),
          button: GameControllerButton.a,
          onStart: () {
            final directions = <String>[
              'north',
              'northeast',
              'east',
              'southeast',
              'south',
              'southwest',
              'west',
              'northwest'
            ];
            final index = (((runner.heading % 360) < 0
                            ? runner.heading + 360
                            : runner.heading) /
                        45)
                    .round() %
                directions.length;
            runner.outputText(directions[index]);
          }),
      Command(
          name: 'moveForward',
          description: 'Move forwards',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_W),
          button: GameControllerButton.dpadUp,
          onStart: runner.move),
      Command(
          name: 'turnEast',
          description: 'Turn 45 degrees east',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_RIGHT),
          button: GameControllerButton.dpadRight,
          onStart: () => runner.turn(45)),
      Command(
          name: 'turnWest',
          description: 'Turn 45 degrees west',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_LEFT),
          button: GameControllerButton.dpadLeft,
          onStart: () => runner.turn(-45)),
      Command(
          name: 'moveBackwards',
          description: 'Move backwards',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_S),
          button: GameControllerButton.dpadDown,
          onStart: () => runner.move(
              bearing: normaliseAngle(runner.heading + Directions.south),
              distance: 0.5)),
      Command(
          name: 'playEchoSound',
          description: 'Play the echo sound',
          keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_Z),
          button: GameControllerButton.b,
          onStart: () {
            final source = runner.playSound(echoSound, reverb: false);
            runner.playWallEchoes(source);
          })
    ]);
  }

  /// The sound to play as an echo sound with the z key.
  final SoundReference echoSound;
}
