/// Provides the base [Level] class.
import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../command.dart';
import '../game.dart';
import '../json/ambiance.dart';
import '../json/level_stub.dart';
import '../json/random_sound.dart';
import '../sound/events/sound_channel.dart';
import '../sound/events/sound_position.dart';
import '../sound/sound_playback.dart';

/// The top-level level class.
///
/// Instances of this class are used to provide functionality to [Game]
/// instances.
class Level {
  /// Create a level.
  Level(this.game,
      {Map<String, Command>? commands,
      List<Ambiance>? ambiances,
      List<RandomSound>? randomSounds})
      : commands = commands ?? {},
        ambiances = ambiances ?? [],
        randomSounds = randomSounds ?? [],
        ambiancePlaybacks = {},
        randomSoundPlaybacks = {},
        randomSoundNextPlays = {};

  /// Create an instance from a level stub.
  Level.fromStub(this.game, LevelStub stub, {Map<String, Command>? commands})
      : commands = commands ?? {},
        ambiances = stub.ambiances,
        randomSounds = stub.randomSounds,
        ambiancePlaybacks = {},
        randomSoundPlaybacks = {},
        randomSoundNextPlays = {};

  /// The game this level is part of.
  final Game game;

  /// The commands this level recognises.
  final Map<String, Command> commands;

  /// A list of ambiances for this level.
  final List<Ambiance> ambiances;

  /// The playback settings for the list of [ambiances].
  ///
  /// This value is used by [onPush] and [onPop].
  final Map<Ambiance, SoundPlayback> ambiancePlaybacks;

  /// All the random sounds on this level.
  final List<RandomSound> randomSounds;

  /// The playback settings for the list of [randomSounds].
  final Map<RandomSound, SoundPlayback> randomSoundPlaybacks;

  /// The times that [randomSounds] should play next.
  final Map<RandomSound, int> randomSoundNextPlays;

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
      ambiancePlaybacks[ambiance] = SoundPlayback(channel, sound);
    }
  }

  /// Stop [playback].
  ///
  /// If [SoundPlayback.channel] is not [Game.ambianceSounds], then the
  /// channel will be destroyed.
  void stopPlayback(SoundPlayback playback) {
    playback.sound.destroy();
    if (playback.channel != game.ambianceSounds) {
      playback.channel.destroy();
    }
  }

  /// What should happen when this level is popped from a level stack.
  @mustCallSuper
  void onPop(double? fadeLength) {
    for (final ambiance in ambiances) {
      final playback = ambiancePlaybacks.remove(ambiance);
      if (playback == null) {
        continue;
      }
      if (fadeLength != null) {
        playback.sound.fade(length: fadeLength);
        game.registerTask(
            (fadeLength * 1000).round(), () => stopPlayback(playback));
      } else {
        stopPlayback(playback);
      }
    }
    for (final sound in randomSounds) {
      randomSoundNextPlays.remove(sound);
      final playback = randomSoundPlaybacks.remove(sound);
      if (playback != null) {
        if (fadeLength != null) {
          playback.sound.fade(length: fadeLength);
          game.registerTask(
              (fadeLength * 1000).round(), () => stopPlayback(playback));
        } else {
          stopPlayback(playback);
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

  /// Let this level tick.
  ///
  /// This method will be called by [Game.tick].
  ///
  /// The [sdl] argument will be the SDL instance that is running the game.
  ///
  /// The [timeDelta] argument will be how long it has been since the game last
  /// ticked.
  ///
  /// To prevent jank, this method should not take too long, although some time
  /// correction is performed by the [Game.tick] method.
  void tick(Sdl sdl, int timeDelta) {}
}
