/// Provides the [Surface] class.
import 'dart:math';

import 'tile.dart';
import 'wall.dart';

/// The base class for [Wall]s and [Tile]s.
mixin Surface {
  /// The start coordinates of this tile.
  late final Point<int> start;

  /// The end coordinates of this tile.
  late final Point<int> end;

  /// The sound of this surface.
  ///
  /// If this surface is a [Wall], this sound will be heard when a player walks
  /// into it.
  ///
  /// If this surface is a [Tile], this sound will be heard when walking on it.
  late final String? sound;

  /// Get the width of this tile.
  int get width => end.x - start.x;

  /// Get the depth of this room.
  ///
  /// This is the distance north to south.
  int get depth => end.y - start.y;

  /// The coordinates at the northwest corner of this tile.
  Point<int> get cornerNw => Point<int>(start.x, end.y);

  /// The coordinates of the southeast corner of this tile.
  Point<int> get cornerSe => Point<int>(end.y, start.y);

  /// Returns `true` if this tile contains the point [p].
  bool containsPoint(Point<int> p) =>
      p.x >= start.x && p.y >= start.y && p.x <= end.x && p.y <= end.y;
}
