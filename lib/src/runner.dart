/// Provides the [Runner] class.
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';

import 'ambiance.dart';
import 'error.dart';
import 'extensions.dart';
import 'math.dart';
import 'random_sound.dart';
import 'random_sound_container.dart';
import 'tile.dart';
import 'tile_types/surface.dart';
import 'tile_types/wall.dart';
import 'ziggurat.dart';

/// A class for running maps.
class Runner<T> {
  /// Create the runner.
  Runner(this.context, this.bufferCache, this.gameState,
      {this.maxWallFilter = 500.0})
      : random = Random(),
        randomSoundContainers = {},
        randomSoundTimers = {},
        ambianceSources = {};

  /// The synthizer context to use.
  final Context context;

  /// The buffer cache used by this runner.
  final BufferCache bufferCache;

  /// The current state of the game.
  ///
  /// This object can be anything, and should probably be loaded from JSON or
  /// similar.
  final T gameState;

  /// The maximum filtering applied by walls.
  ///
  /// When sounds are filtered through walls, this value is the lowest frequency
  /// cutoff allowed.
  final double maxWallFilter;

  /// The random number generator to use.
  final Random random;

  /// The last time a move was performed by way of the [move] method.
  DateTime? lastMove;

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
    final ct = currentTile;
    final oldTileName = ct?.name;
    if (ct != null && ct is Tile<Surface>) {
      final now = DateTime.now();
      final lm = lastMove;
      if (lm != null && now.difference(lm) < ct.type.moveInterval) {
        return;
      } else {
        lastMove = now;
      }
    }
    final c = coordinatesInDirection(coordinates, bearing, distance);
    final cf = c.floor();
    final t = getTile(cf);
    if (t != null) {
      if (t is Tile<Wall>) {
        final wallSound = t.sound;
        if (wallSound != null) {
          playSound(wallSound);
        }
      } else {
        coordinates = c;
        final movementSound = t.sound;
        if (movementSound != null) {
          playSound(movementSound);
        }
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
      final position = p.floor();
      reverberateSource(source, position);
      filterSource(source, position);
    }
    source.gain = ambiance.gain;
    final f = ambiance.path.ensureFile(random);
    final g = BufferGenerator(context)
      ..setBuffer(bufferCache.getBuffer(f))
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
    final f = sound.path.ensureFile(random);
    final soundPosition = Point<double>(
        sound.minCoordinates.x + random.nextDouble() * sound.maxCoordinates.x,
        sound.minCoordinates.y + random.nextDouble() * sound.maxCoordinates.y);
    final s = Source3D(context)
      ..position = Double3(soundPosition.x, soundPosition.y, 0)
      ..gain = sound.minGain + random.nextDouble() + sound.maxGain
      ..configDeleteBehavior(linger: false);
    final position = soundPosition.floor();
    reverberateSource(s, position);
    filterSource(s, position);
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: false)
      ..setBuffer(bufferCache.getBuffer(f));
    s.addGenerator(g);
    randomSoundContainers[sound] = RandomSoundContainer(soundPosition, s);
    scheduleRandomSound(sound);
  }

  /// Add reverb to a source if necessary.
  ///
  /// If there is no reverb at the given [position], nothing will happen.
  void reverberateSource(Source source, Point<int> position) {
    final t = getTile(position);
    if (t != null) {
      final type = t.type;
      if (type is Surface) {
        final reverbPreset = type.reverbPreset;
        if (reverbPreset != null) {
          final r = reverbPreset.makeReverb(context)
            ..configDeleteBehavior(linger: false);
          context.ConfigRoute(source, r);
        }
      }
    }
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
    while (x < endX && y < endY) {
      if (x < endX) {
        x++;
      }
      if (y < endY) {
        y++;
      }
      final t = getTile(Point<int>(x, y));
      if (t != null) {
        if (t is Tile<Wall>) {
          s.add(t);
        }
      }
    }
    return s;
  }

  /// Play a simple sound.
  ///
  /// A sound played via this method is not panned or occluded, but will be
  /// reverberated if [reverb] is `true`.
  void playSound(FileSystemEntity sound,
      {double gain = 0.7, bool reverb = true}) {
    final f = sound.ensureFile(random);
    final s = DirectSource(context)
      ..gain = gain
      ..configDeleteBehavior(linger: false);
    if (reverb) {
      reverberateSource(s, coordinates.floor());
    }
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: false)
      ..setBuffer(bufferCache.getBuffer(f));
    s.addGenerator(g);
  }
}
