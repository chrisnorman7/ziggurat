/// Provides the [Game] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import 'json/message.dart';
import 'json/trigger_map.dart';
import 'levels/level.dart';
import 'task.dart';

/// The main game object.
class Game {
  /// Create an instance.
  Game(this.title, {TriggerMap? triggerMap})
      : _levels = [],
        triggerMap = triggerMap ?? TriggerMap({}),
        time = 0,
        _isRunning = false,
        tasks = [];

  /// The title of this game.
  ///
  /// This value will be used to determine the title of the resulting window.
  final String title;

  /// The level stack of this game.
  final List<Level> _levels;

  /// Get the current level.
  ///
  /// This is the level which is last in the levels stack.
  Level? get currentLevel => _levels.isEmpty ? null : _levels.last;

  /// The trigger map.
  final TriggerMap triggerMap;

  /// The sdl window that will be shown when the [run] method is called.
  Window? window;

  /// Game time.
  int time;

  bool _isRunning;

  /// Whether or not this game is running.
  bool get isRunning => _isRunning;

  /// The tasks which have been registered using [registerTask].
  final List<Task> tasks;

  /// Register a new task.
  ///
  /// This method is shorthand for:
  ///
  /// ```
  /// task = Task(game.time + runAfter, func);
  /// ```
  Task registerTask(int runAfter, void Function() func, {int? interval}) {
    final task = Task(time + runAfter, interval, func);
    tasks.add(task);
    return task;
  }

  /// Push a level onto the stack.
  void pushLevel(Level level) {
    final cl = currentLevel;
    level.onPush();
    _levels.add(level);
    if (cl != null) {
      cl.onCover(level);
    }
  }

  /// Pop the most recent level.
  Level? popLevel() {
    if (_levels.isNotEmpty) {
      final oldLevel = _levels.removeLast()..onPop();
      final cl = currentLevel;
      if (cl != null) {
        cl.onReveal(oldLevel);
      }
      return oldLevel;
    }
  }

  /// Handle SDL events.
  ///
  ///This method will be passed one event at a time.
  @mustCallSuper
  void handleSdlEvent(Event event) {
    if (event is QuitEvent) {
      stop();
    } else if (event is ControllerDeviceEvent) {
      if (event.state == DeviceState.added) {
        event.sdl.openGameController(event.joystickId);
      }
    } else {
      final level = currentLevel;
      if (level != null) {
        for (final element in triggerMap.triggers.entries) {
          final name = element.key;
          final commandTrigger = element.value;
          final key = commandTrigger.keyboardKey;
          final button = commandTrigger.button;
          if ((event is KeyboardEvent &&
                  key != null &&
                  event.key.scancode == key.scanCode &&
                  event.key.alt == key.altKey &&
                  event.key.ctrl == key.controlKey &&
                  event.key.shift == key.shiftKey &&
                  event.repeat == false) ||
              (event is ControllerButtonEvent &&
                  button != null &&
                  event.button == button)) {
            final PressedState state;
            if (event is KeyboardEvent) {
              state = event.state;
            } else if (event is ControllerButtonEvent) {
              state = event.state;
            } else {
              throw Exception('Internal error.');
            }
            switch (state) {
              case PressedState.pressed:
                level.startCommand(name);
                break;
              case PressedState.released:
                level.stopCommand(name);
                break;
            }
          }
        }
        level.handleSdlEvent(event);
      }
    }
  }

  /// Tick this game.
  ///
  /// The [timeDelta] argument will be the number of milliseconds since the last
  /// tick. If the game hasn't ticked before, then this value will be 0.
  @mustCallSuper
  void tick(Sdl sdl, int timeDelta) {
    Event? event;
    do {
      event = sdl.pollEvent();
      if (event != null) {
        handleSdlEvent(event);
      }
    } while (event != null);
    final level = currentLevel;
    if (level != null) {
      for (final entry in level.commands.entries) {
        final name = entry.key;
        final command = entry.value;
        if (command.isRunning &&
            command.nextRun != 0 &&
            time > command.nextRun) {
          level.startCommand(name);
        }
      }
    }
    final completedTasks = <Task>[];
    for (final task in tasks) {
      if (time >= task.runWhen) {
        task.func();
        final interval = task.interval;
        if (interval == null) {
          completedTasks.add(task);
        } else {
          task.runWhen = time + interval;
        }
      }
    }
    tasks.removeWhere(completedTasks.contains);
  }

  /// Stop this game.
  @mustCallSuper
  void stop() => _isRunning = false;

  /// Destroy this game.
  ///
  /// This method destroys any created [window].
  @mustCallSuper
  void destroy() => window?.destroy();

  /// Run this game.
  @mustCallSuper
  Future<void> run(Sdl sdl, {int framesPerSecond = 60}) async {
    final int tickEvery = (1000 / framesPerSecond).round();
    window = sdl.createWindow(title);
    var lastTick = 0;
    _isRunning = true;
    while (_isRunning == true) {
      time = DateTime.now().millisecondsSinceEpoch;
      final int timeDelta;
      if (lastTick == 0) {
        timeDelta = 0;
        lastTick = time;
      } else {
        timeDelta = time - lastTick;
      }
      tick(sdl, timeDelta);
      lastTick = DateTime.now().millisecondsSinceEpoch;
      final tickTime = lastTick - time;
      if (tickEvery > tickTime) {
        await Future<void>.delayed(
            Duration(milliseconds: tickEvery - tickTime));
      }
    }
    destroy();
  }

  /// Output a message.
  void outputMessage(Message message) {
    final text = message.text;
    if (text != null) {
      window?.title = text;
    }
  }
}
