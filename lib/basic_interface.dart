// ignore_for_file: avoid_print
/// Provides the [BasicInterface] class.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'src/directions.dart';
import 'src/extensions.dart';
import 'src/math.dart';
import 'src/runner.dart';
import 'ziggurat.dart';

/// The type of the hotkeys dictionary.
typedef CommandsDict = Map<String, void Function()>;

/// A basic command line interface for working with a single runner.
class BasicInterface extends EventLoop {
  /// Create an interface.
  BasicInterface(Runner runner, this.echoSound, {CommandsDict? hotkeys})
      : _commandsQueue = [],
        _commands = hotkeys ?? {},
        super(runner) {
    <String, void Function()>{
      'p': () {
        if (state == EventLoopState.running) {
          pause();
          print('Paused.');
        } else if (state == EventLoopState.paused) {
          unpause();
          print('Unpaused.');
        }
      },
      'q': stop,
      'c': () {
        final c = runner.coordinates.floor();
        print('${c.x}, ${c.y}');
      },
      'x': () {
        final b = runner.currentBox;
        if (b != null) {
          final x =
              (100 / b.width * (runner.coordinates.x - b.start.x)).round();
          final y =
              (100 / b.height * (runner.coordinates.y - b.start.y)).round();
          print('${b.name} ($x%, $y%)');
        }
      },
      'f': () {
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
        print(directions[index]);
      },
      'w': runner.move,
      'd': () => runner.turn(45),
      'a': () => runner.turn(-45),
      's': () => runner.move(
          bearing: normaliseAngle(runner.heading + Directions.south),
          distance: 0.5),
      'z': () {
        final source = runner.playSound(echoSound, reverb: false);
        runner.playWallEchoes(source);
      }
    }.forEach((key, value) {
      if (_commands.containsKey(key) == false) {
        _commands[key] = value;
      }
    });
  }

  /// The sound to play as an echo sound with the z key.
  final SoundReference echoSound;

  /// Link keyboard keys to commands.
  final CommandsDict _commands;

  /// The command queue.
  final List<void Function()> _commandsQueue;

  /// The [stdin] listener.
  StreamSubscription<List<int>>? stdinListener;

  /// Run the interface.
  @override
  Stream<int> run() async* {
    stdin
      ..echoMode = false
      ..lineMode = false;
    stdinListener = stdin.listen((event) {
      final key = utf8.decode(event);
      final command = _commands[key];
      if (command != null) {
        _commandsQueue.add(command);
      }
    });
    yield* super.run();
  }

  /// Tick the game.
  @override
  void tick() {
    while (_commandsQueue.isNotEmpty) {
      _commandsQueue.removeLast()();
    }
    if (state == EventLoopState.stopped) {
      print('Goodbye.');
      runner.stop();
      runner.bufferStore.clear(includeProtected: true);
      runner.context.destroy();
      runner.context.synthizer.shutdown();
      stdinListener?.cancel();
    }
  }
}
