/// Provides the [Runner] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';
import 'package:meta/meta.dart';
import 'package:spatialhash/spatialhash.dart';

import 'box.dart';
import 'box_types/agents/agent.dart';
import 'box_types/agents/player.dart';
import 'box_types/door.dart';
import 'box_types/surface.dart';
import 'box_types/wall.dart';
import 'directions.dart';
import 'error.dart';
import 'extensions.dart';
import 'json/message.dart';
import 'json/runner_settings.dart';
import 'json/sound_reference.dart';
import 'math.dart';
import 'sound/ambiance.dart';
import 'sound/buffer_store.dart';
import 'sound/random_sound.dart';
import 'sound/random_sound_container.dart';
import 'wall_location.dart';
import 'ziggurat.dart';

/// A class for running maps.
class Runner<T> {
  /// Create the runner.
  Runner(this.context, this.bufferStore, this.gameState, this.player,
      {RunnerSettings? runnerSettings})
      : _tiles = [],
        runnerSettings = runnerSettings ?? RunnerSettings(),
        directionalRadarState = {},
        _spatialHash = null,
        _reverbs = {},
        random = Random(),
        _randomSoundContainers = {},
        _ambianceSources = {};

  /// The synthizer context to use.
  final Context context;

  /// The buffer cache used by this runner.
  final BufferStore bufferStore;

  /// The current state of the game.
  ///
  /// This object can be anything, and should probably be loaded from JSON or
  /// similar.
  final T gameState;

  /// The settings for this runner.
  final RunnerSettings runnerSettings;

  /// The state of the left/right radar.
  final Map<int, Box<Wall>?> directionalRadarState;

  /// The box that represents the player.
  final Box<Player> player;

  /// The send that is used by wall echoes.
  GlobalEcho? _wallEcho;

  /// Reverb instances for the various boxes.
  final Map<Box<Surface>, GlobalFdnReverb> _reverbs;

  /// The random number generator to use.
  final Random random;

  /// The last time a move was performed by way of the [move] method.
  int? lastMove;

  /// A dictionary to old random sound timers.
  final Map<RandomSound, RandomSoundContainer> _randomSoundContainers;

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
    // Only clear buffers if we're setting a ziggurat for the first time.
    if (_ziggurat != null) {
      stop();
    }
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
      value.ambiances.forEach(startAmbiance);
      final cb = currentBox;
      onBoxChange(
          agent: player,
          newBox: cb,
          oldBox: null,
          oldPosition: coordinates,
          newPosition: coordinates);
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
  Point<double> _coordinates = Point(0, 0);

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
    if (cb != null && cb is Box<Surface>) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lm = lastMove;
      if (lm != null && (now - lm) < cb.type.moveInterval) {
        return;
      } else {
        lastMove = now;
      }
    }
    final c = coordinatesInDirection(coordinates, bearing, distance);
    final cf = c.floor();
    final nb = getBox(cf);
    if (nb != null) {
      if (nb is Box<Wall> && nb is! Box<Door>) {
        onCollideWall(nb, player);
      } else {
        if (nb is Box<Door> && nb.type.shouldOpen(player) == false) {
          return onCollideDoor(nb, player, c);
        }
        final oldCoordinates = coordinates;
        player.move(cf, cf);
        _spatialHash?.update(player, Rectangle.fromPoints(c, c));
        onMove(
            agent: player,
            surface: nb,
            oldCoordinates: coordinates,
            newCoordinates: c);
        if (nb != cb) {
          onBoxChange(
              agent: player,
              newBox: nb,
              oldBox: cb,
              oldPosition: oldCoordinates,
              newPosition: c);
        }
      }
    }
  }

  /// Turn by the specified amount.
  void turn(double amount) {
    heading = normaliseAngle(heading + amount);
    if (runnerSettings.directionalRadarResetOnTurn == true) {
      directionalRadarState.clear();
    }
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
    final buffer =
        bufferStore.getBuffer(ambiance.sound.name, ambiance.sound.type);
    final g = BufferGenerator(context)
      ..setBuffer(buffer)
      ..looping = true
      ..configDeleteBehavior(linger: false);
    source.addGenerator(g);
    _ambianceSources[ambiance] = source;
  }

  /// Stop this runner from working.
  ///
  /// This method cancels all random sound timers, and prepares this object for
  /// garbage collection.
  @mustCallSuper
  void stop() {
    directionalRadarState.clear();
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
    bufferStore.clear();
  }

  /// Play a random sound.
  void playRandomSound(RandomSound sound) {
    _randomSoundContainers.remove(sound);
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
      ..setBuffer(bufferStore.getBuffer(sound.sound.name, sound.sound.type));
    s.addGenerator(g);
    _randomSoundContainers[sound] = RandomSoundContainer(soundPosition, s);
  }

  /// Add reverb to a source if necessary.
  ///
  /// If there is no reverb at the given [position], nothing will happen.
  void reverberateSource(Source source, Point<int> position) {
    final box = getBox(position);
    if (box != null && box is Box<Surface>) {
      final reverbPreset = box.type.reverbPreset;
      if (reverbPreset != null) {
        GlobalFdnReverb? r = _reverbs[box];
        if (r == null) {
          r = reverbPreset.makeReverb(context)
            ..configDeleteBehavior(linger: false);
          _reverbs[box] = r;
        }
        context.ConfigRoute(source, r);
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
        if (t is Box<Door> && t.type.open == true) {
          continue;
        }
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

  /// Get nearby objects for the given [agent].
  Set<Box> getNearbyObjects(Box<Agent> agent) {
    final sh = _spatialHash;
    if (sh == null) {
      return <Box>{};
    }
    return sh.near(agent);
  }

  /// Play a simple sound.
  ///
  /// A sound played via this method is not panned or occluded, but will be
  /// reverberated if [reverb] is `true`.
  DirectSource playSound(SoundReference sound,
      {double gain = 0.7, bool reverb = true}) {
    final s = DirectSource(context)
      ..gain = gain
      ..configDeleteBehavior(linger: true);
    if (reverb) {
      reverberateSource(s, coordinates.floor());
    }
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: true)
      ..setBuffer(bufferStore.getBuffer(sound.name, sound.type));
    s.addGenerator(g);
    return s;
  }

  /// Play a sound in 3d.
  Source3D playSound3D(SoundReference sound, Point<double> position,
      {double gain = 0.7, bool reverb = true}) {
    final s = Source3D(context)
      ..position = Double3(position.x, position.y, 0.0)
      ..gain = gain
      ..configDeleteBehavior(linger: true);
    if (reverb) {
      reverberateSource(s, position.floor());
    }
    final g = BufferGenerator(context)
      ..configDeleteBehavior(linger: true)
      ..setBuffer(bufferStore.getBuffer(sound.name, sound.type));
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

  /// Play the radar sound in the given direction.
  Box<Wall>? playDirectionalRadarDirection(
      Point<double> from, double direction, Box<Wall>? currentObject) {
    final doorSound = runnerSettings.directionalRadarDoorSound;
    final wallSound = runnerSettings.directionalRadarWallSound;
    Point<double> boxCoordinates = from;
    for (var distance = 0.0;
        distance <= runnerSettings.directionalRadarDistance;
        distance++) {
      boxCoordinates = coordinatesInDirection(from, direction, distance);
      final box = getBox(boxCoordinates.floor());
      if (box is Box<Wall>) {
        if (box == currentBox) {
          continue;
        }
        final SoundReference sound;
        if (box is Box<Door>) {
          if (doorSound == null) {
            continue;
          }
          sound = doorSound;
        } else {
          if (wallSound == null) {
            continue;
          }
          sound = wallSound;
        }
        if (currentObject == null || box != currentObject) {
          playSound3D(
            sound,
            boxCoordinates,
            gain: runnerSettings.directionalRadarGain,
            reverb: false,
          );
          return box;
        } else {
          return currentObject;
        }
      }
    }
    // We have not returned yet, so there is empty space in the given direction.
    if (currentObject == null) {
      // The radar has already noticed.
      if (runnerSettings.directionalRadarAlertOnChange == true) {
        /// The player doesn't want to be alerted again.
        return null;
      }
    }
    final emptySpaceSound = runnerSettings.directionalRadarEmptySpaceSound;
    if (emptySpaceSound != null) {
      playSound3D(emptySpaceSound, boxCoordinates, reverb: false);
    }
  }

  /// Play the directional radar sounds.
  void playDirectionalRadar({Point<double>? from}) {
    from ??= coordinates;
    for (final i in runnerSettings.directionalRadarDirections) {
      final direction = normaliseAngle(heading + i);
      final b = playDirectionalRadarDirection(
          from,
          direction,
          runnerSettings.directionalRadarAlertOnChange == true
              ? directionalRadarState[i]
              : null);
      if (runnerSettings.directionalRadarAlertOnChange == true) {
        directionalRadarState[i] = b;
      }
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
    if (text != null &&
        (position == null || getWallsBetween(position.floor()).isEmpty)) {
      outputText(text);
    }
    final sound = message.sound;
    if (sound != null) {
      final Source source;
      if (position == null) {
        source = playSound(sound, gain: message.gain, reverb: reverberate);
      } else {
        final generator = BufferGenerator(context)
          ..setBuffer(bufferStore.getBuffer(sound.name, sound.type))
          ..configDeleteBehavior(linger: true);
        source = Source3D(context)
          ..gain = message.gain
          ..position = Double3(position.x, position.y, 0.0)
          ..addGenerator(generator)
          ..configDeleteBehavior(linger: true);
        if (filter == true) {
          filterSource(source, position.floor());
        }
      }
    }
  }

  /// Someone collided with a wall.
  void onCollideWall(Box<Wall> wall, Box<Agent> agent) {
    final wallSound = wall.sound;
    if (wallSound != null) {
      if (agent == player) {
        playSound(wallSound);
      } else {
        playSound3D(wallSound, agent.centre);
      }
    }
  }

  /// [agent] collided with a door.
  ///
  /// This happens when a door's [Door.shouldOpen] method returns `false`.
  void onCollideDoor(
      Box<Door> door, Box<Agent> agent, Point<double> coordinates) {
    final collideMessage = door.type.collideMessage;
    if (collideMessage != null) {
      outputMessage(collideMessage, position: coordinates);
    }
  }

  /// [agent] moved from [oldCoordinates] to [newCoordinates].
  void onMove(
      {required Box<Agent> agent,
      required Box surface,
      required Point<double> oldCoordinates,
      required Point<double> newCoordinates}) {
    coordinates = newCoordinates;
    final movementSound = surface.sound;
    if (movementSound != null) {
      if (agent == player) {
        final source = playSound(movementSound);
        if (runnerSettings.wallEchoEnabled) {
          playWallEchoes(source);
        }
        if (runnerSettings.directionalRadarEnabled) {
          playDirectionalRadar();
        }
      } else {
        playSound3D(movementSound, newCoordinates);
      }
    }
  }

  /// A function to be called whenever a new box is encountered.
  @mustCallSuper
  void onBoxChange(
      {required Box<Agent> agent,
      required Box? newBox,
      required Box? oldBox,
      required Point<double> oldPosition,
      required Point<double> newPosition}) {
    oldBox?.onExit(this, agent, newPosition);
    newBox?.onEnter(this, agent, oldPosition);
  }

  /// Open a door.
  void openDoor(Door d, Point<double> position) {
    d.open = true;
    final openMessage = d.openMessage;
    if (openMessage != null) {
      outputMessage(openMessage, position: position);
    }
    filterSources();
  }

  /// Close a door.
  void closeDoor(Door d, Point<double> position) {
    d
      ..open = false
      ..closeTimer = null;
    final closeMessage = d.closeMessage;
    if (closeMessage != null) {
      outputMessage(closeMessage, position: position);
    }
    filterSources();
  }
}
