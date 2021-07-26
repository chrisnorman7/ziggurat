/// Provides typedefs for use with collision code.
import 'package:tuple/tuple.dart';

import '../tile.dart';

/// Tuple used by many of the collision functions.
typedef TilesTuple = Tuple2<Tile, Tile>;

/// Required as an argument to many of the collision algorithms.
typedef TilesTupleList = List<TilesTuple>;

/// The iterator returned by many of the collision algorithms.
typedef TilesTupleIterable = Iterable<TilesTuple>;

/// A simple list of tiles.
typedef TilesList = List<Tile>;
