/// Provides the base [Level] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../command.dart';
import '../game.dart';
import '../sound/ambiance.dart';
import '../sound/events/playback.dart';

/// A level in a [Game] instance.
class Level {
  /// Create a level.
  Level(this.game, {List<Ambiance>? ambiances})
      : commands = {},
        ambiances = ambiances ?? [],
        ambianceSounds = [];

  /// The game this level is part of.
  final Game game;

  /// The commands this level recognises.
  final Map<String, Command> commands;

  /// A list of ambiances for this level.
  final List<Ambiance> ambiances;

  /// The list of ambiance sounds created by the [onPush] method.
  final List<PlaySound> ambianceSounds;

  /// What should happen when this game is pushed into a level stack.
  @mustCallSuper
  void onPush() {
    for (final ambiance in ambiances) {
      ambianceSounds.add(
          game.playSound(ambiance.sound, gain: ambiance.gain, looping: true));
    }
  }

  /// What should happen when this level is popped from a level stack.
  @mustCallSuper
  void onPop() {
    while (ambianceSounds.isNotEmpty) {
      final sound = ambianceSounds.removeLast();
      game.destroySound(sound);
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
