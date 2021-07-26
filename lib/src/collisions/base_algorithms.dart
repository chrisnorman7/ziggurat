/// Provides base algorithms for computing collisions.
import 'package:tuple/tuple.dart';

import '../tile.dart';

/// The simplest check possible. Can return duplicates. Is very, very expensive.
/// This is here for testing purposes: we know that it works, ergo we can test
/// against it to make sure more complicated algorithms are right.
Iterable<Tuple2<Tile, Tile>> checkExhaustive(List<Tile> tiles) sync* {
  for (final a in tiles) {
    for (final b in tiles) {
      // If the centers of the boxes are close enough together that they overlap
      // in the x and y axis both, they overlap.
      //
      // See the readme for the edge cases with box detection: in particular,
      // it's not sufficient to check if one of the corners is inside the other
      // box.
      if (a != b &&
          (a.centre.x - b.centre.x).abs() <= (a.halfWidth + b.halfWidth) &&
          (a.centre.y - b.centre.y).abs() <= (a.halfDepth + b.halfDepth)) {
        yield Tuple2<Tile, Tile>(a, b);
      }
    }
  }
}

/// This version does half the comparisons of check_exhaustive by using the
/// fact that we know that we only need to check boxes to the right of what
/// we've already done. Consider a list of 3 boxes `[a, b, c]`.
/// The first loop will check `[(a, a), (a, b), (a, c)]`
/// This means that a has been checked against all the other boxes. The second
/// loop then does:
/// `[(b, c)]`
/// And the third loop does nothing.
/// Extend this to bigger cases, if you want further proof that it works.
///
/// This variant also doesn't yield duplicated collision pairs, *and* we do
/// this without having to check in a set.
Iterable<Tuple2<Tile, Tile>> checkDeduplicated(List<Tile> tiles) sync* {
  // Save the len function call.
  final l = tiles.length;
  for (var i = 0; i < l; i++) {
    // The inner loop only does l to the end of the boxes.
    for (var j = i + 1; j < l; j++) {
      final a = tiles[i];
      final b = tiles[j];
      if ((a.centre.x - b.centre.x).abs() <=
              (a.halfWidth + b.halfWidth).abs() &&
          (a.centre.y - b.centre.y).abs() <= (a.halfDepth + b.halfDepth)) {
        yield Tuple2<Tile, Tile>(a, b);
      }
    }
  }
}
