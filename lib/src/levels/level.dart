import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../../sound.dart';
import '../command.dart';
import '../game.dart';
import '../json/level_stub.dart';
import '../next_run.dart';

/// The top-level level class.
///
/// Instances of this class are used to provide functionality to [Game]
/// instances.
class Level {
  /// Create a level.
  Level({
    required this.game,
    Map<String, Command>? commands,
    this.music,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  })  : commands = commands ?? {},
        commandNextRuns = [],
        stoppedCommands = [],
        ambiances = ambiances ?? [],
        randomSounds = randomSounds ?? [],
        ambiancePlaybacks = {},
        randomSoundPlaybacks = {},
        randomSoundNextPlays = [];

  /// Create an instance from a level stub.
  Level.fromStub(
    this.game,
    LevelStub stub, {
    Map<String, Command>? commands,
  })  : commands = commands ?? {},
        commandNextRuns = [],
        stoppedCommands = [],
        music = stub.music,
        ambiances = stub.ambiances,
        randomSounds = stub.randomSounds,
        ambiancePlaybacks = {},
        randomSoundPlaybacks = {},
        randomSoundNextPlays = [];

  /// The game this level is part of.
  final Game game;

  /// The commands this level recognises.
  final Map<String, Command> commands;

  /// The times before commands should run next.
  final List<NextRun<Command>> commandNextRuns;

  /// The old command next runs.
  ///
  /// This list gets added to by [stopCommand], and removed from by
  /// [startCommand].
  final List<NextRun<Command>> stoppedCommands;

  /// The music for this level.
  final Music? music;

  /// The playing [music].
  PlaySound? musicSound;

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
  ///
  /// The map values are the number of milliseconds before the sound keys
  /// should play again.
  final List<NextRun<RandomSound>> randomSoundNextPlays;

  /// What should happen when this game is pushed into a level stack.
  @mustCallSuper
  void onPush() {
    final sound = music;
    if (sound != null) {
      musicSound = game.musicSounds.playSound(
        sound.sound,
        gain: sound.gain,
        keepAlive: true,
        looping: true,
      );
    }
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
    randomSounds.forEach(scheduleRandomSound);
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
    final sound = musicSound;
    musicSound = null;
    if (sound != null) {
      if (fadeLength == null) {
        sound.destroy();
      } else {
        sound.fade(length: fadeLength);
        game.callAfter(
          func: sound.destroy,
          runAfter: (fadeLength * 1000).floor(),
        );
      }
    }
    for (final ambiance in ambiances) {
      final playback = ambiancePlaybacks.remove(ambiance);
      if (playback == null) {
        continue;
      }
      if (fadeLength != null) {
        playback.sound.fade(length: fadeLength);
        game.callAfter(
          runAfter: (fadeLength * 1000).round(),
          func: () => stopPlayback(playback),
        );
      } else {
        stopPlayback(playback);
      }
    }
    for (final sound in randomSounds) {
      randomSoundNextPlays.removeWhere((element) => element.value == sound);
      final playback = randomSoundPlaybacks.remove(sound);
      if (playback != null) {
        if (fadeLength != null) {
          playback.sound.fade(length: fadeLength);
          game.callAfter(
            runAfter: (fadeLength * 1000).round(),
            func: () => stopPlayback(playback),
          );
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

  /// Get the next run for the given [randomSound].
  NextRun<RandomSound> getRandomSoundNextPlay(RandomSound randomSound) =>
      randomSoundNextPlays.firstWhere(
        (element) => element.value == randomSound,
        orElse: () {
          final nextRun = NextRun(randomSound);
          randomSoundNextPlays.add(nextRun);
          return nextRun;
        },
      );

  /// Schedule a random [sound] to play.
  void scheduleRandomSound(RandomSound sound) {
    final int offset;
    if (sound.minInterval == sound.maxInterval) {
      offset = 0;
    } else {
      offset = game.random.nextInt(sound.maxInterval - sound.minInterval);
    }
    getRandomSoundNextPlay(sound).runAfter = sound.minInterval + offset;
  }

  /// Get the next run value for the given [command].
  NextRun<Command>? getCommandNextRun(Command command) {
    for (final nextRun in commandNextRuns) {
      if (nextRun.value == command) {
        return nextRun;
      }
    }
    return null;
  }

  /// Start the command with the given [name].
  ///
  /// Returns `true` if the command was handled.
  @mustCallSuper
  bool startCommand(String name) {
    final command = commands[name];
    if (command != null) {
      final interval = command.interval;
      NextRun<Command>? nextRun;
      for (var i = 0; i < stoppedCommands.length; i++) {
        nextRun = stoppedCommands[i];
        if (nextRun.value == command) {
          stoppedCommands.removeAt(i);
          commandNextRuns.add(nextRun);
          break;
        }
      }
      nextRun ??= getCommandNextRun(command);
      final runAfter = nextRun?.runAfter ?? command.interval;
      if (interval == null || (runAfter != null && runAfter >= interval)) {
        runCommand(command);
      }
      return true;
    }
    return false;
  }

  /// Run the given [command].
  void runCommand(Command command) {
    final onStart = command.onStart;
    if (onStart != null) {
      onStart();
      final interval = command.interval;
      if (interval != null) {
        final nextRun = getCommandNextRun(command);
        if (nextRun == null) {
          commandNextRuns.add(NextRun(command));
        } else {
          nextRun.runAfter -= interval;
        }
      }
    }
  }

  /// Stop the command with the given [name].
  ///
  /// Returns `true` if the command was handled.
  @mustCallSuper
  bool stopCommand(String name) {
    final command = commands[name];
    if (command != null) {
      final nextRun = getCommandNextRun(command);
      if (nextRun != null) {
        commandNextRuns.removeWhere((element) => element.value == command);
        stoppedCommands.add(nextRun);
      }
      final onStop = command.onStop;
      if (onStop != null) {
        onStop();
      }
      return true;
    }
    return false;
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
  @mustCallSuper
  void tick(Sdl sdl, int timeDelta) {
    for (final nextRun in commandNextRuns) {
      nextRun.runAfter += timeDelta;
      final command = nextRun.value;
      final interval = command.interval!;
      if (nextRun.runAfter >= interval) {
        runCommand(command);
      }
    }
    final toStop = <Command>{};
    for (final nextRun in stoppedCommands) {
      final command = nextRun.value;
      nextRun.runAfter += timeDelta;
      if (nextRun.runAfter >= command.interval!) {
        toStop.add(command);
      }
    }
    for (final command in toStop) {
      stoppedCommands.removeWhere((element) => element.value == command);
    }
    for (final sound in randomSounds) {
      final playNext = getRandomSoundNextPlay(sound);
      if (playNext.runAfter <= 0) {
        final playback = randomSoundPlaybacks[sound];
        SoundChannel? c;
        if (playback != null) {
          playback.sound.destroy();
          c = playback.channel;
        } else {
          c = null;
        }
        final minX = sound.minCoordinates.x;
        final maxX = sound.maxCoordinates.x;
        final minY = sound.minCoordinates.y;
        final maxY = sound.maxCoordinates.y;
        final xDifference = maxX - minX;
        final yDifference = maxY - minY;
        final x = minX + (xDifference * game.random.nextDouble());
        final y = minY + (yDifference * game.random.nextDouble());
        final position = SoundPosition3d(x: x, y: y);
        if (c == null) {
          c = game.createSoundChannel(position: position);
        } else {
          c.position = position;
        }
        randomSoundPlaybacks[sound] = SoundPlayback(
          c,
          c.playSound(
            sound.sound,
            keepAlive: true,
            gain: sound.minGain == sound.maxGain
                ? sound.minGain
                : (sound.minGain +
                    ((sound.maxGain - sound.minGain) *
                        game.random.nextDouble())),
          ),
        );
        scheduleRandomSound(sound);
      } else {
        playNext.runAfter -= timeDelta;
      }
    }
  }
}
