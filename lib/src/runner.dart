/// Provides the [Runner] class.
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';

import 'ambiance.dart';
import 'error.dart';
import 'math.dart';
import 'random_sound.dart';
import 'tile.dart';
import 'tile_types/surface.dart';
import 'tile_types/wall.dart';
import 'ziggurat.dart';

/// An extension for returning a `Point<int>` from a `Point<double>`.
extension RunnerDoubleMethods on Point<double> {
  /// Return a floored version of this point.
  Point<int> floor() => Point<int>(x.floor(), y.floor());
}

/// An extension for returning a `Point<double>` from a `Point<int>`.
extension RunnerIntMethods on Point<int> {
  /// Return a version of this point with the points converted to doubles.
  Point<double> toDouble() => Point<double>(x.toDouble(), y.toDouble());
}

/// An extension for getting random files from directories.
extension RunnerMethods on Directory {
  /// Return a random file from a directory.
  ///
  /// If this entity is already a file, it will be returned.
  File randomFile(Random random) {
    final files = listSync();
    if (files.isEmpty) {
      throw NoFilesError(this);
    }
    final f = files[random.nextInt(files.length)];
    if (f is File) {
      return f;
    } else if (f is Directory) {
      return f.randomFile(random);
    } else {
      throw InvalidEntityError(f);
    }
  }
}

/// A class for containing random sound data.
class RandomSoundContainer {
  /// Create the data.
  RandomSoundContainer(this.coordinates, this.source);

  /// The coordinates of the sound.
  final Point<double> coordinates;

  /// The source which is playing the sound.
  final Source3D source;
}

/// A class for running maps.
class Runner {
  /// Create the runner.
  Runner(this.context, this.bufferCache, {this.maxWallFilter = 500.0})
      : random = Random(),
        randomSoundContainers = {},
        randomSoundTimers = {},
        ambianceSources = {};

  /// The synthizer context to use.
  final Context context;

  /// The buffer cache used by this runner.
  final BufferCache bufferCache;

  /// The maximum filtering applied by walls.
  ///
  /// When sounds are filtered through walls, this value is the lowest frequency
  /// cutoff allowed.
  final double maxWallFilter;

  /// The random number generator to use.
  final Random random;

  /// A dictionary to old random sound timers.
  final Map<RandomSound, RandomSoundContainer> randomSoundContainers;

  /// A dictionary for holding random sound timers.
  final Map<RandomSound, Timer> randomSoundTimers;

  /// A dictionary to hold ambiance sources.
  final Map<Ambiance, Source> ambianceSources;

  /// The ziggurat this runner will work with.
  Ziggurat? _ziggurat;

  /// Get the current ziggurat.
  Ziggurat? get ziggurat => _ziggurat;

  /// Set the current ziggurat.
  set ziggurat(Ziggurat? value) {
    _ziggurat = value;
    stop();
    if (value != null) {
      heading = value.initialHeading;
      coordinates = value.initialCoordinates;
      value.randomSounds.forEach(scheduleRandomSound);
      value.ambiances.forEach(startAmbiance);
    }
  }

  /// The bearing of the listener.
  double _heading = 0;

  /// Get the current heading.
  double get heading => _heading;

  /// Set the current heading.
  set heading(double value) {
    _heading = value;
    final rad = angleToRad(value);
    context.orientation = Double6(
      sin(rad),
      cos(rad),
      0,
      0,
      0,
      1,
    );
  }

  /// The coordinates of the player.
  Point<double> _coordinates = Point<double>(0.0, 0.0);

  /// Get the current coordinates.
  Point<double> get coordinates => _coordinates;

  /// Set the player's coordinates.
  set coordinates(Point<double> value) {
    _coordinates = value;
    context.position = Double3(value.x, value.y, 0);
    filterSources();
  }

  /// Return the tile at the given [coordinates], if any.
  Tile? getTile(Point<int> coordinates) {
    final z = ziggurat;
    if (z == null) {
      throw NoZigguratError(this);
    }
    for (final t in z.tiles) {
      if (t.containsPoint(coordinates)) {
        return t;
      }
    }
  }

  /// Get the current tile.
  Tile? get currentTile => getTile(coordinates.floor());

  /// Move the player the given [distance].
  ///
  /// If [bearing] is `null`, then [heading] will be used.
  void move({double distance = 1.0, double? bearing}) {
    bearing ??= heading;
    final oldTileName = currentTile?.name;
    final c = coordinatesInDirection(coordinates, bearing, distance);
    final cf = c.floor();
    final t = getTile(cf);
    if (t != null) {
      if (t.type is Wall) {
        // ignore: avoid_print
        print('You walk into ${t.name}.');
      } else {
        coordinates = c;
        final newTileName = t.name;
        if (newTileName != oldTileName) {
          // ignore: avoid_print
          print(t.name);
        }
      }
    }
  }

  /// Turn by the specified amount.
  void turn(double amount) => heading = normaliseAngle(heading + amount);

  /// Schedule the playing of a random sound.
  void scheduleRandomSound(RandomSound sound) {
    final t = Timer(
        Duration(
            milliseconds:
                sound.minInterval + random.nextInt(sound.maxInterval)), () {
      playRandomSound(sound);
    });
    randomSoundTimers[sound] = t;
  }

  /// Start an ambiance playing.
  void startAmbiance(Ambiance ambiance) {
    final p = ambiance.position;
    final Source source;
    if (p == null) {
      source = DirectSource(context);
    } else {
      source = Source3D(context)..position = Double3(p.x, p.y, 0.0);
      filterSource(source, p.floor());
      final t = getTile(p.floor());
      if (t != null) {
        final type = t.type;
        if (type is Surface) {
          final reverbPreset = type.reverbPreset;
          if (reverbPreset != null) {
            final r = reverbPreset.makeReverb(context)
              ..configDeleteBehavior(linger: false);
            context.ConfigRoute(source, r);
          } else {}
        }
      }
    }
    source.gain = ambiance.gain;
    var f = ambiance.path;
    if (f is Directory) {
      f = f.randomFile(random);
    } else if (f is! File) {
      throw InvalidEntityError(f);
    }
    final g = BufferGenerator(context)
      ..setBuffer(Buffer.fromFile(context.synthizer, f as File))
      ..looping = true
      ..configDeleteBehavior(linger: false);
    source.addGenerator(g);
    ambianceSources[ambiance] = source;
  }

  /// Stop this runner from working.
  ///
  /// This method cancels all random sound timers, and prepares this object for
  /// garbage collection.
  void stop() {
    for (final timer in randomSoundTimers.values) {
      timer.cancel();
    }
    randomSoundTimers.clear();
    randomSoundContainers.clear();
    for (final source in ambianceSources.values) {
      source.destroy();
    }
    ambianceSources.clear();
  }

  /// Play a random sound.
  void playRandomSound(RandomSound sound) {
    randomSoundContainers.remove(sound);
    randomSoundTimers.remove(sound);
    var f = sound.path;
    if (f is Directory) {
      f = f.randomFile(random);
    }
    if (f is! File) {
      throw InvalidEntityError(f);
    }
    final soundPosition = Point<double>(
        sound.minCoordinates.x + random.nextDouble() * sound.maxCoordinates.x,
        sound.minCoordinates.y + random.nextDouble() * sound.maxCoordinates.y);
    final s = Source3D(context)
      ..position = Double3(soundPosition.x, soundPosition.y, 0)
      ..gain = sound.minGain + random.nextDouble() + sound.maxGain
      ..configDeleteBehavior(linger: false);
    final position = soundPosition.floor();
    final t = getTile(position);
    if (t != null) {
      final type = t.type;
      if (type is Surface) {
        final reverbPreset = type.reverbPreset;
        if (reverbPreset != null) {
          final r = reverbPreset.makeReverb(context)
            ..configDeleteBehavior(linger: false);
          context.ConfigRoute(s, r);
        }
      }
    }
    filterSource(s, position);
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: false)
      ..setBuffer(Buffer.fromFile(context.synthizer, f));
    s.addGenerator(g);
    randomSoundContainers[sound] = RandomSoundContainer(soundPosition, s);
    scheduleRandomSound(sound);
  }

  /// Filter a source depending on position.
  void filterSource(Source source, Point<int> position) {
    var filterAmount = 20000.0;
    final walls = getWallsBetween(position);
    for (final w in walls) {
      filterAmount -= w.type.filterFrequency;
    }
    source.filter =
        context.synthizer.designLowpass(max(maxWallFilter, filterAmount));
  }

  /// Filter all sources.
  void filterSources() {
    ambianceSources.forEach((key, value) {
      final p = key.position;
      if (p != null) {
        filterSource(value, p.floor());
      }
    });
    for (final container in randomSoundContainers.values) {
      filterSource(container.source, container.coordinates.floor());
    }
  }

  /// Get the number of walls between two positions.
  Set<Tile<Wall>> getWallsBetween(Point<int> end, [Point<int>? start]) {
    start ??= coordinates.floor();
    final s = <Tile<Wall>>{};
    var x = min(start.x, end.x);
    var y = min(start.y, end.y);
    final endX = max(start.x, end.x);
    final endY = max(start.y, end.y);
    while (x <= endX && y <= endY) {
      x++;
      y++;
      final t = getTile(Point<int>(x, y));
      if (t != null) {
        if (t is Tile<Wall>) {
          s.add(t);
        }
      }
    }
    return s;
  }
}
