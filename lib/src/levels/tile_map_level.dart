/// Provides the [TileMapLevel] class.
import 'dart:math';

import 'package:meta/meta.dart';

import '../json/tile.dart';
import '../json/tile_map.dart';
import 'level.dart';

/// A level which holds a [tileMap].
///
/// To change the player's position on the map, use the [coordinates] setter.
class TileMapLevel<T extends Tile> extends Level {
  /// Create an instance.
  TileMapLevel({
    required super.game,
    required this.tileMap,
    required this.makeTile,
    this.initialCoordinates = const Point(0.0, 0.0),
    this.initialHeading = 0.0,
    super.ambiances,
    super.commands,
    super.music,
    super.randomSounds,
  })  : _coordinates = initialCoordinates,
        _heading = initialHeading;

  /// The tile map to use.
  final TileMap tileMap;

  /// The initial coordinates of the player.
  final Point<double> initialCoordinates;

  late Point<double> _coordinates;

  /// The player's coordinates.
  Point<double> get coordinates => _coordinates;

  /// Set the player's [coordinates].
  @mustCallSuper
  set coordinates(final Point<double> value) {
    _coordinates = value;
    game.setListenerPosition(value.x, value.y, 0.0);
  }

  /// The initial heading of the player.
  final double initialHeading;

  late double _heading;

  /// The player's bearing in degrees.
  @mustCallSuper
  double get heading => _heading;

  /// Set the player's [heading].
  set heading(final double value) {
    _heading = value;
    game.setListenerOrientation(value);
  }

  /// The function to convert flags to a tile.
  final T Function(Point<int> point, int flags) makeTile;

  /// Get the tile at the given [point].
  T getTile(final Point<int> point) => makeTile(
        point,
        tileMap.getTileFlags(point),
      );
}
