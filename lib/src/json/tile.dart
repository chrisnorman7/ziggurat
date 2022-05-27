/// Provides the [Tile] class.
import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

part 'tile.g.dart';

/// A tile for a map.
@JsonSerializable()
class Tile {
  /// Create an instance.
  const Tile({
    required this.x,
    required this.y,
    required this.value,
  });

  /// Create an instance from the given [point].
  Tile.fromPoint({
    required final Point<int> point,
    required this.value,
  })  : x = point.x,
        y = point.y;

  /// Create an instance from a JSON object.
  factory Tile.fromJson(final Map<String, dynamic> json) =>
      _$TileFromJson(json);

  /// The x coordinate of this tile.
  final int x;

  /// The y coordinate of this tile.
  final int y;

  /// The value of this tile.
  final int value;

  /// Get the coordinates of this tile.
  Point get coordinates => Point(x, y);

  /// Returns `true` if [value] has the given [flag].
  bool hasFlag(final int flag) => value & flag != 0;

  /// Convert an instance to JSON.
  Map<String, dynamic> toJson() => _$TileToJson(this);
}
