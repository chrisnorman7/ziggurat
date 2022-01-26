/// Provides the [TileMapLevel] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:meta/meta.dart';

import '../directions.dart';
import '../extensions.dart';
import '../game.dart';
import '../json/ambiance.dart';
import '../json/axis_setting.dart';
import '../json/random_sound.dart';
import '../math.dart';
import '../tile_map/tile.dart';
import '../tile_map/tile_map.dart';
import 'level.dart';

/// A level that will render a [TileMap] instance.
class TileMapLevel extends Level {
  /// Create an instance.
  TileMapLevel({
    required Game game,
    required this.tileMap,
    Point<double>? coordinates,
    double heading = 0.0,
    this.forwardMoveDistance = 1.0,
    this.backwardMoveDistance = 0.5,
    this.lateralMoveDistance = 0.7,
    this.turnAmount = 5.0,
    this.movementSettings =
        const AxisSetting(GameControllerAxis.lefty, 0.5, 500),
    this.forwardScanCode = ScanCode.SCANCODE_W,
    this.backwardScanCode = ScanCode.SCANCODE_S,
    this.sidestepSettings =
        const AxisSetting(GameControllerAxis.leftx, 0.5, 600),
    this.sidestepLeftScanCode = ScanCode.SCANCODE_A,
    this.sidestepRightScanCode = ScanCode.SCANCODE_D,
    this.turnSettings = const AxisSetting(GameControllerAxis.rightx, 0.5, 300),
    this.turnLeftScanCode = ScanCode.SCANCODE_LEFT,
    this.turnRightScanCode = ScanCode.SCANCODE_RIGHT,
    List<Ambiance>? ambiances,
    List<RandomSound>? randomSounds,
  })  : lastMove = 0,
        lastTurn = 0,
        _tiles = List.generate(
            tileMap.width, (index) => List.filled(tileMap.height, null)),
        _coordinates = coordinates ??
            Point(tileMap.start.x.toDouble(), tileMap.start.y.toDouble()),
        _heading = heading,
        super(
          game: game,
          ambiances: (ambiances ?? []) +
              [
                for (final tile in tileMap.tiles)
                  if (tile.ambiance != null)
                    Ambiance(
                        sound: tile.ambiance!,
                        gain: tile.ambianceGain,
                        position: tile.coordinates.toDouble())
              ],
          randomSounds: randomSounds,
        ) {
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

  /// The distance to move the player.
  ///
  /// This value will be used by the [move] method.
  final double forwardMoveDistance;

  /// The size of the player's footsteps when moving backwards.
  final double backwardMoveDistance;

  /// The size of the player's footsteps when moving laterally.
  double lateralMoveDistance;

  /// How far to turn the player.
  ///
  /// This value will be used by the [turn] method.
  final double turnAmount;

  /// Configure how the player will move forward and backward.
  final AxisSetting movementSettings;

  /// The key to move forward.
  final ScanCode forwardScanCode;

  /// The key to move backwards.
  final ScanCode backwardScanCode;

  /// Configure how the player will sidestep.
  final AxisSetting sidestepSettings;

  /// The key to sidestep left.
  final ScanCode sidestepLeftScanCode;

  /// The key to move backwards.
  final ScanCode sidestepRightScanCode;

  /// Configure how the player will turn.
  final AxisSetting turnSettings;

  /// The key to turn left.
  final ScanCode turnLeftScanCode;

  /// The key to turn right.
  final ScanCode turnRightScanCode;

  /// The direction the player is moving in.
  MovementDirections? movementDirection;

  /// The direction the player is turning.
  TurnDirections? turnDirection;

  /// The direction the player is sidestepping in.
  TurnDirections? sidestepDirection;

  /// How many milliseconds since the last move.
  int lastMove;

  /// How many seconds since the last turn.
  int lastTurn;

  /// Get the tile at the given [point].
  Tile? tileAt(Point<int> point) {
    try {
      return _tiles[point.x][point.y];
    } on RangeError {
      return null;
    }
  }

  @override
  @mustCallSuper
  void onPush() {
    super.onPush();
    game
      ..setListenerOrientation(heading)
      ..setListenerPosition(coordinates.x, coordinates.y, 0.0);
  }

  @override
  @mustCallSuper
  void handleSdlEvent(Event event) {
    if (event is ControllerAxisEvent) {
      final axis = event.axis;
      final value = event.smallValue;
      if (axis == movementSettings.axis) {
        if (value.abs() >= movementSettings.sensitivity) {
          // The right stick provides positive values when it is pulled back.
          sidestepDirection = null;
          if (value < 0) {
            movementDirection = MovementDirections.forward;
          } else {
            movementDirection = MovementDirections.backward;
          }
        } else {
          movementDirection = null;
        }
      } else if (axis == sidestepSettings.axis) {
        if (value.abs() >= sidestepSettings.sensitivity) {
          movementDirection = null;
          if (value < 0) {
            sidestepDirection = TurnDirections.left;
          } else {
            sidestepDirection = TurnDirections.right;
          }
        } else {
          sidestepDirection = null;
        }
      } else if (axis == turnSettings.axis) {
        if (value.abs() >= turnSettings.sensitivity) {
          if (value < 0) {
            turnDirection = TurnDirections.left;
          } else {
            turnDirection = TurnDirections.right;
          }
        } else {
          turnDirection = null;
        }
      }
    } else if (event is KeyboardEvent) {
      if (event.repeat == false && event.key.modifiers.isEmpty) {
        final scanCode = event.key.scancode;
        final state = event.state;
        if (scanCode == forwardScanCode) {
          sidestepDirection = null;
          movementDirection =
              state == PressedState.pressed ? MovementDirections.forward : null;
        } else if (scanCode == backwardScanCode) {
          sidestepDirection = null;
          movementDirection = state == PressedState.pressed
              ? MovementDirections.backward
              : null;
        } else if (scanCode == sidestepLeftScanCode) {
          movementDirection = null;
          sidestepDirection =
              state == PressedState.pressed ? TurnDirections.left : null;
        } else if (scanCode == sidestepRightScanCode) {
          movementDirection = null;
          sidestepDirection =
              state == PressedState.pressed ? TurnDirections.right : null;
        } else if (scanCode == turnLeftScanCode) {
          turnDirection =
              state == PressedState.pressed ? TurnDirections.left : null;
        } else if (scanCode == turnRightScanCode) {
          turnDirection =
              state == PressedState.pressed ? TurnDirections.right : null;
        }
      }
    }
  }

  @override
  @mustCallSuper
  void tick(Sdl sdl, int timeDelta) {
    if (turnDirection != null &&
        (game.time - lastTurn) >= turnSettings.interval) {
      lastTurn = game.time;
      turn();
    }
    if (movementDirection != null &&
        (game.time - lastMove) >= movementSettings.interval) {
      lastMove = game.time;
      move();
    }
    if (sidestepDirection != null &&
        (game.time - lastMove) >= sidestepSettings.interval) {
      lastMove = game.time;
      sidestep();
    }
  }

  /// Move the player.
  void move({double? direction, double? distance}) {
    if (direction == null || distance == null) {
      if (movementDirection == MovementDirections.forward) {
        direction ??= _heading;
        distance ??= forwardMoveDistance;
      } else {
        direction ??= normaliseAngle(_heading + 180);
        distance ??= backwardMoveDistance;
      }
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

  /// Move the player sideways.
  void sidestep() => move(
      direction: normaliseAngle(sidestepDirection == TurnDirections.left
          ? _heading - 90
          : _heading + 90));

  /// Turn the player.
  void turn({double? angle}) {
    heading = angle ??
        normaliseAngle(turnDirection == TurnDirections.right
            ? heading + turnAmount
            : heading - turnAmount);
    game.outputSound(sound: tileMap.turnSound);
  }
}
