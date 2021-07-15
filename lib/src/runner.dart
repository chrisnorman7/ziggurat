/// Provides the [Runner] class.
import 'dart:math';

import 'package:dart_synthizer/dart_synthizer.dart';

import 'math.dart';
import 'tile.dart';
import 'tile_types/wall.dart';
import 'ziggurat.dart';

/// An extension for returning a `Point<int>` from a `Point<double>`.
extension RunnerMethods on Point<double> {
  /// Return a floored version of this point.
  Point<int> floor() => Point<int>(x.floor(), y.floor());
}

/// A class for running maps.
class Runner {
  /// Create the runner.
  Runner(this.ziggurat, this.context) {
    heading = ziggurat.initialHeading;
    coordinates = ziggurat.initialCoordinates;
  }

  /// The ziggurat this runner will work with.
  final Ziggurat ziggurat;

  /// The synthizer context to use.
  final Context context;

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
  }

  /// Return the tile at the given [coordinates], if any.
  Tile? getTile(Point<int> coordinates) {
    for (final t in ziggurat.tiles) {
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
}
