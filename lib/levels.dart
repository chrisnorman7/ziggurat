/// The [Level] class, as well as various subclasses.
///
/// This file used to be part of the main Ziggurat package, but as the number of
/// levels grew, it became something of an information overload.
///
/// The only level subclass that is not exported here is the [Menu] class.
///
/// ## Description
///
/// Once you have created a [Game] instance, you will eventually want to push
/// [Level] instances. You can of course subclass [Level], and implement your
/// own behaviour. There are a bunch of different ready-to-use levels to start
/// with, including the [Menu] and [Editor] classes.
///
/// For mapping, there is the [TileMapLevel] class, but this is only suitable
/// for rapid prototyping, and will eventually become restrictive.
library levels;

import 'src/game.dart';
import 'src/levels/editor.dart';
import 'src/levels/level.dart';
import 'src/levels/tile_map_level.dart';
import 'src/menu/menu.dart';

export 'src/json/level_stub.dart';
export 'src/levels/dialogue_level.dart';
export 'src/levels/editor.dart';
export 'src/levels/level.dart';
export 'src/levels/multi_grid_level.dart';
export 'src/levels/scene_level.dart';
export 'src/levels/tile_map_level.dart';
