/// Functions for partitioning a list of boxes into subsets that might collide
/// using a heuristic algorithm and some sorting.
import 'dart:math';

import 'package:tuple/tuple.dart';

import '../tile.dart';
import 'base_algorithms.dart';
import 'tile_manager.dart';
import 'typedefs.dart';

/// Get an estimated center of a bunch of boxes.
Point<double> estimateCentre(TilesList tiles) {
  var x = 0.0;
  var y = 0.0;
  for (final t in tiles) {
    x += t.centre.x;
    y += t.centre.y;
  }
  return Point<double>(x / tiles.length, y / tiles.length);
}

/// Given a big list of boxes, partition it into 4 quadrants, where each
/// quadrant contains all the boxes that overlap with the quadrant.  Boxes can
/// be in more than 1 quadrant, if it's possible for them to collide with each
/// other.
/// Imagine this like an X where the center of the X is at the estimated center
/// of all the boxes. If the box is in one corner of the X, then it can't
/// collide with boxes in other corners.  But it's possible for a box to be on
/// the line, in which case it might be in all of them.
Tuple4<TilesList, TilesList, TilesList, TilesList> partitionQuadrants(
    TilesList tiles) {
  final partitionBottomLeft = <Tile>[];
  final partitionUpperLeft = <Tile>[];
  final partitionBottomRight = <Tile>[];
  final partitionUpperRight = <Tile>[];
  final centre = estimateCentre(tiles);
  for (final t in tiles) {
    // If the minimum x of the box < center_x, it can be in either of the left
    // quadrants.
    if (t.start.x <= centre.x) {
      // If the minimum y < center_y, it's in the bottom left.
      if (t.start.y <= centre.y) {
        partitionBottomLeft.add(t);
      }
      // If the maximum y > center_y, it's also in the top left quadrant.
      if (t.end.y >= centre.y) {
        partitionUpperLeft.add(t);
      }
    }
    // Same logic, but for the right half.
    if (t.end.x >= centre.x) {
      if (t.start.y <= centre.y) {
        partitionBottomRight.add(t);
      }
      if (t.end.y >= centre.y) {
        partitionUpperRight.add(t);
      }
    }
  }
  return Tuple4(partitionBottomLeft, partitionUpperLeft, partitionBottomRight,
      partitionUpperRight);
}

/// This is a recursive function which partitions repeatedly until either a
/// maximum number of iterations or a minimum partition size. In the best case,
/// the function terminates early because the boxes are spread apart sparsely,
/// but it's possible that partitioning won't ever break up a partition at all
/// or will get stuck partitioning for a long time, if the boxes are all
/// overlapping.
Iterable<TilesList> partition(
    TilesList tiles, int partitionSize, int maxIterations,
    {int iteration = 0}) sync* {
  if (iteration == maxIterations) {
    // We got passed a partition, yield it up unchanged.
    yield tiles;
    return;
  }
  final quadrants = partitionQuadrants(tiles);
  for (final p in [
    quadrants.item1,
    quadrants.item2,
    quadrants.item3,
    quadrants.item4
  ]) {
    // Check the partition limit. Also, check if this partition shrunk at
    // all. If it didn't shrink, it probably can't be partitioned further,
    // and we might as well not waste time on it.
    if (p.length <= partitionSize || p.length == tiles.length) {
      yield p;
      continue;
    }
    yield* partition(p, partitionSize, maxIterations, iteration: iteration + 1);
  }
}

/// This isn't the final algorithm. For partitioning to really work for us, we
/// also want some other stuff. See [TileManager] for what that other stuff is.
TilesTupleIterable checkPartitioned(TilesList tiles) sync* {
  if (tiles.isNotEmpty) {
    for (final p in partition(tiles, 10, 2)) {
      yield* checkDeduplicated(p);
    }
  }
}
