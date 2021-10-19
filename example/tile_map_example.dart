import 'dart:math';

import 'package:dart_sdl/dart_sdl.dart';
import 'package:ziggurat/levels.dart';
import 'package:ziggurat/mapping.dart';
import 'package:ziggurat/ziggurat.dart';

Future<void> main() async {
  final game = Game('Tile Map Example');
  final sdl = Sdl()..init();
  final map = TileMap(
      tiles: [],
      width: 10,
      height: 10,
      wallMessage: Message(text: 'You walk into a wall.'));
  for (var x = 0; x < map.width; x++) {
    for (var y = 0; y < map.height; y++) {
      map.tiles.add(Tile(
        coordinates: Point(x, y),
        onEnter: () => game.outputText('Coordinates $x $y.'),
      ));
    }
  }
  final level = TileMapLevel(game: game, tileMap: map);
  game.pushLevel(level);
  await game.run(sdl);
}
