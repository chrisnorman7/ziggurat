/// Provides the [Tile] class.
import 'dart:math';

import 'tile_types/base.dart';
import 'tile_types/wall.dart';

/// A tile on a map.
class Tile<T extends TileType> {
  /// Create a tile.
  Tile(this.name, this.start, this.end, this.type, {this.sound});

  /// The name of this tile.
  final String name;

  /// The start coordinates of this tile.
  final Point<int> start;

  /// The end coordinates of this tile.
  final Point<int> end;

  /// The type of this tile.
  T type;

  /// The sound of this surface.
  ///
  /// If this surface is a [Wall], this sound will be heard when a player walks
  /// into it.
  ///
  /// If this surface is a [Tile], this sound will be heard when walking on it.
  late final String? sound;

  /// Get the width of this tile.
  int get width => (end.x - start.x) + 1;

  /// Get the depth of this room.
  ///
  /// This is the distance north to south.
  int get depth => (end.y - start.y) + 1;

  /// The coordinates at the northwest corner of this tile.
  Point<int> get cornerNw => Point<int>(start.x, end.y);

  /// The coordinates of the southeast corner of this tile.
  Point<int> get cornerSe => Point<int>(end.y, start.y);

  /// Returns `true` if this tile contains the point [p].
  bool containsPoint(Point<int> p) =>
      p.x >= start.x && p.y >= start.y && p.x <= end.x && p.y <= end.y;

  /// What happens when this tile is "activated".
  ///
  /// Exactly when a tile is activated is left up to the programmer, but maybe
  /// when the enter key is pressed.
  void onActivate() {}
}
