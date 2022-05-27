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

  /// Set the tile at the given [point] to the given [flags].
  ///
  /// If you only want to set or unset a single flag at a time, consider the
  /// [setTileFlag] and [clearTileFlag] methods.
  void setTileFlags({
    required final Point<int> point,
    required final int flags,
  }) {
    tiles.putIfAbsent(point.x, () => {})[point.y] = flags;
  }

  /// Set the given [flag] on the tile at the given [point].
  void setTileFlag({
    required final Point<int> point,
    required final int flag,
  }) {
    final map = tiles.putIfAbsent(point.x, () => {});
    final value = map.putIfAbsent(point.y, () => 0) | flag;
    map[point.y] = value;
  }

  /// Clear the given [flag] from the tile at the given [point].
  void clearTileFlag({
    required final Point<int> point,
    required final int flag,
  }) {
    final map = tiles.putIfAbsent(point.x, () => {});
    final value = map.putIfAbsent(point.y, () => 0);
    if (value & flag != 0) {
      map[point.y] = value - flag;
    }
  }

  /// Returns `true` if the given [point] represents valid coordinates for this
  /// map.
  bool validCoordinates(final Point<int> point) =>
      point.x >= 0 && point.x < width && point.y >= 0 && point.y < height;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$TileMapToJson(this);
}
