/// Provides the [Game] class.
import 'dart:async';
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import 'json/asset_reference.dart';
import 'json/message.dart';
import 'json/trigger_map.dart';
import 'levels/level.dart';
import 'sound/events/events_base.dart';
import 'sound/events/global.dart';
import 'sound/reverb_preset.dart';
import 'task.dart';

/// The main game object.
class Game {
  /// Create an instance.
  Game(this.title, {TriggerMap? triggerMap})
      : _levels = [],
        triggerMap = triggerMap ?? TriggerMap([]),
        time = 0,
        _started = 0,
        _isRunning = false,
        tasks = [],
        _queuedSoundEvents = [],
        gameControllers = {},
        random = Random() {
    soundsController = StreamController(
        onListen: _addAllSoundEvents, onResume: _addAllSoundEvents);
    interfaceSounds = createSoundChannel();
    ambianceSounds = createSoundChannel();
  }

  /// The title of this game.
  ///
  /// This value will be used to determine the title of the resulting window.
  final String title;

  /// The level stack of this game.
  final List<Level> _levels;

  /// Get the current level.
  ///
  /// This is the level which is last in the levels stack.
  @doNotStore
  Level? get currentLevel => _levels.isEmpty ? null : _levels.last;

  /// The trigger map.
  final TriggerMap triggerMap;

  Window? _window;

  /// The sdl window that will be shown when the [run] method is called.
  Window? get window => _window;

  /// Game time.
  ///
  /// This value is given in milliseconds since the epoch.
  int time;

  int _started;

  /// The time when [run] was first called.
  ///
  /// If this value is 0, you can be assured that [run] has never been called.
  int get started => _started;

  /// The number of milliseconds this game has been running for.
  int get runDurationMilliseconds => time - _started;

  /// The number of seconds this game has been running for.
  double get runDurationSeconds => runDurationMilliseconds / 1000;

  bool _isRunning;

  /// Whether or not this game is running.
  bool get isRunning => _isRunning;

  /// The tasks which have been registered using [registerTask].
  final List<Task> tasks;

  /// The stream controller for dispatching sound events.
  ///
  /// Do not add events to this controller directly, instead, use the
  /// [queueSoundEvent] method.
  late final StreamController<SoundEvent> soundsController;

  /// The place where sound events go until [soundsController] has listeners.
  final List<SoundEvent> _queuedSoundEvents;

  /// The game controllers that are currently open.
  final Map<int, GameController> gameControllers;

  /// The random number generator to use.
  final Random random;

  /// The stream for listening to sound events.
  ///
  /// You can add sounds with the [queueSoundEvent] method.
  Stream<SoundEvent> get sounds => soundsController.stream;

  /// The default channel for playing interface sounds through.
  late final SoundChannel interfaceSounds;

  /// The sound channel to play ambiance sounds through.
  late final SoundChannel ambianceSounds;

  /// Queue a sound event.
  ///
  /// If [soundsController] is paused, then events will be queued.
  ///
  /// It is not possible to fully pause sound events, since this could lead to
  /// problems if a sound delete event was never received for example. Instead,
  /// events are simply queued until the [soundsController] is unpaused.
  void queueSoundEvent(SoundEvent event) {
    if (soundsController.isPaused || soundsController.hasListener == false) {
      _queuedSoundEvents.add(event);
    } else {
      soundsController.add(event);
    }
  }

  /// Fire all the events that have built up.
  void _addAllSoundEvents() {
    while (_queuedSoundEvents.isNotEmpty) {
      final event = _queuedSoundEvents.removeAt(0);
      soundsController.add(event);
    }
  }

  /// Register a new task.
  ///
  /// This method is shorthand for:
  ///
  /// ```
  /// task = Task(game.time + runAfter, func);
  /// ```
  ///
  /// If you are registering a task before calling [run], you can use the
  /// [timeOffset] argument to add the current time, rather than having the task
  /// executed immediately.
  Task registerTask(int runAfter, void Function() func,
      {int? interval, int? timeOffset}) {
    var when = time + runAfter;
    if (timeOffset != null) {
      when += timeOffset;
    }
    final task = Task(when, interval, func);
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
  Level? popLevel({double? ambianceFadeTime}) {
    if (_levels.isNotEmpty) {
      final oldLevel = _levels.removeLast()..onPop(ambianceFadeTime);
      final cl = currentLevel;
      if (cl != null) {
        cl.onReveal(oldLevel);
      }
      return oldLevel;
    }
  }

  /// Replace the current level with [level].
  void replaceLevel(Level level, {double? ambianceFadeTime}) {
    popLevel(ambianceFadeTime: ambianceFadeTime);
    if (ambianceFadeTime != null) {
      registerTask((ambianceFadeTime * 1000).round(), () => pushLevel(level));
    } else {
      pushLevel(level);
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
        final controller = event.sdl.openGameController(event.joystickId);
        gameControllers[event.joystickId] = controller;
      } else {
        gameControllers.remove(event.joystickId);
      }
    } else {
      final level = currentLevel;
      if (level != null) {
        for (final commandTrigger in triggerMap.triggers) {
          final name = commandTrigger.name;
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
  Future<void> tick(Sdl sdl, int timeDelta) async {
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
      for (final sound in level.randomSounds) {
        final nextPlay = sound.nextPlay;
        if (nextPlay == null) {
          final int offset;
          if (sound.minInterval == sound.maxInterval) {
            offset = 0;
          } else {
            offset = random.nextInt(sound.maxInterval - sound.minInterval);
          }
          sound.nextPlay = time + (sound.minInterval + offset);
        } else if (time >= nextPlay) {
          final minX = sound.minCoordinates.x;
          final maxX = sound.maxCoordinates.x;
          final minY = sound.minCoordinates.y;
          final maxY = sound.maxCoordinates.y;
          final xDifference = maxX - minX;
          final yDifference = maxY - minY;
          final x = minX + (xDifference * random.nextDouble());
          final y = minY + (yDifference * random.nextDouble());
          var c = sound.channel;
          if (c == null) {
            c = createSoundChannel(position: SoundPosition3d(x: x, y: y));
            sound.channel = c;
          } else {
            c.position = SoundPosition3d(x: x, y: y);
          }
          c
            ..gain = sound.minGain == sound.maxGain
                ? sound.minGain
                : (sound.minGain +
                    ((sound.maxGain - sound.minGain) * random.nextDouble()))
            ..playSound(sound.sound);
        }
      }
    }
    final completedTasks = <Task>[];
    // We must copy the `tasks` list to prevent Concurrent modification during
    // iteration.
    for (final task in List<Task>.from(tasks, growable: false)) {
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
  /// This method destroys any created [_window].
  @mustCallSuper
  void destroy() {
    _window?.destroy();
    interfaceSounds.destroy();
    ambianceSounds.destroy();
    soundsController
      ..close()
      ..done;
  }

  /// Run this game.
  @mustCallSuper
  Future<void> run(Sdl sdl, {int framesPerSecond = 60}) async {
    final int tickEvery = 1000 ~/ framesPerSecond;
    _window = sdl.createWindow(title);
    var lastTick = 0;
    _isRunning = true;
    _started = DateTime.now().millisecondsSinceEpoch;
    while (_isRunning == true) {
      time = DateTime.now().millisecondsSinceEpoch;
      final int timeDelta;
      if (lastTick == 0) {
        timeDelta = 0;
        lastTick = time;
      } else {
        timeDelta = time - lastTick;
      }
      await tick(sdl, timeDelta);
      lastTick = DateTime.now().millisecondsSinceEpoch;
      final tickTime = lastTick - time;
      if (tickEvery > tickTime) {
        await Future<void>.delayed(
            Duration(milliseconds: tickEvery - tickTime));
      }
    }
    destroy();
  }

  /// How to output text.
  void outputText(String text) => _window?.title = text;

  /// Output a sound.
  ///
  /// This method is used by [outputMessage].
  PlaySound? outputSound(
      {required AssetReference? sound,
      SoundChannel? soundChannel,
      PlaySound? oldSound,
      double gain = 0.7,
      bool keepAlive = false}) {
    if (oldSound != null && oldSound.keepAlive == true) {
      oldSound.destroy();
    }
    if (sound != null) {
      soundChannel ??= interfaceSounds;
      return soundChannel.playSound(sound, gain: gain, keepAlive: keepAlive);
    }
  }

  /// Output a message.
  PlaySound? outputMessage(Message message,
      {SoundChannel? soundChannel, PlaySound? oldSound}) {
    final text = message.text;
    if (text != null) {
      outputText(text);
    }
    return outputSound(
        sound: message.sound,
        oldSound: oldSound,
        soundChannel: soundChannel,
        gain: message.gain,
        keepAlive: message.keepAlive);
  }

  /// Create a reverb.
  CreateReverb createReverb(ReverbPreset reverb) {
    final event =
        CreateReverb(game: this, id: SoundEvent.nextId(), reverb: reverb);
    queueSoundEvent(event);
    return event;
  }

  /// Create a sound channel.
  SoundChannel createSoundChannel(
      {SoundPosition position = unpanned,
      double gain = 0.7,
      CreateReverb? reverb}) {
    final event = SoundChannel(
        game: this,
        id: SoundEvent.nextId(),
        reverb: reverb?.id,
        gain: gain,
        position: position);
    queueSoundEvent(event);
    return event;
  }

  /// Set the listener position.
  void setListenerPosition(double x, double y, double z) =>
      queueSoundEvent(ListenerPositionEvent(x, y, z));

  /// Set the orientation of the listener.
  void setListenerOrientation(double angle) =>
      queueSoundEvent(ListenerOrientationEvent.fromAngle(angle));

  /// Set the default panner strategy.
  void setDefaultPannerStrategy(DefaultPannerStrategy strategy) =>
      queueSoundEvent(SetDefaultPannerStrategy(strategy));
}
