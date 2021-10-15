/// Provides the [TileMapLevel] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';

import '../extensions.dart';
import '../game.dart';
import '../math.dart';
import '../sound/ambiance.dart';
import '../sound/random_sound.dart';
import '../tile_map/tile.dart';
import '../tile_map/tile_map.dart';
import 'level.dart';

/// A level that will render a [TileMap] instance.
class TileMapLevel extends Level {
  /// Create an instance.
  TileMapLevel(
      {required Game game,
      required this.tileMap,
      Point<double>? coordinates,
      double heading = 0.0,
      this.axisSensitivity = 0.5,
      this.axisInterval = 200,
      this.forwardMoveAxis = GameControllerAxis.righty,
      this.lateralMoveAxis = GameControllerAxis.rightx,
      this.forwardMoveDistance = 1.0,
      this.backwardMoveDistance = 0.5,
      this.lateralMoveDistance = 0.7,
      this.turnAxis = GameControllerAxis.leftx,
      this.turnAmount = 5.0,
      List<Ambiance>? ambiances,
      List<RandomSound>? randomSounds})
      : _tiles = List.generate(
            tileMap.width, (index) => List.filled(tileMap.height, null)),
        _coordinates = coordinates ??
            Point(tileMap.start.x.toDouble(), tileMap.start.y.toDouble()),
        _heading = heading,
        _turningValue = 0,
        _movingValue = 0,
        super(game,
            ambiances: (ambiances ?? []) +
                [
                  for (final tile in tileMap.tiles)
                    if (tile.ambiance != null)
                      Ambiance(
                          sound: tile.ambiance!,
                          gain: tile.ambianceGain,
                          position: tile.coordinates.toDouble())
                ],
            randomSounds: randomSounds) {
    for (final tile in tileMap.tiles) {
      _tiles[tile.coordinates.x][tile.coordinates.y] = tile;
    }
  }

  /// The tile map instance this level will work with.
  final TileMap tileMap;

  /// A 2d array of tiles.
  final List<List<Tile?>> _tiles;

  /// The last tile the player entered.
  Tile? _lastTile;

  /// The current coordinates of the player.
  Point<double> _coordinates;

  /// Get the current coordinates of the player.
  Point<double> get coordinates => _coordinates;

  /// Set the player coordinates, and the listener position.
  set coordinates(Point<double> value) {
    _coordinates = value;
    game.setListenerPosition(value.x, value.y, 0.0);
  }

  /// The direction the player is facing.
  double _heading;

  /// Get the direction the player is facing in.
  double get heading => _heading;

  /// Set the direction the player is facing.
  ///
  /// This setter also sets the listener orientation.
  set heading(double value) {
    _heading = value;
    game.setListenerOrientation(value);
  }

  /// the sensitivity of controller axes.
  final double axisSensitivity;

  /// How regularly axes moving will affect player movement.
  final int axisInterval;

  /// The controller axis that should be used to move the player forwards and
  /// backwards.
  final GameControllerAxis forwardMoveAxis;

  /// The controller axis that should be used to move the player left and right.
  final GameControllerAxis lateralMoveAxis;

  /// The distance to move the player.
  ///
  /// This value will be used by the [move] method.
  final double forwardMoveDistance;

  /// The size of the player's footsteps when moving backwards.
  final double backwardMoveDistance;

  /// The size of the player's footsteps when moving laterally.
  double lateralMoveDistance;

  /// The controller axis that can be used to turn the player.
  final GameControllerAxis turnAxis;

  /// How far to turn the player.
  ///
  /// This value will be used by the [turn] method.
  final double turnAmount;

  /// Whether the player is turning.
  double _turningValue;

  /// Whether the player is moving.
  double _movingValue;

  /// Get the tile at the given [point].
  Tile? tileAt(Point<int> point) {
    try {
      return _tiles[point.x][point.y];
    } on RangeError {
      return null;
    }
  }

  @override
  void onPush() {
    super.onPush();
    game
      ..setListenerOrientation(heading)
      ..setListenerPosition(coordinates.x, coordinates.y, 0.0);
  }

  @override
  void handleSdlEvent(Event event) {
    if (event is ControllerAxisEvent) {
      final axis = event.axis;
      var value = event.smallValue;
      if (axis == turnAxis) {
        if (value.abs() > axisSensitivity) {
          if (_turningValue < axisSensitivity) {
            game.registerTask(0, turn, interval: axisInterval);
          }
          _turningValue = value;
        } else {
          game.unregisterTask(turn);
        }
      } else if (axis == forwardMoveAxis) {
        value *= -1;
        if (value.abs() >= axisSensitivity) {
          if (_movingValue.abs() < axisSensitivity) {
            game.registerTask(0, move, interval: axisInterval);
          }
          _movingValue = value;
        } else {
          game.unregisterTask(move);
        }
      }
    }
  }

  /// Move the player.
  void move() {
    var direction = _heading;
    var distance = _movingValue;
    if (distance < 0) {
      direction = normaliseAngle(direction + 180);
      distance *= -1;
      distance *= backwardMoveDistance;
    } else {
      distance *= forwardMoveDistance;
    }
    final newCoordinates =
        coordinatesInDirection(_coordinates, direction, distance);
    if (tileMap.containsPoint(newCoordinates)) {
      final oldTile = _lastTile;
      if (oldTile != null) {
        final onExit = oldTile.onExit;
        if (onExit != null) {
          onExit();
        }
      }
      coordinates = newCoordinates;
      game.outputSound(sound: tileMap.footstepSound);
      final tile = tileAt(newCoordinates.floor());
      _lastTile = tile;
      if (tile != null) {
        final onEnter = tile.onEnter;
        if (onEnter != null) {
          onEnter();
        }
      }
    } else {
      game.outputMessage(tileMap.wallMessage);
    }
  }

  /// Turn the player.
  void turn() {
    heading = normaliseAngle(heading + (_turningValue * turnAmount));
    game.outputSound(sound: tileMap.turnSound);
  }
}
