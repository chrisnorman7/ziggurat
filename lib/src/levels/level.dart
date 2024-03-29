import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../../sound.dart';
import '../../ziggurat.dart';
import '../json/level_stub.dart';

/// The top-level level class.
///
/// Instances of this class are used to provide functionality to [Game]
/// instances.
class Level {
  /// Create a level.
  Level({
    required this.game,
    final Map<String, Command>? commands,
    this.music,
    final List<Ambiance>? ambiances,
    final List<RandomSound>? randomSounds,
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
    final LevelStub stub, {
    final Map<String, Command>? commands,
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

  /// The [game]'s random sound generator.
  Random get random => game.random;

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
  final AssetReference? music;

  /// The playing [music].
  Sound? musicSound;

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

  /// What should happen when this level is pushed into a level stack.
  ///
  /// If [fadeLength] is not `null`, then [music] and all [ambiances] will be
  /// faded in.
  @mustCallSuper
  void onPush({final double? fadeLength}) {
    final sound = music;
    if (sound != null) {
      musicSound = game.musicSounds.playSound(
        assetReference: fadeLength == null ? sound : sound.silent(),
        keepAlive: true,
        looping: true,
      );
      if (fadeLength != null) {
        musicSound!.fade(
          length: fadeLength,
          endGain: sound.gain,
          startGain: 0.0,
        );
      }
    }
    for (final ambiance in ambiances) {
      final SoundChannel channel;
      final position = ambiance.position;
      if (position == null) {
        channel = game.ambianceSounds;
      } else {
        channel = game.createSoundChannel(
          position: SoundPosition3d(x: position.x, y: position.y),
        );
      }
      final assetReference = ambiance.sound;
      final sound = channel.playSound(
        assetReference:
            fadeLength == null ? assetReference : assetReference.silent(),
        keepAlive: true,
        looping: true,
      );
      if (fadeLength != null) {
        sound.fade(
          length: fadeLength,
          startGain: 0.0,
          endGain: assetReference.gain,
        );
      }
      ambiancePlaybacks[ambiance] = SoundPlayback(channel, sound);
    }
    randomSounds.forEach(scheduleRandomSound);
  }

  /// Stop [playback].
  ///
  /// If [SoundPlayback.channel] is not [Game.ambianceSounds], then the
  /// channel will be destroyed.
  void stopPlayback(final SoundPlayback playback) {
    playback.sound.destroy();
    if (playback.channel != game.ambianceSounds) {
      playback.channel.destroy();
    }
  }

  /// What should happen when this level is popped from a level stack.
  @mustCallSuper
  void onPop(final double? fadeLength) {
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
      randomSoundNextPlays
          .removeWhere((final element) => element.value == sound);
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
  void onCover(final Level other) {}

  /// What should happen when this level is revealed by another level being
  /// popped from on top of it.
  void onReveal(final Level old) {}

  /// Register a command on this level.
  void registerCommand(final String name, final Command command) =>
      commands[name] = command;

  /// Get the next run for the given [randomSound].
  NextRun<RandomSound> getRandomSoundNextPlay(final RandomSound randomSound) =>
      randomSoundNextPlays.firstWhere(
        (final element) => element.value == randomSound,
        orElse: () {
          final nextRun = NextRun(randomSound);
          randomSoundNextPlays.add(nextRun);
          return nextRun;
        },
      );

  /// Schedule a random [sound] to play.
  void scheduleRandomSound(final RandomSound sound) {
    final int offset;
    if (sound.minInterval == sound.maxInterval) {
      offset = 0;
    } else {
      offset = random.nextInt(sound.maxInterval - sound.minInterval);
    }
    getRandomSoundNextPlay(sound).runAfter = sound.minInterval + offset;
  }

  /// Get the next run value for the given [command].
  NextRun<Command>? getCommandNextRun(final Command command) {
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
  bool startCommand(final String name) {
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
  void runCommand(final Command command) {
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
  bool stopCommand(final String name) {
    final command = commands[name];
    if (command != null) {
      final nextRun = getCommandNextRun(command);
      if (nextRun != null) {
        commandNextRuns
            .removeWhere((final element) => element.value == command);
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
  @mustCallSuper
  void handleSdlEvent(final Event event) {}

  /// Tick all [commandNextRuns].
  ///
  /// This method is called by [tick].
  void tickCommands(final int timeDelta) {
    for (final nextRun in commandNextRuns) {
      nextRun.runAfter += timeDelta;
      final command = nextRun.value;
      final interval = command.interval!;
      if (nextRun.runAfter >= interval) {
        runCommand(command);
      }
    }
  }

  /// Remove any commands from the [stoppedCommands] list that can now be ran
  /// again.
  void stopCommands(final int timeDelta) {
    stoppedCommands.removeWhere((final element) {
      element.runAfter += timeDelta;
      return element.runAfter >= element.value.interval!;
    });
  }

  /// Tick all random sounds.
  void tickRandomSounds(final int timeDelta) {
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
        final x = minX + (xDifference * random.nextDouble());
        final y = minY + (yDifference * random.nextDouble());
        final position = SoundPosition3d(x: x, y: y);
        if (c == null) {
          c = game.createSoundChannel(position: position);
        } else {
          c.position = position;
        }
        randomSoundPlaybacks[sound] = SoundPlayback(
          c,
          c.playSound(
            assetReference: sound.sound.copy(
              sound.minGain == sound.maxGain
                  ? sound.minGain
                  : sound.minGain +
                      ((sound.maxGain - sound.minGain) * random.nextDouble()),
            ),
            keepAlive: true,
          ),
        );
        scheduleRandomSound(sound);
      } else {
        playNext.runAfter -= timeDelta;
      }
    }
  }

  /// Let this level tick.
  ///
  /// This method will be called by [Game.tick].
  ///
  /// The [timeDelta] argument will be how long it has been since the game last
  /// ticked.
  ///
  /// To prevent jank, this method should not take too long, although some time
  /// correction is performed by the [Game.tick] method.
  @mustCallSuper
  void tick(final int timeDelta) {
    tickCommands(timeDelta);
    stopCommands(timeDelta);
    tickRandomSounds(timeDelta);
  }
}
