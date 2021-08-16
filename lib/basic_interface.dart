/// Provides the [BasicInterface] class.
import 'package:dart_sdl/dart_sdl.dart';

import 'src/box.dart';
import 'src/box_types/door.dart';
import 'src/command.dart';
import 'src/directions.dart';
import 'src/event_loop.dart';
import 'src/extensions.dart';
import 'src/json/command_trigger.dart';
import 'src/json/sound_reference.dart';
import 'src/math.dart';
import 'src/runner.dart';

/// A basic command line interface for working with a single runner.
class BasicInterface extends EventLoop {
  /// Create an interface.
  BasicInterface(Sdl sdl, this.runner, this.echoSound)
      : super(sdl, CommandHandler()) {
    commandHandler
      ..registerCommand(Command(
          name: 'pause',
          description: 'Pause or unpause the game',
          defaultTrigger: CommandTrigger(
            button: GameControllerButton.rightShoulder,
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_P),
          ),
          onStart: () {
            if (state == EventLoopState.running) {
              pause();
              runner.outputText('Paused.');
            } else if (state == EventLoopState.paused) {
              unpause();
              runner.outputText('Unpaused.');
            }
          }))
      ..registerCommand(Command(
          name: 'quit',
          description: 'Quit the game',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_Q),
            button: GameControllerButton.leftShoulder,
          ),
          onStart: () {
            runner
              ..outputText('Goodbye.')
              ..stop()
              ..bufferStore.clear(includeProtected: true)
              ..context.destroy()
              ..context.synthizer.shutdown();
            stop();
          }))
      ..registerCommand(Command(
          name: 'coordinates',
          description: 'Show current coordinates',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_C),
            button: GameControllerButton.y,
          ),
          onStart: () {
            final c = runner.coordinates.floor();
            runner.outputText('${c.x}, ${c.y}');
          }))
      ..registerCommand(Command(
          name: 'describeCurrentBox',
          description: "Describe the player's position within the current box",
          defaultTrigger: CommandTrigger(
            button: GameControllerButton.x,
            keyboardKey:
                CommandKeyboardKey(ScanCode.SCANCODE_C, shiftKey: true),
          ),
          onStart: () {
            final b = runner.currentBox;
            if (b != null) {
              final x =
                  (100 / b.width * (runner.coordinates.x - b.start.x)).round();
              final y =
                  (100 / b.height * (runner.coordinates.y - b.start.y)).round();
              runner.outputText('${b.name} ($x%, $y%)');
            }
          }))
      ..registerCommand(Command(
          name: 'showFacing',
          description: 'Show which direction the player is facing in',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_F),
            button: GameControllerButton.a,
          ),
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
          }))
      ..registerCommand(Command(
          name: 'moveForward',
          description: 'Move forwards',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_W),
            button: GameControllerButton.dpadUp,
          ),
          onStart: runner.move,
          onStop: () {
            runner.walkingState = null;
          }))
      ..registerCommand(Command(
          name: 'turnEast',
          description: 'Turn 45 degrees east',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_RIGHT),
            button: GameControllerButton.dpadRight,
          ),
          onStart: () => runner.turn(45)))
      ..registerCommand(Command(
          name: 'turnWest',
          description: 'Turn 45 degrees west',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_LEFT),
            button: GameControllerButton.dpadLeft,
          ),
          onStart: () => runner.turn(-45)))
      ..registerCommand(Command(
          name: 'moveBackwards',
          description: 'Move backwards',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_S),
            button: GameControllerButton.dpadDown,
          ),
          onStart: () => runner.move(
              bearing: normaliseAngle(runner.heading + Directions.south),
              distance: 0.5),
          onStop: () => runner.walkingState = null))
      ..registerCommand(Command(
          name: 'playEchoSound',
          description: 'Play the echo sound',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_Z),
            button: GameControllerButton.b,
          ),
          onStart: () {
            final source = runner.playSound(echoSound, reverb: false);
            runner.playWallEchoes(source);
          }))
      ..registerCommand(Command(
          name: 'menuUp',
          description: 'Move up in a menu',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_UP),
            button: GameControllerButton.dpadUp,
          ),
          onStart: () {
            final m = menu;
            if (m != null) {
              m.up();
            }
          }))
      ..registerCommand(
        Command(
            name: 'menuDown',
            description: 'Move down in a menu',
            defaultTrigger: CommandTrigger(
              keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_DOWN),
              button: GameControllerButton.dpadDown,
            ),
            onStart: () {
              final m = menu;
              if (m != null) {
                m.down();
              }
            }),
      )
      ..registerCommand(Command(
          name: 'menuActivate',
          description: 'Activate a menu item',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_RETURN),
            button: GameControllerButton.dpadRight,
          ),
          onStart: () {
            final m = menu;
            if (m != null) {
              m.activate();
            }
          }))
      ..registerCommand(Command(
          name: 'menuCancel',
          description: 'Cancel the current menu',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_ESCAPE),
            button: GameControllerButton.dpadLeft,
          ),
          onStart: () {
            final m = menu;
            if (m != null) {
              m.cancel();
            }
          }));
  }

  /// The runner to use.
  final Runner runner;

  /// The sound to play as an echo sound with the z key.
  final SoundReference echoSound;

  /// Override the tick.
  @override
  Stream<Event> tick(int timeDelta, int now) async* {
    yield* super.tick(timeDelta, now);
    final walkingState = runner.walkingState;
    if (walkingState != null && now >= runner.nextMove) {
      runner.move(
          distance: walkingState.distance, bearing: walkingState.heading);
    }
    final boxes = runner.ziggurat?.boxes;
    if (boxes != null) {
      for (final box in boxes) {
        if (box is Box<Door>) {
          final closeWhen = box.type.closeWhen;
          if (closeWhen != null && now >= closeWhen) {
            runner.closeDoor(box.type, box.type.closeCoordinates ?? box.centre);
          }
        }
      }
    }
    final randomSounds = runner.ziggurat?.randomSounds;
    if (randomSounds != null) {
      for (final randomSound in randomSounds) {
        final nextPlay = randomSound.nextPlay;
        if (nextPlay != null && now >= nextPlay) {
          runner.playRandomSound(randomSound);
          randomSound.nextPlay = null;
        }
        if (nextPlay == null) {
          randomSound.nextPlay = now +
              (randomSound.minInterval +
                  runner.random.nextInt(randomSound.maxInterval));
        }
      }
    }
  }
}
