/// Provides the [TileMap] class.
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import 'tile.dart';

part 'tile_map.g.dart';

/// A map which contains integer values which can be turned into [Tile]
/// instances.
@JsonSerializable()
class TileMap {
  /// Create an instance.
  const TileMap({
    required this.width,
    required this.height,
    this.defaultFlags = 0,
    this.tiles = const {},
  });

  /// Create an instance from a JSON object.
  factory TileMap.fromJson(final Map<String, dynamic> json) =>
      _$TileMapFromJson(json);

  /// The width of the map.
  ///
  /// The number of columns will be 1 less than this value.
  final int width;

  /// The height of this map.
  ///
  /// the number of rows will be 1 less than this value.
  final int height;

  /// The default flags for newly-created tiles.
  final int defaultFlags;

  /// The created tiles.
  ///
  /// Any coordinates not in this map will be set to [defaultFlags].
  final Map<int, Map<int, int>> tiles;

  /// Get the value for the given coordinates.
  ///
  /// If no flags have been saved for the given [point], [defaultFlags] will be
  /// returned.
  int getTileFlags(final Point<int> point) {
    final map = tiles[point.x];
    if (map == null) {
      return defaultFlags;
    }
    return map[point.y] ?? defaultFlags;
  }

  /// Returns `true` if the given [point] represents valid coordinates for this
  /// map.
  bool validCoordinates(final Point<int> point) =>
      point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$TileMapToJson(this);
}
