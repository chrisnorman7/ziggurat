/// Provides the [Game] class.
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../ziggurat.dart';
import 'json/reverb_preset.dart';
import 'levels/level.dart';
import 'sound/backend/effects/backend_echo.dart';
import 'sound/backend/effects/backend_reverb.dart';
import 'sound/backend/listener.dart';
import 'sound/backend/sound.dart';
import 'sound/backend/sound_backend.dart';
import 'sound/backend/sound_channel.dart';
import 'sound/backend/sound_position.dart';

/// The main game object.
class Game {
  /// Create an instance.
  Game({
    required this.title,
    required this.sdl,
    required this.soundBackend,
    this.orgName = 'com.example',
    this.appName = 'untitled_game',
    this.preferencesFileName = 'preferences.json',
    this.preferencesKey = defaultPreferencesKey,
    this.triggerMap = const TriggerMap([]),
    final Random? random,
  })  : _levels = [],
        _isRunning = false,
        tasks = [],
        gameControllers = {},
        joysticks = {},
        random = random ?? Random(),
        interfaceSounds = soundBackend.createSoundChannel(),
        ambianceSounds = soundBackend.createSoundChannel(),
        musicSounds = soundBackend.createSoundChannel();

  /// The title of this game.
  ///
  /// This value will be used to determine the title of the resulting window.
  final String title;

  /// The SDL instance to use.
  final Sdl sdl;

  /// The name of the organisation who makes this game.
  final String orgName;

  /// The internal name for this game.
  ///
  /// This name will be used along with [orgName], to get a suitable
  /// [preferencesDirectory].
  final String appName;

  /// The filename where [preferences] will be read from.
  ///
  /// This value will be combined with [preferencesDirectory] to get the
  /// fully-qualified filename.
  final String preferencesFileName;

  /// The file where [preferences] will be stored.
  File get preferencesFile => File(
        path.join(
          preferencesDirectory.path,
          preferencesFileName,
        ),
      );

  /// The key where [preferences] will be stored.
  final String preferencesKey;

  /// Get the preferences directory for this game.
  Directory get preferencesDirectory =>
      Directory(sdl.getPrefPath(orgName, appName));

  /// The preferences object for this game.
  Preferences get preferences => Preferences(
        file: preferencesFile,
        key: preferencesKey,
      );

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

  bool _isRunning;

  /// Whether or not this game is running.
  bool get isRunning => _isRunning;

  /// The tasks which have been registered using [registerTask].
  final List<TaskRunner> tasks;

  /// The game controllers that are currently open.
  final Map<int, GameController> gameControllers;

  /// The loaded joysticks.
  final Map<int, Joystick> joysticks;

  /// The random number generator to use.
  final Random random;

  /// The sound backend to use.
  final SoundBackend soundBackend;

  /// The default channel for playing interface sounds through.
  final SoundChannel interfaceSounds;

  /// The sound channel to play ambiance sounds through.
  final SoundChannel ambianceSounds;

  /// The sound channel for [Level] music.
  late final SoundChannel musicSounds;

  /// Register a new [task].
  void registerTask(final Task task) => tasks.add(TaskRunner(task));

  /// Call the given [func] after the specified time.
  ///
  /// This is equivalent to:
  ///
  /// ```
  /// const task = Task(func: f, runAfter: 15);
  /// game.registerTask(task);
  /// ```
  Task callAfter({
    required final TaskFunction func,
    required final int runAfter,
  }) {
    final task = Task(func: func, runAfter: runAfter);
    registerTask(task);
    return task;
  }

  /// Unregister a task.
  void unregisterTask(final Task task) =>
      tasks.removeWhere((final element) => element.value == task);

  /// Push a level onto the stack.
  void pushLevel(
    final Level level, {
    final int? after,
    final double? fadeLength,
  }) {
    if (after != null) {
      callAfter(
        func: () => pushLevel(level, fadeLength: fadeLength),
        runAfter: after,
      );
    } else {
      final cl = currentLevel;
      level.onPush(fadeLength: fadeLength);
      _levels.add(level);
      if (cl != null) {
        cl.onCover(level);
      }
    }
  }

  /// Pop the most recent level.
  Level? popLevel({
    final double? ambianceFadeTime,
  }) {
    if (_levels.isNotEmpty) {
      final oldLevel = _levels.removeLast()..onPop(ambianceFadeTime);
      final cl = currentLevel;
      if (cl != null) {
        cl.onReveal(oldLevel);
      }
      return oldLevel;
    }
    return null;
  }

  /// Replace the current level with [level].
  void replaceLevel(
    final Level level, {
    final double? fadeOutTime,
    final double? fadeInTime,
  }) {
    popLevel(ambianceFadeTime: fadeOutTime);
    pushLevel(
      level,
      after: fadeOutTime == null ? null : (fadeOutTime * 1000).round(),
      fadeLength: fadeInTime,
    );
  }

  /// Handle SDL events.
  ///
  ///This method will be passed one event at a time.
  @mustCallSuper
  void handleSdlEvent(final Event event) {
    final sdl = event.sdl;
    if (event is QuitEvent) {
      stop();
    } else if (event is ControllerDeviceEvent) {
      switch (event.state) {
        case DeviceState.added:
          final controller = sdl.openGameController(event.joystickId);
          gameControllers[event.joystickId] = controller;
          break;
        case DeviceState.removed:
          gameControllers.remove(event.joystickId);
          break;
        case DeviceState.remapped:
          // Do nothing.
          break;
      }
    } else if (event is JoyDeviceEvent) {
      final id = event.joystickId;
      switch (event.state) {
        case DeviceState.added:
          final joystick = sdl.openJoystick(id);
          joysticks[id] = joystick;
          break;
        case DeviceState.removed:
          joysticks.remove(id);
          break;
        case DeviceState.remapped:
          // Do nothing.
          break;
      }
    } else {
      final level = currentLevel;
      if (level != null) {
        for (final commandTrigger in triggerMap.triggers) {
          final name = commandTrigger.name;
          final key = commandTrigger.keyboardKey;
          final button = commandTrigger.button;
          if ((event is KeyboardEvent &&
                  event.repeat == false &&
                  key != null &&
                  event.key.scancode == key.scanCode &&
                  (key.altKey == false ||
                      event.key.modifiers.contains(KeyMod.alt)) &&
                  (key.controlKey == false ||
                      event.key.modifiers.contains(KeyMod.ctrl)) &&
                  (key.shiftKey == false ||
                      event.key.modifiers.contains(KeyMod.shift))) ||
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
            final bool value;
            switch (state) {
              case PressedState.pressed:
                value = level.startCommand(name);
                break;
              case PressedState.released:
                value = level.stopCommand(name);
                break;
            }
            if (value == true) {
              return;
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
  Future<void> tick(final int timeDelta) async {
    Event? event;
    do {
      event = sdl.pollEvent();
      if (event != null) {
        handleSdlEvent(event);
      }
    } while (event != null);
    final level = currentLevel;
    if (level != null) {
      level.tick(timeDelta);
    }
    final completedTasks = <TaskRunner>[];
    // We must copy the `tasks` list to prevent Concurrent modification during
    // iteration.
    for (final runner in List<TaskRunner>.from(
      tasks.where(
        (final element) {
          final taskLevel = element.value.level;
          return taskLevel == null || taskLevel == level;
        },
      ),
      growable: false,
    )) {
      final task = runner.value;
      final interval = task.interval;
      final timeSinceRun = runner.runAfter + timeDelta;
      if ((runner.numberOfRuns == 0 && timeSinceRun >= task.runAfter) ||
          (runner.numberOfRuns >= 1 &&
              interval != null &&
              timeSinceRun >= interval)) {
        runner.run();
        if (interval == null) {
          completedTasks.add(runner);
        }
      } else {
        runner.runAfter += timeDelta;
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
  }

  /// Run this game.
  ///
  /// You can set the frames per second with the [framesPerSecond] parameter.
  ///
  /// Note: Once set, FPS cannot currently be changed.
  ///
  /// If you want to run some code when the game has started, but before the
  /// main loop starts, use the [onStart] parameter.
  ///
  /// The `onStart` function will be called after the window has been created,
  /// so it's perfectly fine to start pushing levels at that point.
  ///
  /// Before this parameter was introduced, it was necessary to use
  /// [registerTask], which wasn't quite as reliable, due to how fast windows
  /// are created on some machines.
  @mustCallSuper
  Future<void> run({
    final int framesPerSecond = 60,
    final TaskFunction? onStart,
  }) async {
    final tickEvery = 1000 ~/ framesPerSecond;
    _window = sdl.createWindow(title);
    var lastTick = 0;
    _isRunning = true;
    if (onStart != null) {
      onStart();
    }
    while (_isRunning == true) {
      final int timeDelta;
      final ticks = sdl.ticks;
      if (lastTick == 0) {
        timeDelta = 0;
        lastTick = 0;
      } else {
        timeDelta = ticks - lastTick;
      }
      await tick(timeDelta);
      lastTick = sdl.ticks;
      final tickTime = lastTick - ticks;
      if (tickEvery > tickTime) {
        await Future<void>.delayed(
          Duration(milliseconds: tickEvery - tickTime),
        );
      }
    }
    destroy();
  }

  /// How to output text.
  // ignore: use_setters_to_change_properties
  void outputText(final String text) => _window?.title = text;

  /// Quickly play a sound.
  ///
  /// If [position] is not [unpanned], the resulting sound's [Sound.keepAlive]
  /// will be `true`, and [Sound.channel] must be manually destroyed.
  ///
  /// If [position] is [unpanned], then the resulting sound's [Sound.channel]
  /// will be set to [interfaceSounds], and [Sound.keepAlive] will be `false`.
  Sound playSimpleSound({
    required final AssetReference sound,
    final SoundPosition position = unpanned,
    final bool looping = false,
    final double pitchBend = 1.0,
  }) {
    final SoundChannel channel;
    if (position == unpanned) {
      channel = interfaceSounds;
    } else {
      channel = soundBackend.createSoundChannel(position: position);
    }
    return channel.playSound(
      assetReference: sound,
      keepAlive: position != unpanned,
      looping: looping,
      pitchBend: pitchBend,
    );
  }

  /// Output a sound.
  ///
  /// This method is used by [outputMessage].
  Sound? outputSound({
    required final AssetReference? sound,
    final SoundChannel? soundChannel,
    final Sound? oldSound,
    final bool keepAlive = false,
    final bool looping = false,
    final double pitchBend = 1.0,
  }) {
    if (oldSound != null && oldSound.keepAlive == true) {
      oldSound.destroy();
    }
    if (sound != null) {
      return (soundChannel ?? interfaceSounds).playSound(
        assetReference: sound,
        keepAlive: keepAlive,
        looping: looping,
        pitchBend: pitchBend,
      );
    }
    return null;
  }

  /// Output a message.
  Sound? outputMessage(
    final Message message, {
    final SoundChannel? soundChannel,
    final Sound? oldSound,
  }) {
    final text = message.text;
    if (text != null) {
      outputText(text);
    }
    return outputSound(
      sound: message.sound,
      oldSound: oldSound,
      soundChannel: soundChannel,
      keepAlive: message.keepAlive,
    );
  }

  /// Create a reverb.
  BackendReverb createReverb(final ReverbPreset reverb) =>
      soundBackend.createReverb(reverb);

  /// Create an echo.
  BackendEcho createEcho(final Iterable<EchoTap> taps) =>
      soundBackend.createEcho(taps);

  /// Create a sound channel.
  SoundChannel createSoundChannel({
    final SoundPosition position = unpanned,
    final double gain = 0.7,
  }) =>
      soundBackend.createSoundChannel(
        gain: gain,
        position: position,
      );

  /// Set the listener position.
  void setListenerPosition(final double x, final double y, final double z) =>
      soundBackend.listenerPosition = ListenerPosition(x, y, z);

  /// Set the orientation of the listener.
  void setListenerOrientation(final double angle) {
    soundBackend.listenerOrientation = ListenerOrientation.fromAngle(angle);
  }

  /// Set the default panner strategy.
  set defaultPannerStrategy(final DefaultPannerStrategy strategy) =>
      soundBackend.defaultPannerStrategy = strategy;

  /// Rumble on all [joysticks].
  void rumble({
    required final int duration,
    final int lowFrequency = 65535,
    final int highFrequency = 65535,
  }) {
    for (final joystick in joysticks.values) {
      joystick.rumble(
        duration: duration,
        highFrequency: highFrequency,
        lowFrequency: lowFrequency,
      );
    }
  }
}
