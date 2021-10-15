/// Provides the [Tile] class.
import 'dart:math';

import '../json/asset_reference.dart';
import 'tile_map.dart';

/// A tile on a [TileMap].
class Tile {
  /// Create a tile.
  const Tile(
      {required this.coordinates,
      this.ambiance,
      this.ambianceGain = 0.7,
      this.onEnter,
      this.onExit});

  /// The coordinates of this tile.
  final Point<int> coordinates;

  /// The ambiance for this tile.
  final AssetReference? ambiance;

  /// The gain of [ambiance].
  ///
  /// If [ambiance] is `null`, this value has no effect.
  final double ambianceGain;

  /// What happens when the player enters this tile.
  final void Function()? onEnter;

  /// What happens when the player exits this tile.
  final void Function()? onExit;
}
