/// Provides the [Game] class.
import 'dart:async';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import 'json/message.dart';
import 'json/sound_reference.dart';
import 'json/trigger_map.dart';
import 'levels/level.dart';
import 'sound/events/events_base.dart';
import 'sound/reverb_preset.dart';
import 'task.dart';

/// The main game object.
class Game {
  /// Create an instance.
  Game(this.title, {TriggerMap? triggerMap})
      : _levels = [],
        triggerMap = triggerMap ?? TriggerMap({}),
        time = 0,
        _isRunning = false,
        tasks = [],
        sounds = StreamController();

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

  /// The stream controller for dispatching sound events.
  ///
  /// You can add to this stream either manually, or by using the various sound
  /// methods on instances of this class.
  final StreamController<SoundEvent> sounds;

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
                  (key.altKey == false ||
                      event.key.modifiers.contains(KeyMod.alt)) &&
                  (key.controlKey == false ||
                      event.key.modifiers.contains(KeyMod.ctrl)) &&
                  (key.shiftKey == false ||
                      event.key.modifiers.contains(KeyMod.shift)) &&
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
    final sound = message.sound;
    if (sound != null) {
      playSound(sound, gain: message.gain);
    }
  }

  /// Create a reverb.
  CreateReverb createReverb(ReverbPreset reverb) {
    final event = CreateReverb(id: SoundEvent.nextId(), reverb: reverb);
    sounds.add(event);
    return event;
  }

  /// Destroy a reverb previously created with [createReverb].
  DestroyReverb destroyReverb(CreateReverb reverb) {
    final event = DestroyReverb(reverb.id);
    sounds.add(event);
    return event;
  }

  /// Play a sound.
  PlaySound playSound(SoundReference sound,
      {SoundPosition position = unpanned,
      double gain = 0.7,
      bool looping = false,
      CreateReverb? reverb}) {
    final event = PlaySound(
        sound: sound,
        position: position,
        id: SoundEvent.nextId(),
        gain: gain,
        reverb: reverb?.id);
    sounds.add(event);
    return event;
  }

  /// Destroy a sound previously started by [playSound].
  DestroySound destroySound(PlaySound sound) {
    final event = DestroySound(sound.id);
    sounds.add(event);
    return event;
  }

  /// Pause a sound previously started with [playSound].
  PauseSound pauseSound(PlaySound sound) {
    final event = PauseSound(sound.id);
    sounds.add(event);
    return event;
  }

  /// Unpause a sound which was previously paused with [pauseSound].
  UnpauseSound unpauseSound(PlaySound sound) {
    final event = UnpauseSound(sound.id);
    sounds.add(event);
    return event;
  }

  /// Set the gain on a sound previously started with [playSound].
  SetGain setGain(PlaySound sound, double gain) {
    final event = SetGain(id: sound.id, gain: gain);
    sounds.add(event);
    return event;
  }

  /// Set whether or not a sound previously created with [playSound] should
  /// loop.
  SetLoop setLoop(PlaySound sound, bool loop) {
    final event = SetLoop(id: sound.id, looping: loop);
    sounds.add(event);
    return event;
  }
}
