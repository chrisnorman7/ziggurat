/// Provides the [Runner] class.
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:spatialhash/spatialhash.dart';

import 'ambiance.dart';
import 'box.dart';
import 'box_types/actors/player.dart';
import 'box_types/surface.dart';
import 'box_types/wall.dart';
import 'directions.dart';
import 'error.dart';
import 'extensions.dart';
import 'json/runner_settings.dart';
import 'math.dart';
import 'message.dart';
import 'random_sound.dart';
import 'random_sound_container.dart';
import 'wall_location.dart';
import 'ziggurat.dart';

/// A class for running maps.
class Runner<T> {
  /// Create the runner.
  Runner(this.context, this.bufferCache, this.gameState, this.player,
      {RunnerSettings? rSettings})
      : _tiles = [],
        runnerSettings = rSettings ?? RunnerSettings(),
        _spatialHash = null,
        _reverbs = {},
        random = Random(),
        _randomSoundContainers = {},
        _randomSoundTimers = {},
        _ambianceSources = {};

  /// The synthizer context to use.
  final Context context;

  /// The buffer cache used by this runner.
  final BufferCache bufferCache;

  /// The current state of the game.
  ///
  /// This object can be anything, and should probably be loaded from JSON or
  /// similar.
  final T gameState;

  /// The settings for this runner.
  final RunnerSettings runnerSettings;

  /// The box that represents the player.
  ///
  /// The coordinates of the player box are ignored in favour of [coordinates].
  ///
  /// This is because it would be computationally expensive to move the player
  /// box all the time, and nothing has happened to change my mind yet.
  final Box<Player> player;

  /// The send that is used by wall echoes.
  GlobalEcho? _wallEcho;

  /// Reverb instances for the various boxes.
  final Map<Box<Surface>, GlobalFdnReverb> _reverbs;

  /// The random number generator to use.
  final Random random;

  /// The last time a move was performed by way of the [move] method.
  DateTime? lastMove;

  /// A dictionary to old random sound timers.
  final Map<RandomSound, RandomSoundContainer> _randomSoundContainers;

  /// A dictionary for holding random sound timers.
  final Map<RandomSound, Timer> _randomSoundTimers;

  /// A dictionary to hold ambiance sources.
  final Map<Ambiance, Source> _ambianceSources;

  /// All the tiles which are present on [ziggurat].
  List<List<Box?>> _tiles;

  /// The spatial hash containing all the boxes.
  SpatialHash<Box>? _spatialHash;

  /// Get the current spatial hash.
  SpatialHash<Box>? get spatialHash => _spatialHash;

  /// The ziggurat this runner will work with.
  Ziggurat? _ziggurat;

  /// Get the current ziggurat.
  Ziggurat? get ziggurat => _ziggurat;

  /// Set the current ziggurat.
  ///
  /// If setting the same ziggurat, the behaviour is undefined.
  set ziggurat(Ziggurat? value) {
    stop();
    _ziggurat = value;
    if (value != null) {
      var maxX = 0;
      var maxY = 0;
      final widths = <int>[];
      final depths = <int>[];
      for (final box in value.boxes) {
        if (box.start.x < 0 ||
            box.end.x < 0 ||
            box.start.y < 0 ||
            box.end.y < 0) {
          throw NegativeCoordinatesError(box);
        } else if (box == player) {
          throw PlayerInBoxesError(player, value);
        }
        widths.add(box.width);
        depths.add(box.height);
        maxX = max(maxX, box.end.x);
        maxY = max(maxY, box.end.y);
      }
      _tiles = List.generate(
          maxX + 1, (index) => List.filled(maxY + 1, null, growable: false),
          growable: false);
      final sh = SpatialHash<Box>(maxX, maxY, widths.average, depths.average)
        ..add(
            player,
            Rectangle(value.initialCoordinates.x, value.initialCoordinates.y,
                player.width, player.height));
      _spatialHash = sh;
      for (final box in value.boxes) {
        sh.add(box, Rectangle(box.start.x, box.start.y, box.width, box.height));
        for (var i = box.start.x; i <= box.end.x; i++) {
          for (var j = box.start.y; j <= box.end.y; j++) {
            _tiles[i][j] = box;
          }
        }
      }
      heading = value.initialHeading;
      coordinates = value.initialCoordinates;
      value.randomSounds.forEach(scheduleRandomSound);
      value.ambiances.forEach(startAmbiance);
      final cb = currentBox;
      if (cb != null) {
        onBoxChange(cb);
      }
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

  /// Return the box at the given [coordinates], if any.
  ///
  /// If no box is found, then `null` will be returned.
  Box? getBox(Point<int> coordinates) {
    if (coordinates.x < 0 ||
        coordinates.y < 0 ||
        coordinates.x >= _tiles.length ||
        coordinates.y >= _tiles[coordinates.x].length) {
      return null;
    }
    return _tiles[coordinates.x][coordinates.y];
  }

  /// Get the current box.
  Box? get currentBox => getBox(coordinates.floor());

  /// Move the player the given [distance].
  ///
  /// If [bearing] is `null`, then [heading] will be used.
  void move({double distance = 1.0, double? bearing}) {
    bearing ??= heading;
    final cb = currentBox;
    final oldBoxName = cb?.name;
    if (cb != null && cb is Box<Surface>) {
      final now = DateTime.now();
      final lm = lastMove;
      if (lm != null && now.difference(lm) < cb.type.moveInterval) {
        return;
      } else {
        lastMove = now;
      }
    }
    final c = coordinatesInDirection(coordinates, bearing, distance);
    final cf = c.floor();
    final b = getBox(cf);
    if (b != null) {
      if (b is Box<Wall>) {
        final wallSound = b.sound;
        if (wallSound != null) {
          playSound(wallSound);
        }
      } else {
        coordinates = c;
        _spatialHash?.update(player, Rectangle.fromPoints(c, c));
        final movementSound = b.sound;
        if (movementSound != null) {
          final source = playSound(movementSound);
          if (runnerSettings.wallEchoEnabled) {
            playWallEchoes(source);
          }
        }
        final newBoxName = b.name;
        if (newBoxName != oldBoxName) {
          onBoxChange(b);
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
    _randomSoundTimers[sound] = t;
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
    source
      ..gain = ambiance.gain
      ..configDeleteBehavior(linger: false);
    final f = ambiance.path.ensureFile(random);
    final g = BufferGenerator(context)
      ..setBuffer(bufferCache.getBuffer(f))
      ..looping = true
      ..configDeleteBehavior(linger: false);
    source.addGenerator(g);
    _ambianceSources[ambiance] = source;
  }

  /// Stop this runner from working.
  ///
  /// This method cancels all random sound timers, and prepares this object for
  /// garbage collection.
  void stop() {
    for (final timer in _randomSoundTimers.values) {
      timer.cancel();
    }
    _randomSoundTimers.clear();
    _randomSoundContainers.clear();
    for (final source in _ambianceSources.values) {
      source.destroy();
    }
    _ambianceSources.clear();
    _wallEcho?.destroy();
    _wallEcho = null;
    for (final r in _reverbs.values) {
      r.destroy();
    }
    _reverbs.clear();
    _tiles = List.empty();
  }

  /// Play a random sound.
  void playRandomSound(RandomSound sound) {
    _randomSoundContainers.remove(sound);
    _randomSoundTimers.remove(sound);
    final f = sound.path.ensureFile(random);
    final soundPosition = Point<double>(
        sound.minCoordinates.x +
            (random.nextDouble() *
                (sound.maxCoordinates.x - sound.minCoordinates.x)),
        sound.minCoordinates.y +
            (random.nextDouble() *
                (sound.maxCoordinates.y - sound.minCoordinates.y)));
    final s = Source3D(context)
      ..position = Double3(soundPosition.x, soundPosition.y, 0)
      ..gain = sound.minGain + random.nextDouble() + sound.maxGain
      ..configDeleteBehavior(linger: true);
    final position = soundPosition.floor();
    reverberateSource(s, position);
    filterSource(s, position);
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: true)
      ..setBuffer(bufferCache.getBuffer(f));
    s.addGenerator(g);
    _randomSoundContainers[sound] = RandomSoundContainer(soundPosition, s);
    scheduleRandomSound(sound);
  }

  /// Add reverb to a source if necessary.
  ///
  /// If there is no reverb at the given [position], nothing will happen.
  void reverberateSource(Source source, Point<int> position) {
    final t = getBox(position);
    if (t != null && t is Box<Surface>) {
      final type = t.type;
      if (type is Surface) {
        final reverbPreset = type.reverbPreset;
        if (reverbPreset != null) {
          GlobalFdnReverb? r = _reverbs[t];
          if (r == null) {
            r = reverbPreset.makeReverb(context)
              ..configDeleteBehavior(linger: false);
            _reverbs[t] = r;
          }
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
    source.filter = context.synthizer
        .designLowpass(max(runnerSettings.maxWallFilter, filterAmount));
  }

  /// Filter all sources.
  void filterSources() {
    _ambianceSources.forEach((key, value) {
      final p = key.position;
      if (p != null) {
        filterSource(value, p.floor());
      }
    });
    for (final container in _randomSoundContainers.values) {
      filterSource(container.source, container.coordinates.floor());
    }
  }

  /// Get the number of walls between two positions.
  Set<Box<Wall>> getWallsBetween(Point<int> end, [Point<int>? start]) {
    start ??= coordinates.floor();
    final s = <Box<Wall>>{};
    var x = min(start.x, end.x);
    var y = min(start.y, end.y);
    final endX = max(start.x, end.x);
    final endY = max(start.y, end.y);
    while (x < endX || y < endY) {
      if (x < endX) {
        x++;
      }
      if (y < endY) {
        y++;
      }
      final t = getBox(Point<int>(x, y));
      if (t is Box<Wall>) {
        s.add(t);
      }
    }
    return s;
  }

  /// Get the nearest wall in the given [direction].
  ///
  /// This method returns `null` if no wall is found.
  ///
  /// This method stops hunting for walls at the first available opportunity,
  /// or when [maxDistance] has been traversed.
  WallLocation? getNearestWall(double direction,
      {Point<int>? start, int maxDistance = 10}) {
    start ??= coordinates.floor();
    var c = start.toDouble();
    var distance = 0;
    while (distance <= maxDistance) {
      distance++;
      c = coordinatesInDirection(c, direction, 1);
      final t = getBox(c.floor());
      if (t == null) {
        return null;
      } else if (t is Box<Wall>) {
        return WallLocation(t, c);
      }
    }
  }

  /// Play a simple sound.
  ///
  /// A sound played via this method is not panned or occluded, but will be
  /// reverberated if [reverb] is `true`.
  DirectSource playSound(FileSystemEntity sound,
      {double gain = 0.7, bool reverb = true}) {
    final f = sound.ensureFile(random);
    final s = DirectSource(context)
      ..gain = gain
      ..configDeleteBehavior(linger: true);
    if (reverb) {
      reverberateSource(s, coordinates.floor());
    }
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: true)
      ..setBuffer(bufferCache.getBuffer(f));
    s.addGenerator(g);
    return s;
  }

  /// Add wall echoes to a sound.
  void playWallEchoes(DirectSource source) {
    final c = coordinates.floor();
    final westWall = getNearestWall(normaliseAngle(heading - Directions.east),
        maxDistance: runnerSettings.wallEchoMaxDistance, start: c);
    final northWall = getNearestWall(heading,
        maxDistance: runnerSettings.wallEchoMaxDistance, start: c);
    final eastWall = getNearestWall(normaliseAngle(heading + Directions.east),
        maxDistance: runnerSettings.wallEchoMaxDistance, start: c);
    final taps = <EchoTapConfig>[];
    double d;
    double g;
    if (westWall != null) {
      d = coordinates.distanceTo(westWall.coordinates);
      g = runnerSettings.wallEchoGain -
          (d * runnerSettings.wallEchoGainRolloff);
      taps.add(EchoTapConfig(
          runnerSettings.wallEchoMinDelay +
              (d * runnerSettings.wallEchoDistanceOffset),
          g,
          0.0));
    }
    if (northWall != null) {
      d = coordinates.distanceTo(northWall.coordinates);
      g = runnerSettings.wallEchoGain -
          (d * runnerSettings.wallEchoGainRolloff);
      taps.add(EchoTapConfig(
          runnerSettings.wallEchoMinDelay +
              (d * runnerSettings.wallEchoDistanceOffset),
          g,
          g));
    }
    if (eastWall != null) {
      d = coordinates.distanceTo(eastWall.coordinates);
      g = runnerSettings.wallEchoGain -
          (d * runnerSettings.wallEchoGainRolloff);
      taps.add(EchoTapConfig(
          runnerSettings.wallEchoMinDelay +
              (d * runnerSettings.wallEchoDistanceOffset),
          0.0,
          g));
    }
    if (taps.isNotEmpty) {
      var echo = _wallEcho;
      if (echo == null) {
        echo = context.createGlobalEcho()..configDeleteBehavior(linger: false);
        _wallEcho = echo;
      }
      echo.setTaps(taps);
      context.ConfigRoute(source, echo,
          filter: context.synthizer
              .designLowpass(runnerSettings.wallEchoFilterFrequency));
    }
  }

  /// Output some text.
  void outputText(String text) {
    // ignore: avoid_print
    print(text);
  }

  /// Output [message].
  void outputMessage(Message message,
      {Point<double>? position, bool reverberate = true, bool filter = true}) {
    final text = message.text;
    if (text != null) {
      outputText(text);
    }
    var sound = message.sound;
    if (sound != null) {
      sound = sound.ensureFile(random);
      final Source source;
      if (position == null) {
        source = playSound(sound, gain: message.gain, reverb: reverberate);
      } else {
        source = Source3D(context)
          ..gain = message.gain
          ..position = Double3(position.x, position.y, 0.0)
          ..configDeleteBehavior(linger: true);
        if (filter == true) {
          filterSource(source, position.floor());
        }
      }
    }
  }

  /// A function to be called whenever a new box is encountered.
  void onBoxChange(Box t) {}
}
