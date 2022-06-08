import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:test/test.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/ziggurat.dart';

/// Mine flag.
const mine = 1;

/// Wall flag.
const wall = 2;

/// Hole flag.
const hole = 4;

/// Death flag.
const death = 8;

/// A test tile.
class TestTile extends Tile {
  /// Create an instance.
  const TestTile({
    required super.x,
    required super.y,
    required super.value,
  });

  /// Mine flag.
  bool get isMine => hasFlag(mine);

  /// The wall flag.
  bool get isWall => hasFlag(wall);

  /// The hole flag.
  bool get isHole => hasFlag(hole);

  /// Death flag.
  bool get isDeath => hasFlag(death);
}

/// The test tile map level.
class TestTileMapLevel extends TileMapLevel<TestTile> {
  /// Create an instance.
  TestTileMapLevel({required super.game})
      : super(
          tileMap: const TileMap(
            width: 10,
            height: 10,
            tiles: {
              0: {0: mine},
              3: {3: hole},
              5: {5: wall | death}
            },
          ),
          makeTile: (final point, final flags) =>
              TestTile(x: point.x, y: point.y, value: flags),
        );
}

void main() {
  final sdl = Sdl();
  final game = Game(
    title: 'Tile Map Levels',
    sdl: sdl,
  );
  group(
    'TileMapLevel',
    () {
      test(
        'Initialise',
        () {
          final level = TestTileMapLevel(
            game: game,
          );
          expect(level.getTile(const Point(0, 0)), isA<TestTile>());
        },
      );
      test(
        '.coordinates',
        () {
          final level = TestTileMapLevel(game: game);
          expect(level.coordinates, const Point(0.0, 0.0));
          level.coordinates = const Point(5.0, 6.1);
          expect(level.coordinates, const Point(5.0, 6.1));
        },
      );
      test(
        '.heading',
        () {
          final level = TestTileMapLevel(game: game);
          expect(level.heading, 0.0);
          level.heading = 45.0;
          expect(level.heading, 45.0);
        },
      );
      test(
        '.getTile',
        () {
          final level = TestTileMapLevel(game: game);
          var tile = level.getTile(const Point(0, 0));
          expect(tile.isMine, true);
          expect(tile.isDeath, false);
          tile = level.getTile(const Point(5, 5));
          expect(tile.isHole, false);
          expect(tile.isWall, true);
          expect(tile.isDeath, true);
        },
      );
    },
  );
}
