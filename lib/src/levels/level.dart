/// Provides the base [Level] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../command.dart';
import '../game.dart';
import '../sound/ambiance.dart';
import '../sound/events/events_base.dart';
import '../sound/events/sound_channel.dart';
import '../sound/random_sound.dart';

/// A level in a [Game] instance.
class Level {
  /// Create a level.
  Level(this.game, {List<Ambiance>? ambiances, List<RandomSound>? randomSounds})
      : commands = {},
        ambiances = ambiances ?? [],
        randomSounds = randomSounds ?? [];

  /// The game this level is part of.
  final Game game;

  /// The commands this level recognises.
  final Map<String, Command> commands;

  /// A list of ambiances for this level.
  final List<Ambiance> ambiances;

  /// All the random sounds on this level.
  final List<RandomSound> randomSounds;

  /// What should happen when this game is pushed into a level stack.
  @mustCallSuper
  void onPush() {
    for (final ambiance in ambiances) {
      final SoundChannel channel;
      final position = ambiance.position;
      if (position == null) {
        channel = game.ambianceSounds;
      } else {
        channel = game.createSoundChannel(
            position: SoundPosition3d(x: position.x, y: position.y));
      }
      final sound = channel.playSound(ambiance.sound,
          gain: ambiance.gain, keepAlive: true, looping: true);
      ambiance.playback = AmbiancePlayback(channel, sound);
    }
  }

  /// Stop [playback].
  ///
  /// If [AmbiancePlayback.channel] is not [Game.ambianceSounds], then the
  /// channel will be destroyed.
  void stopAmbiance(AmbiancePlayback playback) {
    playback.sound.destroy();
    if (playback.channel != game.ambianceSounds) {
      playback.channel.destroy();
    }
  }

  /// What should happen when this level is popped from a level stack.
  @mustCallSuper
  void onPop(double? fadeLength) {
    for (final ambiance in ambiances) {
      final playback = ambiance.playback;
      if (playback == null) {
        continue;
      }
      if (fadeLength != null) {
        playback.sound.fade(length: fadeLength);
        game.registerTask(
            (fadeLength * 1000).round(), () => stopAmbiance(playback));
      } else {
        stopAmbiance(playback);
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
  void registerCommand(String name, Command command) =>
      commands[name] = command;

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
