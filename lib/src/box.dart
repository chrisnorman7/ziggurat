/// Provides the [Box] class.
import 'dart:io';
import 'dart:math';

import 'box_types/base.dart';
import 'box_types/surface.dart';
import 'box_types/wall.dart';

/// A box on a map.
class Box<T extends BoxType> {
  /// Create a box.
  Box(this.name, this.start, this.end, this.type, {this.sound}) {
    width = (end.x - start.x) + 1;
    height = (end.y - start.y) + 1;
    halfWidth = width / 2;
    halfHeight = height / 2;
    cornerNw = Point<int>(start.x, end.y);
    cornerSe = Point<int>(end.x, start.y);
    centre = Point<double>(start.x + halfWidth, start.y + halfHeight);
  }

  /// The name of this box.
  final String name;

  /// The start coordinates of this box.
  final Point<int> start;

  /// The end coordinates of this box.
  final Point<int> end;

  /// The width of this box.
  ///
  /// This is the distance east to west.
  late final int width;

  /// The height of this box.
  ///
  /// This is the distance north to south.
  late final int height;

  /// Half the width of this box.
  late final double halfWidth;

  /// Half the height of this box.
  late final double halfHeight;

  /// The coordinates at the northwest corner of this box.
  late final Point<int> cornerNw;

  /// The coordinates of the southeast corner of this box.
  late final Point<int> cornerSe;

  /// The centre coordinates of this box.
  late final Point<double> centre;

  /// The type of this box.
  final T type;

  /// The sound of this box.
  ///
  /// If this box is a [Wall], this sound will be heard when a player walks
  /// into it.
  ///
  /// If this box is a [Surface], this sound will be heard when walking on
  /// it.
  final FileSystemEntity? sound;

  /// Returns `true` if this box contains the point [p].
  bool containsPoint(Point<int> p) =>
      p.x >= start.x && p.y >= start.y && p.x <= end.x && p.y <= end.y;

  /// What happens when this box is "activated".
  ///
  /// Exactly when a box is activated is left up to the programmer, but maybe
  /// when the enter key is pressed.
  void onActivate() {}
}
