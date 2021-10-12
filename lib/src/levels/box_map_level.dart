/// Provides the [BoxMapLevel] class.
import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';

import '../box_map/box.dart';
import '../box_map/box_map.dart';
import '../box_map/box_types/surface.dart';
import '../error.dart';
import '../game.dart';
import '../math.dart';
import '../sound/ambiance.dart';
import '../sound/random_sound.dart';
import 'level.dart';

/// A level that can be used to play a [BoxMap] instance.
class BoxMapLevel extends Level {
  /// Create an instance.
  BoxMapLevel(Game game, this.boxMap,
      {this.activateScanCode = ScanCode.SCANCODE_RETURN,
      this.activateButton = GameControllerButton.rightshoulder,
      this.moveAxis = GameControllerAxis.righty,
      this.turnAxis = GameControllerAxis.leftx,
      List<Ambiance>? ambiances,
      List<RandomSound>? randomSounds})
      : lastTurn = 0,
        lastMove = 0,
        super(game, ambiances: ambiances, randomSounds: randomSounds) {
    _coordinates = boxMap.initialCoordinates;
    _heading = boxMap.initialHeading;
    var sizeX = 0;
    var sizeY = 0;
    for (final box in boxMap.boxes) {
      if (box.start.x < 0 ||
          box.start.y < 0 ||
          box.end.x < 0 ||
          box.end.y < 0) {
        throw NegativeCoordinatesError(box);
      }
      sizeX = max(sizeX, box.end.x);
      sizeY = max(sizeY, box.end.y);
    }
    width = sizeX + 1;
    height = sizeY + 1;
    _tiles = List<List<Box?>>.from(<List<Box?>>[
      for (var x = 0; x <= sizeX; x++)
        List<Box?>.from(<Box?>[for (var y = 0; y <= sizeY; y++) null])
    ]);
    for (final box in boxMap.boxes) {
      for (var x = box.start.x; x <= box.end.x; x++) {
        for (var y = box.start.y; y <= box.end.y; y++) {
          _tiles[x][y] = box;
        }
      }
    }
  }

  /// The box map to render.
  final BoxMap boxMap;

  /// The scancode that will be used to activate the current box.
  final ScanCode activateScanCode;

  /// The controller button that will activate the current box.
  final GameControllerButton activateButton;

  /// The axis that will be used to move the player forward or backwards.
  final GameControllerAxis moveAxis;

  /// The axis that will be used to turn the player.
  final GameControllerAxis turnAxis;

  /// The coordinates of the player.
  late Point<double> _coordinates;

  /// Get the coordinates of the player.
  Point<double> get coordinates => _coordinates;

  /// Set the player coordinates.
  ///
  /// this setter also sets the listener position.
  set coordinates(Point<double> value) {
    _coordinates = value;
    game.setListenerPosition(value.x, value.y, 0.0);
  }

  /// Get the current box.
  ///
  /// If the player is not on a box, the behaviour is undefined.
  Box get currentBox {
    final c = coordinates;
    final box = tileAt(c.x.floor(), c.y.floor());
    if (box == null) {
      throw NoBoxError(c);
    }
    return box;
  }

  /// The direction the player is facing.
  late double _heading;

  /// Get the heading that the player is facing in..
  double get heading => _heading;

  /// Set the direction the player is facing in.
  ///
  /// this setter also sets the listener heading.
  set heading(double value) {
    _heading = value;
    game.setListenerOrientation(value);
  }

  /// All the tiles present on this map.
  late final List<List<Box?>> _tiles;

  /// The width of this map.
  late final int width;

  /// The depth of this map.
  late final int height;

  /// Get the tile at the given coordinates.
  Box? tileAt(int x, int y) => _tiles[x][y];

  /// The time the player last moved.
  int lastTurn;

  /// The time the player last moved.
  int lastMove;

  /// Get the tile at the given point.
  Box? tileAtPoint(Point<int> coordinates) =>
      tileAt(coordinates.x, coordinates.y);

  /// Turn the specified [amount].
  void turn(double amount) {
    heading = normaliseAngle(heading + amount);
  }

  /// Move the given [distance] on the given [bearing].
  ///
  /// If [bearing] is `null`, then [heading] will be used.
  void move(double distance, {double? bearing}) {
    bearing ??= heading;
    final newCoordinates =
        coordinatesInDirection(coordinates, bearing, distance);
    final newBox = tileAt(newCoordinates.x.floor(), newCoordinates.y.floor());
    if (newBox == null) {
      // Should probably do something more interesting.
      return;
    }
    coordinates = newCoordinates;
  }

  @override
  void handleSdlEvent(Event event) {
    if ((event is ControllerButtonEvent &&
            event.button == activateButton &&
            event.state == PressedState.pressed) ||
        (event is KeyboardEvent &&
            event.state == PressedState.pressed &&
            event.repeat == false &&
            event.key.modifiers.isEmpty &&
            event.key.scancode == activateScanCode)) {
      final onActivate = currentBox.onActivate;
      if (onActivate != null) {
        onActivate();
      }
    } else if (event is ControllerAxisEvent) {
      if (event.axis == turnAxis) {
        final surface = currentBox.type;
        if (surface is! Surface) {
          return;
        }
        final now = DateTime.now().millisecondsSinceEpoch;
        if ((now - lastTurn) >= (surface.minTurnInterval / event.value)) {
          turn(surface.turnAmount);
          lastTurn = now;
        }
      } else if (event.axis == moveAxis) {
        final surface = currentBox.type;
        if (surface is! Surface) {
          return;
        }
        final now = DateTime.now().millisecondsSinceEpoch;
        if ((now - lastMove) >= (surface.minMoveInterval / event.value)) {
          move(surface.footstepSize);
          lastMove = now;
        }
      }
    }
  }
}
