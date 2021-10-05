/// Provides the base [Level] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../command.dart';
import '../game.dart';
import '../sound/ambiance.dart';
import '../sound/events/playback.dart';
import '../sound/random_sound.dart';

/// A level in a [Game] instance.
class Level {
  /// Create a level.
  Level(this.game, {List<Ambiance>? ambiances, List<RandomSound>? randomSounds})
      : commands = {},
        ambiances = ambiances ?? [],
        randomSounds = randomSounds ?? [],
        ambianceSounds = [];

  /// The game this level is part of.
  final Game game;

  /// The commands this level recognises.
  final Map<String, Command> commands;

  /// A list of ambiances for this level.
  final List<Ambiance> ambiances;

  /// The list of ambiance sounds created by the [onPush] method.
  final List<PlaySound> ambianceSounds;

  /// All the random sounds on this level.
  final List<RandomSound> randomSounds;

  /// What should happen when this game is pushed into a level stack.
  @mustCallSuper
  void onPush() {
    for (final ambiance in ambiances) {
      ambianceSounds.add(game.ambianceSounds.playSound(ambiance.sound,
          gain: ambiance.gain, looping: true, keepAlive: true));
    }
  }

  /// What should happen when this level is popped from a level stack.
  @mustCallSuper
  void onPop(double? fadeLength) {
    while (ambianceSounds.isNotEmpty) {
      final ambiance = ambianceSounds.removeLast();
      if (fadeLength != null) {
        ambiance.fade(length: fadeLength);
        game.registerTask((fadeLength * 1000).round(), ambiance.destroy);
      } else {
        ambiance.destroy();
      }
    }
    for (final sound in randomSounds) {
      final channel = sound.channel;
      sound.channel = null;
      if (channel != null) {
        if (fadeLength != null) {
          game.registerTask((fadeLength * 1000).round(), channel.destroy);
        } else {
          channel.destroy();
        }
      }
    }
  }

  /// What should happen when this level is covered by another level.
  void onCover(Level other) {}

  /// What should happen when this level is revealed by another level being
  /// popped from on top of it.
  void onReveal(Level old) {}

  /// Register a command on this level.
  void registerCommand(String name, Command command) {
    commands[name] = command;
  }

  /// Start the command with the given [name].
  @mustCallSuper
  void startCommand(String name) {
    final command = commands[name];
    if (command != null) {
      command.isRunning = true;
      final onStart = command.onStart;
      final interval = command.interval;
      if (onStart != null) {
        if (interval == null || game.time >= command.nextRun) {
          onStart();
          if (interval != null) {
            command.nextRun = game.time + interval;
          }
        }
      }
    }
  }

  /// Stop the command with the given [name].
  @mustCallSuper
  void stopCommand(String name) {
    final command = commands[name];
    if (command != null) {
      command.isRunning = false;
      final onStop = command.onStop;
      if (onStop != null) {
        onStop();
      }
    }
  }

  /// Handle an SDL event.
  ///
  ///This method will be called only if the event in question is not consumed
  ///by [game].
  void handleSdlEvent(Event event) {}
}
