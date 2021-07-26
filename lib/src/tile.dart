/// Provides the [Tile] class.
import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';

import 'tile_types/base.dart';
import 'tile_types/surface.dart';
import 'tile_types/wall.dart';

/// A tile on a map.
class Tile<T extends TileType> {
  /// Create a tile.
  Tile(this.name, this.start, this.end, this.type, {this.sound}) {
    onAfterMove();
  }

  /// The name of this tile.
  final String name;

  /// The start coordinates of this tile.
  Point<int> start;

  /// The end coordinates of this tile.
  Point<int> end;

  /// The type of this tile.
  final T type;

  /// The sound of this surface.
  ///
  /// If this tile is a [Wall], this sound will be heard when a player walks
  /// into it.
  ///
  /// If this tile is a [Surface], this sound will be heard when walking on
  /// it.
  final FileSystemEntity? sound;

  /// The width of this tile.
  ///
  /// This is the distance east to west.
  late int width;

  /// The depth of this room.
  ///
  /// This is the distance north to south.
  late int depth;

  /// Half the width of this tile.
  late double halfWidth;

  /// Half the depth of this box.
  late double halfDepth;

  /// The coordinates at the northwest corner of this tile.
  late Point<int> cornerNw;

  /// The coordinates of the southeast corner of this tile.
  late Point<int> cornerSe;

  /// The centre coordinates of this tile.
  late Point<double> centre;

  /// Returns `true` if this tile contains the point [p].
  bool containsPoint(Point<int> p) =>
      p.x >= start.x && p.y >= start.y && p.x <= end.x && p.y <= end.y;

  /// What happens when this tile is "activated".
  ///
  /// Exactly when a tile is activated is left up to the programmer, but maybe
  /// when the enter key is pressed.
  void onActivate() {}

  /// Code to run after a tile has moved.
  @mustCallSuper
  void onAfterMove() {
    width = (end.x - start.x) + 1;
    depth = (end.y - start.y) + 1;
    halfWidth = width / 2;
    halfDepth = depth / 2;
    cornerNw = Point<int>(start.x, end.y);
    cornerSe = Point<int>(end.x, start.y);
    centre = Point<double>(start.x + halfWidth, start.y + halfDepth);
  }

  /// Move this box.
  ///
  /// This function changes the bounds of the box.
  @mustCallSuper
  void move(Point<int> startCoordinates, Point<int> endCoordinates) {
    start = startCoordinates;
    end = endCoordinates;
    onAfterMove();
  }
}
