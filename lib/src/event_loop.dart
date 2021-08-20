/// Provides the [EventLoop] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:meta/meta.dart';

import 'box_map/box.dart';
import 'box_map/box_types/door.dart';
import 'command.dart';
import 'directions.dart';
import 'error.dart';
import 'extensions.dart';
import 'json/command_trigger.dart';
import 'json/message.dart';
import 'json/sound_reference.dart';
import 'math.dart';
import 'menu/menu.dart';
import 'runner.dart';
import 'sound/buffer_store.dart';

/// The state of an [EventLoop] instance.
enum EventLoopState {
  /// The instance has not yet had its [EventLoop.run] method called.
  notStarted,

  /// The event loop is running normally.
  running,

  /// The event loop has been paused with the [EventLoop.pause] method.
  paused,

  /// The event loop has been stopped with its [EventLoop.stop] method.
  stopped,
}

/// An event loop.
///
/// Instances of this class can be used to run the game without relying on any
/// asynchronous code.
class EventLoop<T> {
  /// Create a loop.
  EventLoop(
      {required this.context,
      required this.bufferStore,
      required this.sdl,
      required this.commandHandler,
      required this.gameState,
      int framesPerSecond = 60})
      : _menu = null,
        _state = EventLoopState.notStarted,
        _timeBetweenTicks = (1000 / framesPerSecond).floor();

  /// The synthizer context to use.
  final Context context;

  /// The sdl bindings to use.
  final Sdl sdl;

  /// The buffer store to use.
  final BufferStore bufferStore;

  /// The command handler to use in this loop.
  CommandHandler commandHandler;

  /// The current state of the game.
  ///
  /// This object can be anything, and should probably be loaded from JSON or
  /// similar.
  final T gameState;

  /// The runner to be used by this loop.
  Runner? runner;

  Menu? _menu;

  /// The current menu for this event loop.
  Menu? get menu => _menu;

  /// Set the menu.
  set menu(Menu? m) {
    _menu = m;
    if (m != null) {
      outputMessage(m.title);
    }
  }

  EventLoopState _state;

  /// How often to wait between ticks.
  final int _timeBetweenTicks;

  /// The state of this loop.
  EventLoopState get state => _state;

  /// Returns `true` if [state] is either [EventLoopState.running] or
  /// [EventLoopState.paused].
  bool get isRunning =>
      _state == EventLoopState.paused || _state == EventLoopState.running;

  /// Start the event loop.
  @mustCallSuper
  Stream<Event> run() async* {
    if (_state != EventLoopState.notStarted) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.running;
    var tickStart = 0;
    var tickEnd = DateTime.now().millisecondsSinceEpoch;
    while (isRunning) {
      tickStart = DateTime.now().millisecondsSinceEpoch;
      yield* tick(tickStart - tickEnd, tickStart);
      tickEnd = DateTime.now().millisecondsSinceEpoch;
      final tickTime = tickEnd - tickStart;
      if (tickTime < _timeBetweenTicks) {
        await Future<void>.delayed(
            Duration(milliseconds: _timeBetweenTicks - tickTime));
      }
    }
  }

  /// Pause the loop.
  @mustCallSuper
  void pause() {
    if (_state != EventLoopState.running) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.paused;
  }

  /// Unpause (resume) the loop.
  @mustCallSuper
  void unpause() {
    if (_state != EventLoopState.paused) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.running;
  }

  /// Stop the loop entirely.
  ///
  /// The [run] method will need to be used to restart this instance.
  @mustCallSuper
  void stop() {
    if (_state != EventLoopState.running && _state != EventLoopState.paused) {
      throw InvalidStateError(this);
    }
    _state = EventLoopState.stopped;
  }

  /// Tick the loop.
  @mustCallSuper
  Stream<Event> tick(int timeDelta, int now) async* {
    // Get SDL events.
    while (true) {
      final event = sdl.pollEvent();
      if (event == null) {
        break;
      }
      yield event;
      if (event is KeyboardEvent) {
        if (event.repeat == false) {
          commandHandler.handleKeyboardEvent(event);
        }
      } else if (event is ControllerButtonEvent) {
        commandHandler.handleButtonEvent(event);
      }
      final r = runner;
      if (r != null) {
        final walkingState = r.walkingState;
        if (walkingState != null && now >= r.nextMove) {
          r.move(
              distance: walkingState.distance, bearing: walkingState.heading);
        }
        final boxes = r.ziggurat?.boxes;
        if (boxes != null) {
          for (final box in boxes) {
            if (box is Box<Door>) {
              final closeWhen = box.type.closeWhen;
              if (closeWhen != null && now >= closeWhen) {
                r.closeDoor(box.type, box.type.closeCoordinates ?? box.centre);
              }
            }
          }
        }
        final randomSounds = r.ziggurat?.randomSounds;
        if (randomSounds != null) {
          for (final randomSound in randomSounds) {
            final nextPlay = randomSound.nextPlay;
            if (nextPlay != null && now >= nextPlay) {
              r.playRandomSound(randomSound);
              randomSound.nextPlay = null;
            }
            if (nextPlay == null) {
              randomSound.nextPlay = now +
                  (randomSound.minInterval +
                      r.random.nextInt(randomSound.maxInterval));
            }
          }
        }
      }
    }
    for (final command in commandHandler.commands.values) {
      if (command.nextRun >= now) {
        commandHandler.startCommand(command, now);
      }
    }
  }

  /// Play a simple sound.
  ///
  /// A sound played via this method is not panned or occluded, but will be
  /// reverberated if [reverb] is `true`.
  DirectSource playSound(SoundReference sound,
      {double gain = 0.7, bool reverb = true}) {
    final s = DirectSource(context)
      ..gain = gain
      ..configDeleteBehavior(linger: true);
    final r = runner;
    if (r != null && reverb) {
      r.reverberateSource(s, r.coordinates.floor());
    }
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: true)
      ..setBuffer(bufferStore.getBuffer(sound.name, sound.type));
    s.addGenerator(g);
    return s;
  }

  /// Play a sound in 3d.
  Source3D playSound3D(SoundReference sound, Point<double> position,
      {double gain = 0.7, bool reverb = true}) {
    final s = Source3D(context)
      ..position = Double3(position.x, position.y, 0.0)
      ..gain = gain
      ..configDeleteBehavior(linger: true);
    final r = runner;
    if (r != null && reverb) {
      r.reverberateSource(s, position.floor());
    }
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: true)
      ..setBuffer(bufferStore.getBuffer(sound.name, sound.type));
    s.addGenerator(g);
    return s;
  }

  /// Output some text.
  void outputText(String text) {
    // ignore: avoid_print
    print(text);
  }

  /// Output [message].
  void outputMessage(Message message,
      {Point<double>? position, bool reverberate = true, bool filter = true}) {
    final r = runner;
    final text = message.text;
    if (text != null &&
        (position == null ||
            r == null ||
            r.getWallsBetween(position.floor()).isEmpty)) {
      outputText(text);
    }
    final sound = message.sound;
    if (sound != null) {
      final Source source;
      if (position == null) {
        source = playSound(sound, gain: message.gain, reverb: reverberate);
      } else {
        final generator = BufferGenerator(context)
          ..setBuffer(bufferStore.getBuffer(sound.name, sound.type))
          ..configDeleteBehavior(linger: true);
        source = Source3D(context)
          ..gain = message.gain
          ..position = Double3(position.x, position.y, 0.0)
          ..addGenerator(generator)
          ..configDeleteBehavior(linger: true);
        final r = runner;
        if (r != null && filter == true) {
          r.filterSource(source, position.floor());
        }
      }
    }
  }

  /// Register default commands.
  void registerDefaultCommands() {
    commandHandler
      ..registerCommand(Command(
          name: 'quit',
          description: 'Quit the game',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_Q),
            button: GameControllerButton.leftShoulder,
          ),
          onStart: () {
            outputText('Goodbye.');
            runner?.stop();
            stop();
            destroy();
          }))
      ..registerCommand(Command(
          name: 'coordinates',
          description: 'Show current coordinates',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_C),
            button: GameControllerButton.y,
          ),
          onStart: () {
            final r = runner;
            if (r == null) {
              return;
            }
            final c = r.coordinates.floor();
            outputText('${c.x}, ${c.y}');
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
            final r = runner;
            if (r == null) {
              return;
            }
            final b = r.currentBox;
            if (b != null) {
              final x = (100 / b.width * (r.coordinates.x - b.start.x)).round();
              final y =
                  (100 / b.height * (r.coordinates.y - b.start.y)).round();
              outputText('${b.name} ($x%, $y%)');
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
            final r = runner;
            if (r == null) {
              return;
            }
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
            final index =
                (((r.heading % 360) < 0 ? r.heading + 360 : r.heading) / 45)
                        .round() %
                    directions.length;
            outputText(directions[index]);
          }))
      ..registerCommand(Command(
          name: 'moveForward',
          description: 'Move forwards',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_W),
            button: GameControllerButton.dpadUp,
          ),
          onStart: () => runner?.move(),
          onStop: () {
            runner?.walkingState = null;
          }))
      ..registerCommand(Command(
          name: 'turnEast',
          description: 'Turn 45 degrees east',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_RIGHT),
            button: GameControllerButton.dpadRight,
          ),
          onStart: () {
            final r = runner;
            if (r != null) {
              r.turn(45);
            }
          }))
      ..registerCommand(Command(
          name: 'turnWest',
          description: 'Turn 45 degrees west',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_LEFT),
            button: GameControllerButton.dpadLeft,
          ),
          onStart: () => runner?.turn(-45)))
      ..registerCommand(Command(
          name: 'moveBackwards',
          description: 'Move backwards',
          defaultTrigger: CommandTrigger(
            keyboardKey: CommandKeyboardKey(ScanCode.SCANCODE_S),
            button: GameControllerButton.dpadDown,
          ),
          onStart: () {
            final r = runner;
            if (r != null) {
              r.move(
                  bearing: normaliseAngle(r.heading + Directions.south),
                  distance: 0.5);
            }
          },
          onStop: () => runner?.walkingState = null))
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

  /// Destroy this event loop.
  void destroy() {
    bufferStore.clear(includeProtected: true);
    context
      ..destroy()
      ..synthizer.shutdown();
    sdl.quit();
  }
}
