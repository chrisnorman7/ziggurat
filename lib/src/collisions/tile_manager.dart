/// Provides the [TileManager] class.
import 'dart:math';

import 'package:tuple/tuple.dart';

import '../tile.dart';
import 'partitioner.dart';
import 'typedefs.dart';

/// We can get even more speed from holding some state as to whether or not we
/// expect boxes to move and, if not, caching some of the collision steps.
///
/// Doing this requires going via a manager class that can track movement.
class TileManager {
  /// Create a manager.
  TileManager()
      : tiles = [],
        stationaryCache = [],
        stationaryCacheValid = true,
        stationaryCount = 0;

  /// The tiles held by this manager.
  final List<Tile> tiles;

  /// The stationary cache.
  final TilesTupleList stationaryCache;

  /// Whether or not the cache is valid.
  bool stationaryCacheValid;

  /// The length of the stationary count.
  int stationaryCount;

  /// Register a tile with this manager.
  void register(Tile tile) {
    tiles.add(tile);
    // inject ourselves as the manager.
    if (tile.stationary) {
      invalidateStationaryCache();
      stationaryCount++;
    }
  }

  /// Remove a tile from this manager.
  void remove(Tile tile) {
    tiles.remove(tile);
    if (tile.stationary) {
      invalidateStationaryCache();
      stationaryCount--;
    }
  }

  /// Invalidate the stationary cache.
  void invalidateStationaryCache() {
    stationaryCacheValid = false;
  }

  /// Returns an iterator with all detected collisions.
  TilesTupleIterable yieldCollisions() sync* {
    // No stationary boxes means we shouldn't even bother optimizing.
    if (stationaryCount == 0) {
      yield* checkPartitioned(tiles);
    } else if (stationaryCacheValid == false) {
      stationaryCache.clear();
      for (final t in _doNotOptimised()) {
        final a = t.item1;
        final b = t.item2;
        final tup = Tuple2(a, b);
        if (a.stationary && b.stationary) {
          stationaryCache.add(tup);
        }
        yield tup;
        stationaryCacheValid = true;
      }
    } else {
      yield* stationaryCache;
      // If all the boxes are stationary, all the collisions are always
      //already cached.
      if (tiles.length == stationaryCount) {
        return;
      }
      yield* _doOptimised();
    }
  }

  TilesTupleIterable _doNotOptimised() sync* {
    // Just ask the partitioner nicely.
    yield* checkPartitioned(tiles);
  }

  TilesTupleIterable _doOptimised() sync* {
    // See below.
    yield* checkPartitionOptimised(tiles, stationaryCount);
  }
}

/// An optimized checker that assumes that all stationary to stationary
/// collisions are cached. Additionally, it inlines all the functions so that
/// we don't pay the Python function overhead.
TilesTupleIterable checkPartitionOptimised(
    TilesList tiles, int stationaryCount) sync* {
  if (tiles.isNotEmpty) {
    // We want roughly equal numbers of stationary boxes in each partition, and
    // we can assume that they're free (see below).
    //
    // `stationary / tiles.length` is the probability of a single box being
    // stationary, and the partitioner's worst case is sampling with
    // replacement.
    //
    // We have:
    // `nonStationary = size * (1 - stationaryPercent)`
    // `nonStationary / (1 - stationaryPercent) = size`
    final partitionSize =
        max(10, (10 / (1 - stationaryCount / tiles.length)).ceil());
    for (final part in partition(tiles, partitionSize, 2)) {
      // The trick of optimizing stationary boxes is realizing that if we put
      // all the stationary boxes at the end, we can use the same trick as in
      // check_deduplicated. Only, this time, we stop the outer loop when it
      // hits a stationary box: at that point, we know that we'll just yield
      // already-cached stationary pairs.
      part.sort((Tile a, Tile b) {
        if (b.stationary == true && a.stationary == false) {
          return 1;
        } else if (b.stationary == false && a.stationary == true) {
          return -1;
        } else {
          return 0;
        }
      });
      final l = part.length;
      for (var i = 0; i < l; i++) {
        if (part[i].stationary == true) {
          break;
        }
        for (var j = i + 1; j < l; j++) {
          final a = part[i];
          final b = part[j];
          if ((a.centre.x - b.centre.x).abs() <= (a.halfWidth + b.halfWidth) &&
              (a.centre.y - b.centre.y).abs() <= (a.halfDepth + b.halfDepth)) {
            yield Tuple2(a, b);
          }
        }
      }
    }
  }
}
