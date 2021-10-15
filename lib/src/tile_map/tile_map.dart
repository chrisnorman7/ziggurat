/// Provides the [TileMap] class.
import 'dart:math';

import '../json/asset_reference.dart';
import '../json/message.dart';
import 'tile.dart';

/// A Simple map with borders.
class TileMap {
  /// Create an instance.
  const TileMap({
    required this.tiles,
    required this.width,
    required this.height,
    this.footstepSound,
    this.turnSound,
    this.wallMessage = const Message(),
  }) : start = const Point(0, 0);

  /// The tiles on this map.
  final List<Tile> tiles;

  /// The starting coordinates of this map.
  final Point<int> start;

  /// The width of this map.
  final int width;

  /// The height of this map.
  final int height;

  /// The end coordinates.
  ///
  /// These coordinates are at the northeastern corner of the map.
  Point<int> get end => Point(start.x + width, start.y + height);

  /// The coordinates at the northwest corner of this map.
  Point<int> get cornerNw => Point(start.x, height);

  /// The coordinates of the southeast corner of this map.
  Point<int> get cornerSe => Point(width, start.y);

  /// The sound that will be heard when the player walks on this map.
  final AssetReference? footstepSound;

  /// The sound that should be heard when the player turns.
  final AssetReference? turnSound;

  /// The sound that will play when the player walks into a wall.
  final Message wallMessage;

  /// Return `true` if the given [point] is contained by this map.
  bool containsPoint(Point<double> point) =>
      point.x >= start.x &&
      point.y >= start.y &&
      point.x <= width &&
      point.y <= height;
}
